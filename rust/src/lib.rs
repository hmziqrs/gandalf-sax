mod ntp;

use std::sync::{Arc, Mutex};

use log::info;
use serde::Serialize;
use tauri::http;
use tauri::Manager;

use ntp::NtpClient;

const VIDEO_DURATION_MICROS: i64 = 117_540_000; // 117.54 seconds

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

pub struct AppState {
    ntp: Mutex<NtpClient>,
}

// ---------------------------------------------------------------------------
// Response types
// ---------------------------------------------------------------------------

#[derive(Serialize)]
pub struct SeekResult {
    seek_secs: f64,
    offset_micros: i64,
    is_synced: bool,
}

#[derive(Serialize)]
pub struct NtpStatus {
    offset_micros: i64,
    is_synced: bool,
}

// ---------------------------------------------------------------------------
// Tauri commands
// ---------------------------------------------------------------------------

#[tauri::command]
fn get_seek_position(state: tauri::State<AppState>, is_first_sync: bool) -> SeekResult {
    let ntp = state.ntp.lock().unwrap();
    let seek_micros = ntp.seek_position(VIDEO_DURATION_MICROS, is_first_sync);
    SeekResult {
        seek_secs: seek_micros as f64 / 1_000_000.0,
        offset_micros: ntp.offset_micros,
        is_synced: ntp.is_synced,
    }
}

#[tauri::command]
fn sync_ntp(state: tauri::State<AppState>) -> Result<i64, String> {
    let mut ntp = state.ntp.lock().map_err(|e| e.to_string())?;
    let rt = tokio::runtime::Runtime::new().unwrap();
    Ok(rt.block_on(ntp.sync()))
}

#[tauri::command]
fn get_ntp_status(state: tauri::State<AppState>) -> NtpStatus {
    let ntp = state.ntp.lock().unwrap();
    NtpStatus {
        offset_micros: ntp.offset_micros,
        is_synced: ntp.is_synced,
    }
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
        .invoke_handler(tauri::generate_handler![
            get_seek_position,
            sync_ntp,
            get_ntp_status,
        ])
        .register_uri_scheme_protocol("gandalf", move |_ctx, request| {
            let data = &*video_data;
            let total = data.len();

            // Parse Range header for video seeking
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
                .header(
                    "Content-Range",
                    format!("bytes {start}-{end}/{total}"),
                )
                .header("Cache-Control", "no-cache")
                .body(body)
                .unwrap()
        })
        .setup(|app| {
            // Initial NTP sync (blocks briefly, ~2s)
            let state = app.state::<AppState>();
            {
                let rt = tokio::runtime::Runtime::new().unwrap();
                rt.block_on(async {
                    state.ntp.lock().unwrap().sync().await;
                });
            }
            info!(
                "NTP offset: {:.3}ms",
                state.ntp.lock().unwrap().offset_micros as f64 / 1_000.0
            );

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
