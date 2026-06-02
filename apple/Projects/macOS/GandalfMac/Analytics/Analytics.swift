import Foundation

/// Analytics stubs — will be replaced with Firebase Analytics once integrated
enum MacAnalytics {
    static func logViewHomeScreen() {
        print("[Analytics] view_home_screen")
    }

    static func logOpenSheet() {
        print("[Analytics] open_sheet")
    }

    static func logChangeTheme(mode: String) {
        print("[Analytics] change_theme: \(mode)")
    }

    static func logClickSocialLink(platform: String, url: String) {
        print("[Analytics] click_social_link: \(platform) \(url)")
    }

    static func logToggleBackgroundPlayback(enabled: Bool) {
        print("[Analytics] toggle_background_playback: \(enabled)")
    }
}
