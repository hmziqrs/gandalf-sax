package com.onemdev.gandalf

import android.app.Application
import com.google.android.gms.ads.MobileAds
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.ktx.Firebase
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.perf.FirebasePerformance

class GandalfApp : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize Firebase
        Firebase.analytics
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(true)
        FirebasePerformance.getInstance().isPerformanceCollectionEnabled = true

        // Initialize AdMob (non-blocking)
        MobileAds.initialize(this)
    }
}
