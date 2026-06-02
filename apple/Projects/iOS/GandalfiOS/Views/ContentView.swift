import SwiftUI
import GandalfShared

struct ContentView: View {
    @StateObject private var viewModel = VideoViewModel()
    @AppStorage("theme_mode") private var themeMode: String = "system"
    @AppStorage("background_playback") private var backgroundPlayback = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isInitialized {
                VideoPlayerView(player: viewModel.player)
                    .ignoresSafeArea()
            }

            // Transparent tap overlay
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.pause()
                    Analytics.logOpenSheet()
                    showSettings = true
                }
        }
        .preferredColorScheme(resolvedTheme)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .sheet(isPresented: $showSettings, onDismiss: {
            viewModel.syncVideo()
        }) {
            SettingsView(
                syncSource: viewModel.syncSource,
                themeMode: Binding(
                    get: { themeMode },
                    set: { newMode in
                        themeMode = newMode
                        Analytics.logChangeTheme(mode: newMode)
                    }
                ),
                backgroundPlayback: Binding(
                    get: { backgroundPlayback },
                    set: { enabled in
                        backgroundPlayback = enabled
                        Analytics.logToggleBackgroundPlayback(enabled: enabled)
                    }
                )
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            Analytics.logViewHomeScreen()
        }
    }

    private var resolvedTheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system
        }
    }
}
