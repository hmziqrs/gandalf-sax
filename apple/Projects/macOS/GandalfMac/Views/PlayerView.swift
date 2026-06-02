import AppKit
import AVFoundation

class PlayerView: NSView {
    private var _playerLayer: AVPlayerLayer?
    var onTap: (() -> Void)?

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
}
