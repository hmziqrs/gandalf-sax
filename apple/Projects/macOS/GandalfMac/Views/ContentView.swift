import SwiftUI
import GandalfShared

struct ContentView: View {
    @StateObject private var viewModel = VideoViewModel()
    @AppStorage("theme_mode") private var themeMode: String = "system"
    @State private var showSettings = false
    @State private var isFullscreen = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isInitialized {
                VideoPlayerView(player: viewModel.player)
                    .ignoresSafeArea()
            }

            // Transparent click overlay
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.pause()
                    MacAnalytics.logOpenSheet()
                    showSettings = true
                }

            // Fullscreen toggle hint
            if !isFullscreen {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Press F for fullscreen · Click for settings")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .padding(8)
                    }
                }
            }
        }
        .preferredColorScheme(resolvedTheme)
        .sheet(isPresented: $showSettings, onDismiss: {
            viewModel.syncVideo()
        }) {
            SettingsView(
                syncSource: viewModel.syncSource,
                themeMode: Binding(
                    get: { themeMode },
                    set: { newMode in
                        themeMode = newMode
                        MacAnalytics.logChangeTheme(mode: newMode)
                    }
                )
            )
            .frame(width: 400)
        }
        .onAppear {
            MacAnalytics.logViewHomeScreen()
            viewModel.initialize()
        }
        .onKeyPress(KeyEquivalent("f")) {
            toggleFullscreen()
            return .handled
        }
        .onKeyPress(.escape) {
            if isFullscreen {
                toggleFullscreen()
                return .handled
            }
            return .ignored
        }
    }

    private var resolvedTheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private func toggleFullscreen() {
        if let window = NSApp.keyWindow {
            window.toggleFullScreen(nil)
            isFullscreen.toggle()
        }
    }
}
