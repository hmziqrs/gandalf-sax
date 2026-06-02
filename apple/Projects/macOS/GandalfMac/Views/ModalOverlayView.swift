import AppKit

/// A dimmed overlay that darkens the content behind it.
/// Clicking on the overlay background (not on any child view) triggers `onBackgroundClick`.
class ModalOverlayView: NSView {
    var onBackgroundClick: (() -> Void)?

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.45).cgColor
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
