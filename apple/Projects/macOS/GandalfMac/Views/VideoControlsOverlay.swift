import AppKit

/// A floating video control bar: volume slider + fullscreen button.
/// Shows on mouse move, auto-hides after 3 seconds of inactivity.
final class VideoControlsOverlay: NSView {

    // MARK: - Public

    private(set) var isShowing: Bool = false

    var onVolumeChange: ((Float) -> Void)?
    var onToggleFullscreen: (() -> Void)?

    // MARK: - Private

    private var isFullscreen: Bool = false
    private let volumeSlider = NSSlider()
    private let fullscreenButton = NSButton()
    private let stackView = NSStackView()

    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        isHidden = true
        wantsLayer = true

        setupBackground()
        setupVolumeSlider()
        setupFullscreenButton()
        assembleStackView()
    }

    // MARK: - Background

    private func setupBackground() {
        let blur = NSVisualEffectView()
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 10
        addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Volume Slider

    private func setupVolumeSlider() {
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 1
        volumeSlider.doubleValue = 1
        volumeSlider.isContinuous = true
        volumeSlider.controlSize = .small
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeSliderMoved)
        NSLayoutConstraint.activate([
            volumeSlider.widthAnchor.constraint(equalToConstant: 100),
        ])

        let icon = NSImageView()
        icon.image = NSImage(systemSymbolName: "speaker.wave.2.fill",
                             accessibilityDescription: "Volume")
        icon.contentTintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
        ])

        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(volumeSlider)
    }

    // MARK: - Fullscreen Button

    private func setupFullscreenButton() {
        fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        fullscreenButton.isBordered = false
        fullscreenButton.imagePosition = .imageOnly
        fullscreenButton.image = NSImage(systemSymbolName: "arrow.up.right.and.arrow.down.left.rectangle",
                                         accessibilityDescription: "Fullscreen")
        fullscreenButton.contentTintColor = .white
        fullscreenButton.bezelStyle = .inline
        fullscreenButton.target = self
        fullscreenButton.action = #selector(fullscreenTapped)
        if let cell = fullscreenButton.cell as? NSButtonCell {
            cell.highlightsBy = .contentsCellMask
        }
        fullscreenButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stackView.addArrangedSubview(fullscreenButton)
    }

    // MARK: - Assembly

    private func assembleStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 10
        stackView.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func volumeSliderMoved() {
        onVolumeChange?(Float(volumeSlider.floatValue))
    }

    @objc private func fullscreenTapped() {
        isFullscreen.toggle()
        let symbol = isFullscreen
            ? "arrow.down.left.and.arrow.up.right.rectangle"
            : "arrow.up.right.and.arrow.down.left.rectangle"
        fullscreenButton.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        onToggleFullscreen?()
    }

    // MARK: - Public API

    func show() {
        guard !isShowing else { return }
        isShowing = true
        isHidden = false
        wantsLayer = true
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1
        })
    }

    func hide() {
        guard isShowing else { return }
        isShowing = false
        wantsLayer = true
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        }, completionHandler: {
            if !self.isShowing { self.isHidden = true }
        })
    }

    func setFullscreenState(_ fullscreen: Bool) {
        isFullscreen = fullscreen
        let symbol = fullscreen
            ? "arrow.down.left.and.arrow.up.right.rectangle"
            : "arrow.up.right.and.arrow.down.left.rectangle"
        fullscreenButton.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
    }
}
