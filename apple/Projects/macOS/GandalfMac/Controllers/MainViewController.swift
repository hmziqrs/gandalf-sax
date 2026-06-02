import AppKit
import AVFoundation
import GandalfShared

class MainViewController: NSViewController {
    private let viewModel: VideoViewModel
    private var playerView: PlayerView!
    private var hintView: HintOverlayView?

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

    private func showSettings() {
        let settingsVC = SettingsViewController(
            syncSource: viewModel.syncSource,
            onDismiss: { [weak self] in
                self?.viewModel.syncVideo()
            }
        )
        presentAsSheet(settingsVC)
    }

    // MARK: - Keyboard

    private func setupKeyMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard let chars = event.charactersIgnoringModifiers else { return event }

        if chars == "f" {
            view.window?.toggleFullScreen(nil)
            return nil
        }

        if event.keyCode == 53 { // Escape
            if view.window?.styleMask.contains(.fullScreen) == true {
                view.window?.toggleFullScreen(nil)
                return nil
            }
        }

        return event
    }
}
