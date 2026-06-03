import AppKit
import AVFoundation

class PlayerView: NSView {
    private var _playerLayer: AVPlayerLayer?
    var onTap: (() -> Void)?
    var onMouseMove: (() -> Void)?
    var onMouseIdle: (() -> Void)?
    private var idleTimer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        updateTrackingAreas()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        updateTrackingAreas()
    }

    override func updateTrackingAreas() {
        for area in trackingAreas { removeTrackingArea(area) }
        let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways, .inVisibleRect, .cursorUpdate]
        addTrackingArea(NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil))
        super.updateTrackingAreas()
    }

    override func makeBackingLayer() -> CALayer {
        let layer = AVPlayerLayer()
        _playerLayer = layer
        return layer
    }

    var playerLayer: AVPlayerLayer {
        if let existing = _playerLayer { return existing }
        let layer = AVPlayerLayer()
        self.layer = layer
        _playerLayer = layer
        return layer
    }

    override func layout() {
        super.layout()
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspect
    }

    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    override func mouseMoved(with event: NSEvent) {
        onMouseMove?()
        resetIdleTimer()
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.onMouseIdle?()
        }
    }
}
