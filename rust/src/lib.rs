mod ntp;

use std::sync::{Arc, Mutex, OnceLock};

use log::info;
use serde::Serialize;
use tauri::http;
use tauri::Manager;

use ntp::NtpClient;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

pub struct AppState {
    ntp: Mutex<NtpClient>,
}

// ---------------------------------------------------------------------------
// One command: sync NTP and return everything. Called once by JS at init.
// Window appears instantly — no blocking in setup().
// ---------------------------------------------------------------------------

#[derive(Serialize)]
pub struct NtpState {
    offset_micros: i64,
    is_synced: bool,
}

#[tauri::command]
fn sync_ntp(state: tauri::State<AppState>) -> Result<NtpState, String> {
    let mut ntp = state.ntp.lock().map_err(|e| e.to_string())?;
    ntp.sync();
    Ok(NtpState {
        offset_micros: ntp.offset_micros,
        is_synced: ntp.is_synced,
    })
}

// ---------------------------------------------------------------------------
// Open URL in system browser
// ---------------------------------------------------------------------------

#[tauri::command]
fn open_url(url: String) -> Result<(), String> {
    use std::process::Command;
    let result = {
        #[cfg(target_os = "macos")]
        { Command::new("open").arg(&url).spawn() }
        // Empty title ("") so `start` doesn't treat a quoted URL as the title,
        // and survives URLs containing spaces or '&' on the cmd command line.
        #[cfg(target_os = "windows")]
        { Command::new("cmd").args(["/c", "start", "", &url]).spawn() }
        #[cfg(target_os = "linux")]
        { Command::new("xdg-open").arg(&url).spawn() }
        #[cfg(not(any(target_os = "macos", target_os = "windows", target_os = "linux")))]
        { return Err("unsupported platform".into()); }
    };
    if let Err(e) = result {
        log::warn!("open_url failed for {url}: {e}");
        return Err(e.to_string());
    }
    Ok(())
}

// ---------------------------------------------------------------------------
// Copy text to system clipboard
// ---------------------------------------------------------------------------

#[tauri::command]
fn copy_to_clipboard(text: String) -> Result<(), String> {
    // Spawn a clipboard helper, pipe `text` to its stdin, and wait for it.
    fn pipe_to(prog: &str, args: &[&str], text: &str) -> Result<(), String> {
        use std::io::Write;
        use std::process::{Command, Stdio};
        let mut child = Command::new(prog)
            .args(args)
            .stdin(Stdio::piped())
            .spawn()
            .map_err(|e| format!("{prog}: {e}"))?;
        if let Some(mut stdin) = child.stdin.take() {
            stdin.write_all(text.as_bytes()).map_err(|e| e.to_string())?;
        }
        child.wait().map_err(|e| e.to_string())?;
        Ok(())
    }

    #[cfg(target_os = "macos")]
    { return pipe_to("pbcopy", &[], &text); }

    #[cfg(target_os = "windows")]
    { return pipe_to("cmd", &["/c", "clip"], &text); }

    #[cfg(target_os = "linux")]
    {
        // Prefer xclip (X11); fall back to wl-copy (Wayland).
        if pipe_to("xclip", &["-selection", "clipboard"], &text).is_ok() {
            return Ok(());
        }
        return pipe_to("wl-copy", &[], &text);
    }

    #[cfg(not(any(target_os = "macos", target_os = "windows", target_os = "linux")))]
    { Err("clipboard not supported on this platform".into()) }
}

// ---------------------------------------------------------------------------
// App entry
// ---------------------------------------------------------------------------

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    env_logger::init();
    info!("Starting Epic Sax Gandalf v5.0.0");

    // The video is loaded once at startup (resolved through Tauri's resource
    // API, so it works in dev AND in a bundled .app/.exe/AppImage) and then
    // served from memory. Kept out of the binary because an 11 MB
    // `include_bytes!` makes debuginfo emission pathologically slow to compile.
    let video_cache: Arc<OnceLock<Vec<u8>>> = Arc::new(OnceLock::new());
    let video_for_setup = video_cache.clone();

    tauri::Builder::default()
        .manage(AppState {
            ntp: Mutex::new(NtpClient::new()),
        })
        .setup(move |app| {
            // Resolve the bundled resource path first; fall back to the source
            // tree (assets/video.mp4) for `cargo run` outside `cargo tauri dev`.
            let resource = app
                .path()
                .resolve("video.mp4", tauri::path::BaseDirectory::Resource)
                .ok();
            let dev_fallback =
                std::env::current_dir().ok().map(|d| d.join("assets/video.mp4"));
            let video_path = resource.into_iter().chain(dev_fallback).find(|p| p.exists());

            match video_path {
                Some(path) => match std::fs::read(&path) {
                    Ok(bytes) => {
                        info!("Loaded video: {} bytes from {}", bytes.len(), path.display());
                        let _ = video_for_setup.set(bytes);
                    }
                    Err(e) => log::error!("Failed to read video at {}: {e}", path.display()),
                },
                None => log::error!("Could not locate video.mp4 in resources or assets/"),
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![sync_ntp, open_url, copy_to_clipboard])
        .register_uri_scheme_protocol("gandalf", move |_app, request| {
            // Only serve video.mp4 — reject anything else (favicon.ico, etc.)
            let path = request.uri().path();
            if !path.ends_with("video.mp4") {
                return http::Response::builder()
                    .status(http::StatusCode::NOT_FOUND)
                    .body(b"not found".to_vec())
                    .unwrap();
            }

            let data = match video_cache.get() {
                Some(d) => d,
                None => {
                    return http::Response::builder()
                        .status(http::StatusCode::SERVICE_UNAVAILABLE)
                        .body(b"video not ready".to_vec())
                        .unwrap();
                }
            };
            let total = data.len();

            let range_header = request
                .headers()
                .get("range")
                .and_then(|v| v.to_str().ok())
                .and_then(|v| v.strip_prefix("bytes="));

            let (start, end) = match range_header {
                Some(range) => {
                    let mut parts = range.split('-');
                    let start = parts.next().and_then(|s| s.parse::<usize>().ok()).unwrap_or(0);
                    let end = parts
                        .next()
                        .and_then(|s| s.parse::<usize>().ok())
                        .unwrap_or(total - 1);
                    (start.min(total), end.min(total - 1))
                }
                None => (0, total - 1),
            };

            let body = data[start..=end].to_vec();
            let content_len = body.len();

            http::Response::builder()
                .status(if range_header.is_some() {
                    http::StatusCode::PARTIAL_CONTENT
                } else {
                    http::StatusCode::OK
                })
                .header(http::header::CONTENT_TYPE, "video/mp4")
                .header(http::header::CONTENT_LENGTH, content_len)
                .header("Accept-Ranges", "bytes")
                .header("Content-Range", format!("bytes {start}-{end}/{total}"))
                .header("Cache-Control", "no-cache")
                .body(body)
                .unwrap()
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
