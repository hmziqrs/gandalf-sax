mod ntp;

use std::io::{BufRead, BufReader, Write};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use log::{error, info};
use serde_json::Value;

use ntp::NtpClient;

const APP_NAME: &str = "Epic Sax Gandalf";
const SOCKET_PATH: &str = "/tmp/gandalf-sax-mpv.sock";

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

/// Wait for mpv's IPC socket to appear, then connect.
fn connect_ipc() -> std::os::unix::net::UnixStream {
    let timeout = std::time::Instant::now() + Duration::from_secs(5);
    loop {
        if let Ok(stream) = std::os::unix::net::UnixStream::connect(SOCKET_PATH) {
            return stream;
        }
        if std::time::Instant::now() > timeout {
            panic!("Timed out waiting for mpv IPC socket at {}", SOCKET_PATH);
        }
        std::thread::sleep(Duration::from_millis(50));
    }
}

/// Send a command to mpv via JSON IPC. Returns the response data field.
fn mpv_command(stream: &mut std::os::unix::net::UnixStream, args: &[&str]) -> Option<Value> {
    let cmd = serde_json::json!({ "command": args });
    let line = format!("{}\n", cmd);
    if let Err(e) = stream.write_all(line.as_bytes()) {
        error!("IPC write error: {}", e);
        return None;
    }

    // Read response
    let mut reader = BufReader::new(stream.try_clone().ok()?);
    let mut response = String::new();
    if reader.read_line(&mut response).ok()? == 0 {
        return None;
    }

    serde_json::from_str::<Value>(&response).ok()
}

/// Get a property from mpv via JSON IPC.
fn mpv_get_property(stream: &mut std::os::unix::net::UnixStream, property: &str) -> Option<f64> {
    let resp = mpv_command(stream, &["get_property", property])?;
    resp.get("data").and_then(|d| d.as_f64())
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

fn main() {
    env_logger::init();
    info!("Starting {} v4.0.0", APP_NAME);

    let video_path = find_video_path();
    info!("Video path: {:?}", video_path);

    // NTP sync (blocking)
    let ntp = Arc::new(Mutex::new(NtpClient::new()));
    info!("Syncing NTP...");
    {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            ntp.lock().unwrap().sync().await;
        });
    }

    // Calculate initial seek position
    const DEFAULT_DURATION_MICROS: i64 = 117_540_000;
    let ntp_guard = ntp.lock().unwrap();
    let seek_micros = ntp_guard.seek_position(DEFAULT_DURATION_MICROS, true);
    let seek_secs = seek_micros as f64 / 1_000_000.0;
    drop(ntp_guard);
    info!("Initial seek position: {:.3}s", seek_secs);

    // Clean up stale socket
    let _ = std::fs::remove_file(SOCKET_PATH);

    // Spawn mpv as a subprocess — it handles its own window natively
    let video_str = video_path.to_str().expect("Invalid video path");
    let mut child = std::process::Command::new("mpv")
        .args([
            video_str,
            "--fullscreen",
            "--loop-file=inf",
            &format!("--start={:.3}", seek_secs),
            &format!("--input-ipc-server={}", SOCKET_PATH),
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

    // Connect to mpv's IPC socket
    let mut ipc_stream = connect_ipc();
    info!("Connected to mpv IPC");

    // Read actual duration from mpv
    let duration_micros = mpv_get_property(&mut ipc_stream, "duration")
        .map(|d| (d * 1_000_000.0) as i64)
        .unwrap_or(DEFAULT_DURATION_MICROS);
    info!("Video duration: {:.2}s", duration_micros as f64 / 1_000_000.0);

    // Periodic NTP re-sync
    let ntp_resync = ntp.clone();
    let ipc_resync = ipc_stream.try_clone().expect("Failed to clone IPC stream");
    std::thread::spawn(move || {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            loop {
                tokio::time::sleep(Duration::from_secs(ntp::RESYNC_INTERVAL_SECS)).await;
                {
                    let mut ntp = ntp_resync.lock().unwrap();
                    ntp.sync().await;
                    info!("Periodic NTP re-sync done");

                    let seek_micros = ntp.seek_position(duration_micros, false);
                    let seek_secs = seek_micros as f64 / 1_000_000.0;
                    let mut stream = ipc_resync.try_clone().unwrap();
                    let cmd = serde_json::json!({ "command": ["seek", seek_secs, "absolute"] });
                    let _ = stream.write_all(format!("{}\n", cmd).as_bytes());
                    info!("Re-synced to {:.3}s", seek_secs);
                }
            }
        });
    });

    // Wait for mpv to exit
    let status = child.wait().expect("Failed to wait for mpv");
    info!("mpv exited with status: {}", status);

    // Clean up socket
    let _ = std::fs::remove_file(SOCKET_PATH);
}
