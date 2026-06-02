use egui::{Color32, RichText, Vec2};
use crate::ntp::NtpClient;

/// Settings overlay state
pub struct SettingsUi {
    pub visible: bool,
    pub theme_mode: String, // "light", "dark", "system"
    pub sync_source: String, // "NTP synced", "Device time"
}

impl SettingsUi {
    pub fn new() -> Self {
        Self {
            visible: false,
            theme_mode: "system".to_string(),
            sync_source: "Device time".to_string(),
        }
    }

    /// Draw the settings panel as an egui window
    pub fn draw(&mut self, ctx: &egui::Context) {
        if !self.visible {
            return;
        }

        let mut visible = self.visible;
        egui::Window::new("Settings")
            .open(&mut visible)
            .default_size(Vec2::new(350.0, 400.0))
            .resizable(false)
            .show(ctx, |ui| {
                // Sync status
                ui.horizontal(|ui| {
                    let color = if self.sync_source.contains("NTP") {
                        Color32::GREEN
                    } else {
                        Color32::GRAY
                    };
                    ui.colored_label(color, "⏱");
                    ui.label(RichText::new(&self.sync_source).small().color(Color32::GRAY));
                });

                ui.add_space(8.0);

                // Header
                ui.heading("Behold the glory of infinite Gandalf!");
                ui.colored_label(
                    Color32::from_rgb(229, 57, 53),
                    RichText::new("Billions must be entertained!").small(),
                );

                ui.separator();

                // Theme
                ui.label(RichText::new("Theme").strong());
                ui.horizontal(|ui| {
                    for (label, mode) in [("☀ Light", "light"), ("🌙 Dark", "dark"), ("⚙ System", "system")] {
                        let is_selected = self.theme_mode == mode;
                        if ui.selectable_label(is_selected, label).clicked() {
                            self.theme_mode = mode.to_string();
                        }
                    }
                });

                ui.separator();

                // Developer
                ui.label(RichText::new("Developer: hmziqrs").strong());
                ui.horizontal_wrapped(|ui| {
                    ui.hyperlink_to("🌐 hmziq.rs", "https://hmziq.rs");
                    ui.hyperlink_to("GitHub", "https://github.com/hmziqrs");
                    ui.hyperlink_to("X", "https://x.com/hmziqrs");
                    ui.hyperlink_to("Telegram", "https://t.me/hmziqrs");
                });

                ui.separator();

                // Video source
                ui.label(RichText::new("Video source:").strong());
                ui.hyperlink_to("▶ Original video", "https://youtu.be/BBGEG21CGo0");
            });
        self.visible = visible;
    }
}
