mod ntp;

use std::io::{BufRead, BufReader, Write};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use log::{error, info};
use serde_json::Value;

use ntp::NtpClient;

const APP_NAME: &str = "Epic Sax Gandalf";
const DEFAULT_DURATION_MICROS: i64 = 117_540_000;

// ---------------------------------------------------------------------------
// Platform IPC
// ---------------------------------------------------------------------------

#[cfg(unix)]
const IPC_PATH: &str = "/tmp/gandalf-sax-mpv.sock";

#[cfg(windows)]
const IPC_PATH: &str = r"\\.\pipe\gandalf-sax";

#[cfg(unix)]
type IpcStream = std::os::unix::net::UnixStream;

#[cfg(windows)]
type IpcStream = std::fs::File;

fn cleanup_ipc() {
    #[cfg(unix)]
    {
        let _ = std::fs::remove_file(IPC_PATH);
    }
}

fn connect_ipc() -> IpcStream {
    let deadline = std::time::Instant::now() + Duration::from_secs(5);
    loop {
        #[cfg(unix)]
        {
            if let Ok(s) = IpcStream::connect(IPC_PATH) {
                return s;
            }
        }
        #[cfg(windows)]
        {
            if let Ok(f) = std::fs::OpenOptions::new()
                .read(true)
                .write(true)
                .open(IPC_PATH)
            {
                return f;
            }
        }
        if std::time::Instant::now() > deadline {
            panic!("Timed out waiting for mpv IPC at {}", IPC_PATH);
        }
        std::thread::sleep(Duration::from_millis(50));
    }
}

