mod ntp;
mod video;
mod ui;

use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use log::{error, info};
use winit::{
    application::ApplicationHandler,
    event::{ElementState, KeyEvent, WindowEvent},
    event_loop::{ActiveEventLoop, EventLoop},
    window::{Window, WindowAttributes},
};
use raw_window_handle::HasWindowHandle;

use ntp::NtpClient;
use video::VideoPlayer;
use ui::SettingsUi;

const APP_NAME: &str = "Epic Sax Gandalf";

struct AppState {
    ntp: Arc<Mutex<NtpClient>>,
    player: Arc<Mutex<Option<VideoPlayer>>>,
    settings: Arc<Mutex<SettingsUi>>,
    is_first_sync: bool,
    video_duration_micros: i64,
}

impl AppState {
    fn new() -> Self {
        Self {
            ntp: Arc::new(Mutex::new(NtpClient::new())),
            player: Arc::new(Mutex::new(None)),
            settings: Arc::new(Mutex::new(SettingsUi::new())),
            is_first_sync: true,
            video_duration_micros: 117_540_000, // will be updated from video
        }
    }
}

fn find_video_path() -> PathBuf {
    // Try multiple locations
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
    PathBuf::from("assets/video.mp4") // fallback
}

fn main() {
    env_logger::init();
    info!("Starting {} v4.0.0", APP_NAME);

    let video_path = find_video_path();
    info!("Video path: {:?}", video_path);

    let state = Arc::new(Mutex::new(AppState::new()));

    // Initial NTP sync (blocking, with timeout)
    let ntp_clone = state.lock().unwrap().ntp.clone();
    std::thread::spawn(move || {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            let mut ntp = ntp_clone.lock().unwrap();
            ntp.sync().await;
            info!("Initial NTP sync done");
        });
    });

    // Create the video player
    match VideoPlayer::new(&video_path) {
        Ok(player) => {
            let mut s = state.lock().unwrap();
            s.video_duration_micros = player.duration_micros;
            *s.player.lock().unwrap() = Some(player);
        }
        Err(e) => {
            error!("Failed to create video player: {}", e);
            error!("Make sure libmpv is installed (Linux: libmpv-dev, Windows: mpv-2.dll)");
            std::process::exit(1);
        }
    }

    // Perform initial seek based on NTP
    {
        let s = state.lock().unwrap();
        let ntp = s.ntp.lock().unwrap();
        let player_guard = s.player.lock().unwrap();
        if let Some(ref player) = *player_guard {
            let seek_micros = ntp.seek_position(s.video_duration_micros, true);
            let seek_secs = seek_micros as f64 / 1_000_000.0;
            player.seek_to(seek_secs);
            player.play();
            info!("Initial seek to {:.3}s", seek_secs);
        }
    }

    // Set up the winit event loop
    let event_loop = EventLoop::new().expect("Failed to create event loop");

    let mut app_handler = GandalfApp {
        state,
        window: None,
        egui_state: None,
        gl: None,
    };

    event_loop.run_app(&mut app_handler).expect("Event loop error");
}

struct GandalfApp {
    state: Arc<Mutex<AppState>>,
    window: Option<Window>,
    egui_state: Option<egui_winit::State>,
    gl: Option<Arc<glow::Context>>,
}

impl ApplicationHandler for GandalfApp {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_some() {
            return;
        }

        let attrs = WindowAttributes::default()
            .with_title(APP_NAME)
            .with_fullscreen(Some(winit::window::Fullscreen::Borderless(None)))
            .with_inner_size(winit::dpi::LogicalSize::new(1280, 720));

        let window = event_loop.create_window(attrs).expect("Failed to create window");
        let window = Arc::new(window);

        // Create OpenGL context via glow
        let gl = unsafe {
            let gl_ctx = glow::Context::from_loader_function(|proc_name| {
                // This would need a proper GL loading mechanism
                // For now, this is a placeholder
                std::ptr::null()
            });
            Arc::new(gl_ctx)
        };

        // Set up egui
        let egui_state = egui_winit::State::new(
            egui::ViewportId::ROOT,
            window.as_ref(),
            event_loop,
            None,
            None,
        );

        self.window = Some(Arc::into_inner(window).unwrap());
        self.egui_state = Some(egui_state);
        self.gl = Some(gl);
    }

    fn window_event(
        &mut self,
        event_loop: &ActiveEventLoop,
        window_id: winit::window::WindowId,
        event: WindowEvent,
    ) {
        match event {
            WindowEvent::CloseRequested => {
                event_loop.exit();
            }
            WindowEvent::MouseInput { state: ElementState::Pressed, .. } => {
                let mut s = self.state.lock().unwrap();
                let settings = &mut s.settings.lock().unwrap();
                settings.visible = !settings.visible;

                if settings.visible {
                    let player_guard = s.player.lock().unwrap();
                    if let Some(ref player) = *player_guard {
                        player.pause();
                    }
                } else {
                    // Re-sync on close
                    let ntp = s.ntp.lock().unwrap();
                    let player_guard = s.player.lock().unwrap();
                    if let Some(ref player) = *player_guard {
                        let seek_micros = ntp.seek_position(s.video_duration_micros, false);
                        player.seek_to(seek_micros as f64 / 1_000_000.0);
                        player.play();
                    }
                }
            }
            WindowEvent::Key(KeyEvent { logical_key, state: ElementState::Pressed, .. }) => {
                match logical_key {
                    winit::keyboard::Key::Character(c) if c == "f" => {
                        if let Some(ref window) = self.window {
                            if window.fullscreen().is_some() {
                                window.set_fullscreen(None);
                            } else {
                                window.set_fullscreen(Some(winit::window::Fullscreen::Borderless(None)));
                            }
                        }
                    }
                    winit::keyboard::Key::Escape => {
                        if let Some(ref window) = self.window {
                            window.set_fullscreen(None);
                        }
                    }
                    _ => {}
                }
            }
            WindowEvent::Resized(size) => {
                if let (Some(ref mut egui_state), Some(ref window)) = (&mut self.egui_state, &self.window) {
                    egui_state.on_window_event(window, &WindowEvent::Resized(size));
                }
            }
            _ => {}
        }
    }
}
