import FirebaseAnalytics

/// Analytics wrapper matching legacy events.
enum Analytics {
    static func logViewHomeScreen() {
        Analytics.logEvent("view_home_screen", parameters: nil)
    }

    static func logOpenSheet() {
        Analytics.logEvent("open_sheet", parameters: nil)
    }

    static func logShareContent() {
        Analytics.logEvent("share_content", parameters: nil)
    }

    static func logChangeTheme(mode: String) {
        Analytics.logEvent("change_theme", parameters: ["theme_mode": mode])
    }

    static func logToggleBackgroundPlayback(enabled: Bool) {
        Analytics.logEvent("toggle_background_playback", parameters: ["enabled": enabled])
    }

    static func logClickSocialLink(platform: String, url: String) {
        Analytics.logEvent("click_social_link", parameters: ["platform": platform, "url": url])
    }
}
