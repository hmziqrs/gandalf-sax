import SwiftUI
import GandalfShared

struct SettingsView: View {
    let syncSource: NtpClient.SyncSource
    @Binding var themeMode: String
    @Binding var backgroundPlayback: Bool

    private let youtubeLink = "https://youtu.be/BBGEG21CGo0"
    private let user = "hmziqrs"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Sync status
                    HStack {
                        Image(systemName: "sync")
                            .foregroundStyle(syncSource == .ntp ? .green : .gray)
                        Text(syncSource == .ntp ? "NTP synced" : "Device time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Header
                    Text("Behold the glory of infinite Gandalf!")
                        .font(.headline)
                    Text("Billions must be entertained!")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Divider()

                    // Theme
                    Text("Theme")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        themeButton(label: "Light", icon: "sun.max", mode: "light")
                        themeButton(label: "Dark", icon: "moon", mode: "dark")
                        themeButton(label: "System", icon: "gearshape", mode: "system")
                    }

                    // Background playback
                    HStack {
                        Text("Background Playback")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Toggle("", isOn: $backgroundPlayback)
                            .labelsHidden()
                    }

                    Divider()

                    // Developer
                    Text("Developer: \(user)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack(spacing: 12) {
                        socialButton(icon: "globe", label: "hmziq.rs", url: "https://hmziq.rs")
                        socialButton(icon: "chevron.left.forwardslash.chevron.right", label: "GitHub", url: "https://github.com/\(user)")
                        socialButton(icon: "xmark", label: "X", url: "https://x.com/\(user)")
                        socialButton(icon: "paperplane", label: "Telegram", url: "https://t.me/\(user)")
                    }

                    Divider()

                    // Video source
                    Text("Video source:")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack(spacing: 12) {
                        Link(destination: URL(string: youtubeLink)!) {
                            Label("Original video", systemImage: "play.circle")
                        }
                        .buttonStyle(.bordered)

                        ShareLink(item: "Check out Epic Sax Gandalf: \(youtubeLink)") {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
    }

    @ViewBuilder
    private func themeButton(label: String, icon: String, mode: String) -> some View {
        Button {
            themeMode = mode
        } label: {
            Label(label, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(themeMode == mode ? .red : .accentColor)
    }

    @ViewBuilder
    private func socialButton(icon: String, label: String, url: String) -> some View {
        if let dest = URL(string: url) {
            Link(destination: dest) {
                Image(systemName: icon)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
        }
    }
}
