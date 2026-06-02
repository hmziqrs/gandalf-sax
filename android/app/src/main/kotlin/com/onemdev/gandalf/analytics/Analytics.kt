package com.onemdev.gandalf.analytics

import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.ktx.Firebase

/**
 * Analytics wrapper matching legacy events.
 * Events: view_home_screen, open_sheet, share_content, change_theme,
 *         toggle_background_playback, click_social_link
 */
object Analytics {

    private val firebase: FirebaseAnalytics by lazy { Firebase.analytics }

    fun logScreenView(screenName: String) {
        firebase.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, Bundle().apply {
            putString(FirebaseAnalytics.Param.SCREEN_NAME, screenName)
        })
    }

    fun logViewHomeScreen() {
        firebase.logEvent("view_home_screen", null)
    }

    fun logOpenSheet() {
        firebase.logEvent("open_sheet", null)
    }

    fun logShareContent() {
        firebase.logEvent("share_content", null)
    }

    fun logChangeTheme(mode: String) {
        firebase.logEvent("change_theme", Bundle().apply {
            putString("theme_mode", mode)
        })
    }

    fun logToggleBackgroundPlayback(enabled: Boolean) {
        firebase.logEvent("toggle_background_playback", Bundle().apply {
            putBoolean("enabled", enabled)
        })
    }

    fun logClickSocialLink(platform: String, url: String) {
        firebase.logEvent("click_social_link", Bundle().apply {
            putString("platform", platform)
            putString("url", url)
        })
    }
}
