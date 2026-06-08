import AppKit

/// Frosted-glass splash screen shown while NTP sync is in progress.
/// Blocks all taps and consumes mouse events while visible.
class SplashOverlayView: NSView {

    /// When true, hitTest returns nil so events pass through during fade-out.
    var stopsHitTesting = false

    private let spinner = NSProgressIndicator()
    private let statusLabel = NSTextField(labelWithString: "Syncing time…")
    private let titleLabel = NSTextField(labelWithString: "Epic Sax Gandalf")

    init() {
        super.init(frame: .zero)
        wantsLayer = true

        // Frosted glass background
        let effect = NSVisualEffectView()
        effect.material = .sheet
        effect.blendingMode = .behindWindow
        effect.state = .followsWindowActiveState
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 14
        effect.layer?.cornerCurve = .continuous
        effect.layer?.masksToBounds = true
        effect.translatesAutoresizingMaskIntoConstraints = false
        addSubview(effect)

        NSLayoutConstraint.activate([
            effect.leadingAnchor.constraint(equalTo: leadingAnchor),
            effect.trailingAnchor.constraint(equalTo: trailingAnchor),
            effect.topAnchor.constraint(equalTo: topAnchor),
            effect.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Title
        titleLabel.font = NSFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .labelColor
        titleLabel.alignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Spinner
        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimation(nil)

        // Status label
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        // Container stack
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .centerX
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(statusLabel)

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),

            spinner.widthAnchor.constraint(equalToConstant: 20),
            spinner.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Pass-through events once dismiss has started; consume them otherwise.
    override func hitTest(_ point: NSPoint) -> NSView? {
        return stopsHitTesting ? nil : super.hitTest(point)
    }

    /// Consume all mouse events so nothing behind the splash is clickable.
    override func mouseDown(with event: NSEvent) { }
    override func mouseUp(with event: NSEvent) { }
}
