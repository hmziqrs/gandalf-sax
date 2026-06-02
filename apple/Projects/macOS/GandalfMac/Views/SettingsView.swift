import SwiftUI
import GandalfSync

struct SettingsView: View {
    let syncSource: NtpClient.SyncSource
    @Binding var themeMode: String

    private let youtubeLink = "https://youtu.be/BBGEG21CGo0"
    private let user = "hmziqrs"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Sync status
            HStack {
                Image(systemName: "sync")
                    .foregroundStyle(syncSource == .ntp ? .green : .gray)
                Text(syncSource == .ntp ? "NTP synced" : "Device time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Behold the glory of infinite Gandalf!")
                .font(.headline)
            Text("Billions must be entertained!")
                .font(.caption)
                .foregroundStyle(.red)

            Divider()

            Text("Theme")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack(spacing: 8) {
                themeButton(label: "Light", icon: "sun.max", mode: "light")
                themeButton(label: "Dark", icon: "moon", mode: "dark")
                themeButton(label: "System", icon: "gearshape", mode: "system")
            }

            Divider()

            Text("Developer: \(user)")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack(spacing: 12) {
                socialButton(icon: "globe", url: "https://hmziq.rs")
                socialButton(icon: "chevron.left.forwardslash.chevron.right", url: "https://github.com/\(user)")
                socialButton(icon: "xmark", url: "https://x.com/\(user)")
                socialButton(icon: "paperplane", url: "https://t.me/\(user)")
            }

            Divider()

            Text("Video source:")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack {
                Link("Original video", destination: URL(string: youtubeLink)!)
                    .buttonStyle(.bordered)
                ShareLink(item: "Check out Epic Sax Gandalf: \(youtubeLink)") {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
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
    private func socialButton(icon: String, url: String) -> some View {
        if let dest = URL(string: url) {
            Link(destination: dest) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
        }
    }
}
