mod ntp;

use std::sync::{Arc, Mutex};

use log::info;
use serde::Serialize;
use tauri::http;

use ntp::NtpClient;

const VIDEO_DURATION_MICROS: i64 = 117_540_000; // 117.54 seconds

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
    video_duration_micros: i64,
}

#[tauri::command]
fn sync_ntp(state: tauri::State<AppState>) -> Result<NtpState, String> {
    let mut ntp = state.ntp.lock().map_err(|e| e.to_string())?;
    ntp.sync();
    Ok(NtpState {
        offset_micros: ntp.offset_micros,
        is_synced: ntp.is_synced,
        video_duration_micros: VIDEO_DURATION_MICROS,
    })
}

// ---------------------------------------------------------------------------
// Open URL in system browser
// ---------------------------------------------------------------------------

#[tauri::command]
fn open_url(url: String) {
    #[cfg(target_os = "macos")]
    let _ = std::process::Command::new("open").arg(&url).spawn();
    #[cfg(target_os = "windows")]
    let _ = std::process::Command::new("cmd").args(["/c", "start", &url]).spawn();
    #[cfg(target_os = "linux")]
    let _ = std::process::Command::new("xdg-open").arg(&url).spawn();
}

// ---------------------------------------------------------------------------
// Copy text to system clipboard
// ---------------------------------------------------------------------------

#[tauri::command]
fn copy_to_clipboard(text: String) -> Result<(), String> {
    use std::io::Write;

    #[cfg(target_os = "macos")]
    let mut child = std::process::Command::new("pbcopy")
        .stdin(std::process::Stdio::piped())
        .spawn()
        .map_err(|e| e.to_string())?;

    #[cfg(target_os = "windows")]
    let mut child = std::process::Command::new("cmd")
        .args(["/c", "clip"])
        .stdin(std::process::Stdio::piped())
        .spawn()
        .map_err(|e| e.to_string())?;

    #[cfg(target_os = "linux")]
    let mut child = std::process::Command::new("xclip")
        .args(["-selection", "clipboard"])
        .stdin(std::process::Stdio::piped())
        .spawn()
        .map_err(|e| e.to_string())?;

    child
        .stdin
        .take()
        .unwrap()
        .write_all(text.as_bytes())
        .map_err(|e| e.to_string())?;

    child.wait().map_err(|e| e.to_string())?;
    Ok(())
}

// ---------------------------------------------------------------------------
// App entry
// ---------------------------------------------------------------------------

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    env_logger::init();
    info!("Starting Epic Sax Gandalf v5.0.0");

    // Pre-load video into memory so the protocol handler serves it instantly
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap_or_else(|_| ".".into());
    let video_path = std::path::Path::new(&manifest_dir).join("assets/video.mp4");
    let video_data = Arc::new(std::fs::read(&video_path).unwrap_or_else(|e| {
        panic!("Failed to read video at {:?}: {e}", video_path);
    }));
    info!("Loaded video: {} bytes", video_data.len());

    tauri::Builder::default()
        .manage(AppState {
            ntp: Mutex::new(NtpClient::new()),
        })
        .invoke_handler(tauri::generate_handler![sync_ntp, open_url, copy_to_clipboard])
        .register_uri_scheme_protocol("gandalf", move |_ctx, request| {
            // Only serve video.mp4 — reject anything else (favicon.ico, etc.)
            let path = request.uri().path();
            if !path.ends_with("video.mp4") {
                return http::Response::builder()
                    .status(http::StatusCode::NOT_FOUND)
                    .body(b"not found".to_vec())
                    .unwrap();
            }

            let data = &*video_data;
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