fn mpv_send(stream: &mut impl Write, args: &[&str]) {
    let cmd = serde_json::json!({ "command": args });
    let line = format!("{}\n", cmd);
    if let Err(e) = stream.write_all(line.as_bytes()) {
        error!("IPC write error: {}", e);
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn find_video_path() -> PathBuf {
    let candidates = [
        "assets/video.mp4",
        "video.mp4",
        "../assets/video.mp4",
    ];
    for candidate in &candidates {
        let path = PathBuf::from(candidate);
        if path.exists() {
            return path;
        }
    }
    PathBuf::from("assets/video.mp4")
}

struct AppState {
    ntp: Mutex<NtpClient>,
    duration_micros: Mutex<i64>,
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

fn main() {
    env_logger::init();
    info!("Starting {} v4.0.0", APP_NAME);

    let video_path = find_video_path();
    info!("Video path: {:?}", video_path);

    // --- NTP sync (blocking) ---
    let state = Arc::new(AppState {
        ntp: Mutex::new(NtpClient::new()),
        duration_micros: Mutex::new(DEFAULT_DURATION_MICROS),
    });
    info!("Syncing NTP...");
    {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            state.ntp.lock().unwrap().sync().await;
        });
    }

    // --- Calculate initial seek position ---
    let seek_secs = {
        let ntp = state.ntp.lock().unwrap();
        let dur = *state.duration_micros.lock().unwrap();
        info!("[init] NTP offset: {:.3}ms", ntp.offset_micros as f64 / 1_000.0);
        let seek_micros = ntp.seek_position(dur, true);
        info!("[init] duration={:.2}s, seek_target={:.3}s", dur as f64 / 1_000_000.0, seek_micros as f64 / 1_000_000.0);
        seek_micros as f64 / 1_000_000.0
    };
    info!("Initial seek position: {:.3}s", seek_secs);

    // --- Spawn mpv subprocess ---
    cleanup_ipc();
    let video_str = video_path.to_str().expect("Invalid video path");
    let mut child = std::process::Command::new("mpv")
        .args([
            video_str,
            "--fullscreen",
            "--loop-file=inf",
            &format!("--start={:.3}", seek_secs),
            &format!("--input-ipc-server={}", IPC_PATH),
            "--hwdec=auto",
            "--force-window",
            &format!("--title={}", APP_NAME),
            "--no-terminal",
            "--osc=no",
            "--no-osd-bar",
        ])
        .spawn()
        .expect("Failed to start mpv. Is 'mpv' installed?");
    info!("mpv spawned (PID {})", child.id());

    // --- Connect IPC streams ---
    // cmd_stream: for sending commands (seek, etc.)
    // poll_stream: for polling pause state
    let mut poll_stream = connect_ipc();
    let poll_reader = BufReader::new(poll_stream.try_clone().expect("Failed to clone poll stream"));
    let mut poll_reader = poll_reader;

    let cmd_stream = Arc::new(Mutex::new(connect_ipc()));
    info!("Connected to mpv IPC");

    // Read actual duration from mpv
    {
        let mut cmd = cmd_stream.lock().unwrap();
        mpv_send(&mut *cmd, &["get_property", "duration"]);
    }

    // --- Periodic NTP re-sync thread ---
    let state_resync = state.clone();
    let cmd_resync = cmd_stream.clone();
    std::thread::spawn(move || {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            loop {
                tokio::time::sleep(Duration::from_secs(ntp::RESYNC_INTERVAL_SECS)).await;
                let mut ntp = state_resync.ntp.lock().unwrap();
                ntp.sync().await;
                let dur = *state_resync.duration_micros.lock().unwrap();
                let seek_micros = ntp.seek_position(dur, false);
                let seek_secs = seek_micros as f64 / 1_000_000.0;
                info!("[periodic] offset={:.3}ms, seek_target={:.3}s", ntp.offset_micros as f64 / 1_000.0, seek_secs);
                drop(ntp);
                mpv_send(&mut *cmd_resync.lock().unwrap(), &["seek", &format!("{:.3}", seek_secs), "absolute"]);
                info!("[periodic] sent seek to mpv");
            }
        });
    });

    // --- Pause polling loop ---
    // Polls mpv's "pause" property every 200ms to detect Space key presses.
    // On unpause, re-syncs via NTP and seeks to correct position.
    let state_poll = state.clone();
    let cmd_poll = cmd_stream.clone();
    let mut was_paused = false;

    loop {
        std::thread::sleep(Duration::from_millis(200));

        // Send get_property pause on poll connection
        let cmd = format!("{}\n", serde_json::json!({"command": ["get_property", "pause"]}));
        if poll_stream.write_all(cmd.as_bytes()).is_err() {
            break; // mpv exited
        }

        // Read response
        let mut response = String::new();
        match poll_reader.read_line(&mut response) {
            Ok(0) | Err(_) => break,
            Ok(_) => {
                if let Ok(event) = serde_json::from_str::<Value>(&response) {
                    if let Some(paused) = event.get("data").and_then(|d| d.as_bool()) {
                        // Log state changes
                        if was_paused != paused {
                            info!("[state] pause: {} -> {}", was_paused, paused);
                        }

                        // Unpaused (Space pressed) — re-sync via NTP
                        if was_paused && !paused {
                            let ntp = state_poll.ntp.lock().unwrap();
                            let dur = *state_poll.duration_micros.lock().unwrap();
                            let seek_micros = ntp.seek_position(dur, false);
                            let seek_secs = seek_micros as f64 / 1_000_000.0;
                            info!("[re-sync] offset={:.3}ms, seek_target={:.3}s", ntp.offset_micros as f64 / 1_000.0, seek_secs);
                            drop(ntp);

                            mpv_send(
                                &mut *cmd_poll.lock().unwrap(),
                                &["seek", &format!("{:.3}", seek_secs), "absolute"],
                            );
                            info!("[re-sync] sent seek to mpv");
                        }

                        was_paused = paused;
                    }
                }
            }
        }
    }

    // mpv exited
    let status = child.wait().expect("Failed to wait for mpv");
    info!("mpv exited with status: {}", status);
    cleanup_ipc();
}
