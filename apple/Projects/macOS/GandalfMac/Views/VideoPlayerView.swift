import SwiftUI
import AVFoundation

/// NSViewRepresentable wrapper for AVPlayerLayer on macOS
struct VideoPlayerView: NSViewRepresentable {
    let player: AVQueuePlayer

    func makeNSView(context: Context) -> PlayerNSView {
        let view = PlayerNSView()
        view.wantsLayer = true
        view.playerLayer.player = player
        view.layer?.backgroundColor = .black
        return view
    }

    func updateNSView(_ nsView: PlayerNSView, context: Context) {
        nsView.playerLayer.player = player
    }
}

class PlayerNSView: NSView {
    private var _playerLayer: AVPlayerLayer?

    override func makeBackingLayer() -> CALayer {
        let layer = AVPlayerLayer()
        _playerLayer = layer
        return layer
    }

    var playerLayer: AVPlayerLayer {
        if let existing = _playerLayer {
            return existing
        }
        // Fallback: create and set the layer manually
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
}
