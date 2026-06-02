import AppKit

/// A blurred overlay that dims the content behind it.
/// Clicking on the overlay background (not on any child view) triggers `onBackgroundClick`.
class ModalOverlayView: NSVisualEffectView {
    var onBackgroundClick: (() -> Void)?

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        material = .underWindowBackground
        blendingMode = .behindWindow
        state = .active
        alphaValue = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        // Only trigger dismiss if the click landed on the overlay itself,
        // not on the settings card (which is a child view).
        if hitTest(point) == self {
            onBackgroundClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
}
