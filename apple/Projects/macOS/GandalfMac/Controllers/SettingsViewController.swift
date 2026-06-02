import AppKit
import GandalfShared

class SettingsViewController: NSViewController {
    let syncSource: NtpClient.SyncSource
    let onDismiss: () -> Void

    private let user = "hmziqrs"
    private let youtubeLink = "https://youtu.be/BBGEG21CGo0"

    private let linkURLs: [String] = [
        "https://hmziq.rs",
        "https://github.com/hmziqrs",
        "https://x.com/hmziqrs",
        "https://t.me/hmziqrs",
    ]

    init(syncSource: NtpClient.SyncSource, onDismiss: @escaping () -> Void) {
        self.syncSource = syncSource
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 440))
        view.wantsLayer = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])

        stack.addArrangedSubview(makeSyncStatusRow())
        stack.addArrangedSubview(makeHeader())
        stack.addArrangedSubview(makeSeparator())

        stack.addArrangedSubview(makeLabel("Theme", bold: true))
        stack.addArrangedSubview(makeThemeRow())

        stack.addArrangedSubview(makeBackgroundPlaybackRow())
        stack.addArrangedSubview(makeSeparator())

        stack.addArrangedSubview(makeLabel("Developer: \(user)", bold: true))
        stack.addArrangedSubview(makeDevLinksRow())
        stack.addArrangedSubview(makeSeparator())

        stack.addArrangedSubview(makeLabel("Video source:", bold: true))
        stack.addArrangedSubview(makeVideoSourceRow())
    }

    // MARK: - Components

    private func makeSyncStatusRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 6
        container.alignment = .centerY

        let icon = NSImageView(frame: NSRect(x: 0, y: 0, width: 14, height: 14))
        icon.image = NSImage(systemSymbolName: "sync", accessibilityDescription: "Sync")
        icon.contentTintColor = syncSource == .ntp ? .systemGreen : .systemGray
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let text = NSTextField(labelWithString: syncSource == .ntp ? "NTP synced" : "Device time")
        text.font = NSFont.systemFont(ofSize: 11)
        text.textColor = .secondaryLabelColor

        container.addArrangedSubview(icon)
        container.addArrangedSubview(text)
        return container
    }

    private func makeHeader() -> NSView {
        let container = NSStackView()
        container.orientation = .vertical
        container.spacing = 2

        let title = NSTextField(labelWithString: "Behold the glory of infinite Gandalf!")
        title.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        let subtitle = NSTextField(labelWithString: "Billions must be entertained!")
        subtitle.font = NSFont.systemFont(ofSize: 11)
        subtitle.textColor = .systemRed

        container.addArrangedSubview(title)
        container.addArrangedSubview(subtitle)
        return container
    }

    private func makeThemeRow() -> NSView {
        let segmented = NSSegmentedControl(
            labels: ["Light", "Dark", "System"],
            trackingMode: .selectOne,
            target: self,
            action: #selector(themeChanged(_:))
        )
        segmented.selectedSegment = currentThemeSegmentIndex()
        segmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return segmented
    }

    private func makeBackgroundPlaybackRow() -> NSView {
        let checkbox = NSButton(
            checkboxWithTitle: "Background playback",
            target: self,
            action: #selector(backgroundPlaybackToggled(_:))
        )
        checkbox.state = UserDefaults.standard.bool(forKey: "background_playback") ? .on : .off
        checkbox.font = NSFont.systemFont(ofSize: 12)
        return checkbox
    }

    private func makeDevLinksRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 8

        let icons = ["globe", "chevron.left.forwardslash.chevron.right", "xmark", "paperplane"]

        for (index, icon) in icons.enumerated() {
            let button = NSButton(frame: NSRect(x: 0, y: 0, width: 36, height: 36))
            button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
            button.bezelStyle = .rounded
            button.isBordered = true
            button.tag = index
            button.target = self
            button.action = #selector(openDevLink(_:))
            container.addArrangedSubview(button)
        }

        return container
    }

    private func makeVideoSourceRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 8

        let linkButton = NSButton(title: "Original video", target: self, action: #selector(openVideoLink(_:)))
        linkButton.bezelStyle = .rounded
        container.addArrangedSubview(linkButton)

        let shareButton = NSButton(
            image: NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: "Share")!,
            target: self,
            action: #selector(shareLink(_:))
        )
        shareButton.bezelStyle = .rounded
        container.addArrangedSubview(shareButton)

        return container
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, bold: Bool = false) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = bold ? NSFont.systemFont(ofSize: 12, weight: .semibold) : NSFont.systemFont(ofSize: 12)
        return label
    }

    private func makeSeparator() -> NSBox {
        let sep = NSBox()
        sep.boxType = .separator
        return sep
    }

    private func currentThemeSegmentIndex() -> Int {
        let mode = UserDefaults.standard.string(forKey: "theme_mode") ?? "system"
        switch mode {
        case "light": return 0
        case "dark":  return 1
        default:      return 2
        }
    }

    // MARK: - Actions

    @objc private func themeChanged(_ sender: NSSegmentedControl) {
        let modes = ["light", "dark", "system"]
        let mode = modes[sender.selectedSegment]
        UserDefaults.standard.set(mode, forKey: "theme_mode")

        switch mode {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
        default:      NSApp.appearance = nil
        }

        MacAnalytics.logChangeTheme(mode: mode)
    }

    @objc private func backgroundPlaybackToggled(_ sender: NSButton) {
        let enabled = sender.state == .on
        UserDefaults.standard.set(enabled, forKey: "background_playback")
        MacAnalytics.logToggleBackgroundPlayback(enabled: enabled)
    }

    @objc private func openDevLink(_ sender: NSButton) {
        let index = sender.tag
        guard index < linkURLs.count, let url = URL(string: linkURLs[index]) else { return }
        NSWorkspace.shared.open(url)
        MacAnalytics.logClickSocialLink(platform: linkURLs[index], url: linkURLs[index])
    }

    @objc private func openVideoLink(_ sender: NSButton) {
        guard let url = URL(string: youtubeLink) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func shareLink(_ sender: NSButton) {
        let text = "Check out Epic Sax Gandalf: \(youtubeLink)"
        let picker = NSSharingServicePicker(items: [text])
        if let contentView = sender.superview {
            picker.show(relativeTo: sender.bounds, of: contentView, preferredEdge: .minY)
        }
    }

    // MARK: - Sheet dismiss

    @objc func dismissSettings() {
        dismiss(self)
        onDismiss()
    }
}
