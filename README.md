# 🎷 Epic Sax Gandalf Infinite

Glorious Gandalf sax — now **NTP-synced to millisecond precision**. Every device on every platform plays the exact same frame at the same time.

## 📲 Download

<div id="downloads">
  <a href="https://play.google.com/store/apps/details?id=com.onemdev.gandalf">
    <img src="https://raw.githubusercontent.com/hmziqrs/gandalf-sax/master/.github/assets/google-play.png" alt="Play Store badge" width="200" />
  </a>
  <a href="https://github.com/hmziqrs/gandalf-sax/releases/latest/download/app-release.apk">
    <img src="https://raw.githubusercontent.com/hmziqrs/gandalf-sax/master/.github/assets/android.png" alt="Android badge" width="200" />
  </a>
  <a href="https://github.com/hmziqrs/gandalf-sax/releases/latest/download/windows-release.zip">
    <img src="https://raw.githubusercontent.com/hmziqrs/gandalf-sax/master/.github/assets/windows.png" alt="Windows badge" width="200" />
  </a>
  <a href="https://github.com/hmziqrs/gandalf-sax/releases/latest/download/macos-release.zip">
    <img src="https://raw.githubusercontent.com/hmziqrs/gandalf-sax/master/.github/assets/macos.png" alt="MacOS badge"  width="200" />
  </a>
  <a href="https://github.com/hmziqrs/gandalf-sax/releases/latest/download/linux-release.zip">
    <img src="https://raw.githubusercontent.com/hmziqrs/gandalf-sax/master/.github/assets/linux.png" alt="Linux badge"  width="200"/>
  </a>
</div>


## ✨ Features

- ⏱️ **NTP time sync** — all devices play the same frame at the same time (millisecond precision)
- 🔄 Perfect seamless loop
- 📱 **Native first-party** implementations per platform
- 🌐 Firebase Analytics + Crashlytics (mobile)
- 📺 Hardware-accelerated video playback

## 🖥️ Supported Platforms

| Platform | Stack | Video Engine |
|----------|-------|-------------|
| 🤖 Android | Kotlin + Jetpack Compose | Media3 / ExoPlayer |
| 🍎 iOS | Swift + SwiftUI | AVPlayer |
| 🍏 macOS | Swift + SwiftUI | AVPlayer |
| 🪟 Windows | Rust + egui | libmpv |
| 🐧 Linux | Rust + egui | libmpv |

## 🛠️ Building

### Android
```bash
cd android
./gradlew assembleDebug
```

### iOS / macOS
Open `apple/Projects/iOS/` or `apple/Projects/macOS/` in Xcode. Build & run.

### Windows / Linux (Rust)
```bash
cd rust

# Linux: install system dependency
sudo apt install libmpv-dev mpv libgl-dev libx11-dev

# Build
cargo build --release
```

## 📁 Project Structure

```
gandalf-sax/
  assets/video.mp4          # Single source of truth (~11MB)
  assets/icons/             # Source icons (1024x1024)
  android/                  # Kotlin / Gradle project
  apple/
    Sources/GandalfSync/    # Shared Swift Package (NTP client)
    Projects/iOS/           # iOS Xcode project
    Projects/macOS/         # macOS Xcode project
  rust/                     # Cargo project (Windows + Linux)
  legacy/                   # Previous Flutter implementation
```

## ⏱️ How Time Sync Works

Every device computes: `seekPosition = (correctedTime % videoDuration) + buffer`

Where `correctedTime = deviceTime + ntpOffset`. NTP offset is computed by querying 4 time servers and taking the median. Re-syncs every 60 seconds.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## ⭐ Show Your Support

If you found this project helpful or learned something from it, consider:

- Starring the repository
- Following me on GitHub and X


## 🔗 Connect With Me

### Social Links

- 𝕏 (Twitter): [@hmziqrs](https://x.com/hmziqrs)
- Telegram: [@hmziqrs](https://t.me/hmziqrs)

### Personal Website

🌐 Visit my personal site [hmziq.rs](https://hmziq.rs/)

## 🌟 More Open Source Projects

- [Movie Concept App](https://github.com/hmziqrs/invmovieconcept1) - An innovative movie browsing experience built with Flutter
- [React Native Loop Game](https://github.com/hmziqrs/react-native-loop-game) - An engaging mobile game created with React Native
- [CV Template](https://github.com/hmziqrs/cv) - A modern, customizable CV/resume template
