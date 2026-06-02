import AppKit

class HintOverlayView: NSView {
    private let label: NSTextField

    init() {
        label = NSTextField(labelWithString: "Press F for fullscreen \u{00B7} Click for settings")
        label.font = NSFont.systemFont(ofSize: 10)
        label.textColor = NSColor.white.withAlphaComponent(0.3)
        label.sizeToFit()

        let frame = label.frame.insetBy(dx: -8, dy: -4)
        super.init(frame: frame)

        wantsLayer = true
        label.frame.origin = NSPoint(x: 8, y: 4)
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
