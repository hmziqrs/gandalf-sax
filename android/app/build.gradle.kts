import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("com.google.firebase.firebase-perf")
}

val devProps = Properties().apply {
    val f = rootProject.file("dev.properties")
    if (f.exists()) load(f.inputStream())
}

val prodProps = Properties().apply {
    val f = rootProject.file("prod.properties")
    if (f.exists()) load(f.inputStream())
}

android {
    namespace = "com.onemdev.gandalf"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.onemdev.gandalf"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "4.0.0"
        multiDexEnabled = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    signingConfigs {
        getByName("debug") {
            devProps["keyAlias"]?.let { keyAlias = it as String }
            devProps["keyPassword"]?.let { keyPassword = it as String }
            devProps["storeFile"]?.let { storeFile = rootProject.file(it as String) }
            devProps["storePassword"]?.let { storePassword = it as String }
        }
        create("release") {
            prodProps["keyAlias"]?.let { keyAlias = it as String }
            prodProps["keyPassword"]?.let { keyPassword = it as String }
            prodProps["storeFile"]?.let { storeFile = rootProject.file(it as String) }
            prodProps["storePassword"]?.let { storePassword = it as String }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.activity:activity-compose:1.9.3")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")

    // Media3 / ExoPlayer
    implementation("androidx.media3:media3-exoplayer:1.5.1")
    implementation("androidx.media3:media3-ui:1.5.1")
    implementation("androidx.media3:media3-common:1.5.1")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
    implementation("com.google.firebase:firebase-perf")
    implementation("com.google.firebase:firebase-messaging")

    // Google AdMob
    implementation("com.google.android.gms:play-services-ads:23.6.0")

    // DataStore (replaces SharedPreferences)
    implementation("androidx.datastore:datastore-preferences:1.1.1")
}
