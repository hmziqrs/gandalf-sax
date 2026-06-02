import AppKit
import AVFoundation
import GandalfShared

class MainViewController: NSViewController {
    private let viewModel: VideoViewModel
    private var playerView: PlayerView!
    private var hintView: HintOverlayView?

    // Overlay modal state
    private var overlayView: ModalOverlayView?
    private var settingsViewController: SettingsViewController?

    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 1280, height: 720))
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupHintOverlay()
        setupKeyMonitor()

        MacAnalytics.logViewHomeScreen()
        viewModel.initialize()
    }

    // MARK: - Setup

    private func setupPlayerView() {
        playerView = PlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.playerLayer.player = viewModel.player
        playerView.onTap = { [weak self] in
            self?.handleVideoTap()
        }
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupHintOverlay() {
        let hint = HintOverlayView()
        hint.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hint)
        NSLayoutConstraint.activate([
            hint.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -8),
            hint.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
        hintView = hint
    }

    // MARK: - Actions

    private func handleVideoTap() {
        viewModel.pause()
        MacAnalytics.logOpenSheet()
        showSettings()
    }

    // MARK: - Settings Overlay

    private func showSettings() {
        guard overlayView == nil else { return }

        let settingsVC = SettingsViewController(
            syncSource: viewModel.syncSource,
            onDismiss: { [weak self] in
                self?.hideSettings()
            }
        )
        self.settingsViewController = settingsVC
        addChild(settingsVC)

        // Dimmed overlay — constrained to fill the main view
        let overlay = ModalOverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.onBackgroundClick = { [weak self] in
            self?.hideSettings()
        }

        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        view.layoutSubtreeIfNeeded()

        // Center the settings card in the overlay using frame + autoresizing
        let cardSize = settingsVC.view.frame.size
        let overlayBounds = overlay.bounds
        settingsVC.view.frame = NSRect(
            x: (overlayBounds.width - cardSize.width) / 2,
            y: (overlayBounds.height - cardSize.height) / 2,
            width: cardSize.width,
            height: cardSize.height
        )
        settingsVC.view.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        overlay.addSubview(settingsVC.view)

        overlayView = overlay

        // Animate: fade in overlay + scale up card
        settingsVC.view.wantsLayer = true
        settingsVC.view.layer?.transform = CATransform3DMakeScale(0.96, 0.96, 1)
        settingsVC.view.alphaValue = 0

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            overlay.animator().alphaValue = 1
            settingsVC.view.animator().alphaValue = 1
        })
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        settingsVC.view.layer?.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    private func hideSettings() {
        guard let overlay = overlayView,
              let settingsVC = settingsViewController else { return }

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            overlay.animator().alphaValue = 0
            settingsVC.view.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self else { return }
            overlay.removeFromSuperview()
            self.settingsViewController?.removeFromParent()
            self.settingsViewController = nil
            self.overlayView = nil
            self.viewModel.syncVideo()
        })
    }

    // MARK: - Keyboard

    private func setupKeyMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard let chars = event.charactersIgnoringModifiers else { return event }
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Cmd+Q → quit, Cmd+W → close window
        if mods.contains(.command) {
            if chars == "q" {
                NSApp.terminate(nil)
                return nil
            }
            if chars == "w" {
                view.window?.close()
                return nil
            }
        }

        if chars == "f" && mods.isEmpty {
            view.window?.toggleFullScreen(nil)
            return nil
        }

        if event.keyCode == 53 { // Escape
            // Dismiss settings overlay if open
            if overlayView != nil {
                hideSettings()
                return nil
            }
            // Otherwise exit fullscreen
            if view.window?.styleMask.contains(.fullScreen) == true {
                view.window?.toggleFullScreen(nil)
                return nil
            }
        }

        return event
    }
}
