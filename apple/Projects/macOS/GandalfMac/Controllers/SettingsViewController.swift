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
        // Shadow container — must have masksToBounds = false so shadow is visible
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 480))
        container.wantsLayer = true
        container.layer?.shadowColor = NSColor.black.withAlphaComponent(0.35).cgColor
        container.layer?.shadowOpacity = 1
        container.layer?.shadowOffset = NSSize(width: 0, height: -4)
        container.layer?.shadowRadius = 20

        // Glass-effect card — translucent liquid glass on macOS 26+, frosted glass fallback
        let card: NSView
        if #available(macOS 26.0, *) {
            let glass = NSGlassEffectView()
            glass.wantsLayer = true
            glass.layer?.cornerRadius = 14
            glass.layer?.cornerCurve = .continuous
            glass.layer?.masksToBounds = true
            glass.layer?.borderColor = NSColor.white.withAlphaComponent(0.08).cgColor
            glass.layer?.borderWidth = 1
            card = glass
        } else {
            let effect = NSVisualEffectView()
            effect.material = .sheet
            effect.blendingMode = .behindWindow
            effect.state = .followsWindowActiveState
            effect.wantsLayer = true
            effect.layer?.cornerRadius = 14
            effect.layer?.cornerCurve = .continuous
            effect.layer?.masksToBounds = true
            effect.layer?.borderColor = NSColor.white.withAlphaComponent(0.08).cgColor
            effect.layer?.borderWidth = 1
            card = effect
        }
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.topAnchor.constraint(equalTo: container.topAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fitToContent()
    }

    // MARK: - Layout

    private func fitToContent() {
        guard let card = view.subviews.first,
              let stack = card.subviews.first(where: { $0 is NSStackView }) as? NSStackView
        else { return }
        let h = stack.intrinsicContentSize.height
        guard h > 0 else { return }
        view.frame.size.height = h
    }

    private func buildLayout() {
        // Find the card (first subview of the container)
        guard let card = view.subviews.first else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 24, bottom: 24, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor),
        ])

        // Close button (top-right, on the card)
        let closeBtn = makeCloseButton()
        card.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            closeBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            closeBtn.widthAnchor.constraint(equalToConstant: 22),
            closeBtn.heightAnchor.constraint(equalToConstant: 22),
        ])

        // Header
        stack.addArrangedSubview(makeHeader())
        stack.addArrangedSubview(makeSyncStatusRow())
        stack.addArrangedSubview(makeSeparator())

        // Appearance section
        stack.addArrangedSubview(makeSectionHeader("Appearance", icon: "paintbrush.fill"))
        stack.addArrangedSubview(makeThemeRow())
        stack.addArrangedSubview(makeBackgroundPlaybackRow())
        stack.addArrangedSubview(makeSeparator())

        // Developer section
        stack.addArrangedSubview(makeSectionHeader("Developer", icon: "curlybraces"))
        stack.addArrangedSubview(makeDevLinksRow())
        stack.addArrangedSubview(makeSeparator())

        // Video section
        stack.addArrangedSubview(makeSectionHeader("Video", icon: "play.rectangle.fill"))
        stack.addArrangedSubview(makeVideoSourceRow())
    }

    // MARK: - Components

    private func makeCloseButton() -> NSButton {
        let button = NSButton()
        button.image = NSImage(systemSymbolName: "xmark.circle.fill",
                               accessibilityDescription: "Close")
        button.imagePosition = .imageOnly
        button.isBordered = false
        button.contentTintColor = .tertiaryLabelColor
        button.target = self
        button.action = #selector(dismissSettings)
        button.toolTip = "Close settings"

        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        button.symbolConfiguration = config

        return button
    }

    private func makeHeader() -> NSView {
        let container = NSStackView()
        container.orientation = .vertical
        container.spacing = 3

        let title = NSTextField(labelWithString: "Epic Sax Gandalf")
        title.font = NSFont.systemFont(ofSize: 17, weight: .bold)

        let subtitle = NSTextField(labelWithString: "Billions must be entertained!")
        subtitle.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        subtitle.textColor = .systemRed

        container.addArrangedSubview(title)
        container.addArrangedSubview(subtitle)
        return container
    }

    private func makeSyncStatusRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 6
        container.alignment = .centerY

        let indicator = NSView()
        indicator.wantsLayer = true
        indicator.layer?.cornerRadius = 4
        indicator.layer?.backgroundColor = (syncSource == .ntp
            ? NSColor.systemGreen
            : NSColor.systemGray).cgColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.widthAnchor.constraint(equalToConstant: 8),
            indicator.heightAnchor.constraint(equalToConstant: 8),
        ])
        indicator.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let text = NSTextField(labelWithString: syncSource == .ntp ? "NTP Synced" : "Device Time")
        text.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        text.textColor = syncSource == .ntp ? .systemGreen : .secondaryLabelColor

        container.addArrangedSubview(indicator)
        container.addArrangedSubview(text)

        let spacer = NSView()
        container.addArrangedSubview(spacer)

        return container
    }

    private func makeSectionHeader(_ text: String, icon: String) -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 6
        container.alignment = .centerY

        let iconView = NSImageView()
        let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iconView.image = NSImage(systemSymbolName: icon,
                                 accessibilityDescription: nil)?.withSymbolConfiguration(config)
        iconView.contentTintColor = .secondaryLabelColor
        iconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor

        container.addArrangedSubview(iconView)
        container.addArrangedSubview(label)

        let spacer = NSView()
        container.addArrangedSubview(spacer)

        return container
    }

    private func makeThemeRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal

        let segmented = NSSegmentedControl(
            labels: ["Light", "Dark", "System"],
            trackingMode: .selectOne,
            target: self,
            action: #selector(themeChanged(_:))
        )
        segmented.selectedSegment = currentThemeSegmentIndex()
        segmented.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        container.addArrangedSubview(segmented)

        let spacer = NSView()
        container.addArrangedSubview(spacer)

        return container
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
        let tooltips = ["Website", "GitHub", "X (Twitter)", "Telegram"]

        for (index, icon) in icons.enumerated() {
            let button = NSButton()
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            button.image = NSImage(systemSymbolName: icon,
                                   accessibilityDescription: nil)?.withSymbolConfiguration(config)
            button.imagePosition = .imageOnly
            button.bezelStyle = .accessoryBarAction
            button.isBordered = true
            button.tag = index
            button.target = self
            button.action = #selector(openDevLink(_:))
            button.toolTip = tooltips[index]
            container.addArrangedSubview(button)
        }

        return container
    }

    private func makeVideoSourceRow() -> NSView {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 8

        let linkButton = NSButton(title: "Original Video",
                                  target: self,
                                  action: #selector(openVideoLink(_:)))
        linkButton.bezelStyle = .accessoryBarAction
        let playConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        linkButton.image = NSImage(systemSymbolName: "play.rectangle",
                                   accessibilityDescription: nil)?.withSymbolConfiguration(playConfig)
        linkButton.imagePosition = .imageLeft
        container.addArrangedSubview(linkButton)

        let shareButton = NSButton()
        let shareConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        shareButton.image = NSImage(systemSymbolName: "square.and.arrow.up",
                                    accessibilityDescription: "Share")?.withSymbolConfiguration(shareConfig)
        shareButton.imagePosition = .imageOnly
        shareButton.bezelStyle = .accessoryBarAction
        shareButton.target = self
        shareButton.action = #selector(shareLink(_:))
        shareButton.toolTip = "Share"
        container.addArrangedSubview(shareButton)

        let spacer = NSView()
        container.addArrangedSubview(spacer)

        return container
    }

    // MARK: - Helpers

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

    // MARK: - Dismiss

    @objc func dismissSettings() {
        onDismiss()
    }
}
