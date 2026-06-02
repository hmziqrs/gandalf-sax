use std::path::Path;
use std::sync::Arc;
use std::time::Duration;
use libmpv2::{
    Mpv,
    Format,
    events::{Event, PropertyData},
    rendering::{OpenGLInitParams, RenderContext, RenderParam, RenderParamApi},
};
use glow::HasContext;
use log::{debug, error, info};

/// Video duration in microseconds (117.54 seconds)
/// Read dynamically from the video file, but we cache it once known.
const DEFAULT_VIDEO_DURATION_MICROS: i64 = 117_540_000;

pub struct VideoPlayer {
    mpv: Mpv,
    pub duration_micros: i64,
    pub render_context: Option<RenderContext>,
}

impl VideoPlayer {
    pub fn new(video_path: &Path) -> Result<Self, String> {
        let mpv = Mpv::with_initializer(|init| {
            init.set_property("vo", "libmpv")?;
            init.set_property("loop-file", "inf")?;
            init.set_property("keep-open", true)?;
            init.set_property("hwdec", "auto")?;
            Ok(())
        }).map_err(|e| format!("Failed to create mpv: {}", e))?;

        let path_str = video_path.to_str().ok_or("Invalid video path")?;
        mpv.command("loadfile", &[path_str])
            .map_err(|e| format!("Failed to load video: {}", e))?;

        // Try to get duration
        let duration_micros = mpv
            .get_property::<f64>("duration")
            .map(|d| (d * 1_000_000.0) as i64)
            .unwrap_or(DEFAULT_VIDEO_DURATION_MICROS);

        info!("Video loaded: {}, duration={:.2}s", path_str, duration_micros as f64 / 1_000_000.0);

        Ok(Self {
            mpv,
            duration_micros,
            render_context: None,
        })
    }

    /// Initialize the OpenGL render context. Must be called after GL context is ready.
    pub fn init_render_context(&mut self, gl: &glow::Context, get_proc_address: impl FnMut(&str) -> *const std::ffi::c_void) -> Result<(), String> {
        let _ = gl; // We pass the get_proc_address to mpv directly
        let rc = unsafe {
            RenderContext::new(
                self.mpv.clone(),
                RenderParam {
                    api_type: RenderParamApi::OpenGL,
                    data: RenderParam::data(OpenGLInitParams {
                        get_proc_address: Box::new(get_proc_address),
                    }),
                },
            ).map_err(|e| format!("Failed to create render context: {}", e))?
        };
        self.render_context = Some(rc);
        Ok(())
    }

    /// Seek to the given position in seconds.
    pub fn seek_to(&self, position_secs: f64) {
        if let Err(e) = self.mpv.command("seek", &[&position_secs.to_string(), "absolute"]) {
            error!("Seek failed: {}", e);
        } else {
            debug!("Seeked to {:.3}s", position_secs);
        }
    }

    pub fn pause(&self) {
        let _ = self.mpv.set_property("pause", true);
    }

    pub fn play(&self) {
        let _ = self.mpv.set_property("pause", false);
    }

    pub fn mpv(&self) -> &Mpv {
        &self.mpv
    }
}
