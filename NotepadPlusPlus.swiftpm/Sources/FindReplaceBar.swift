#if os(macOS)
import Cocoa

public class FindReplaceBar: NSView {
    public var onFindNext: ((String, Bool, Bool, Bool) -> Void)?
    public var onFindPrev: ((String, Bool, Bool, Bool) -> Void)?
    public var onReplace: ((String, String, Bool, Bool, Bool) -> Void)?
    public var onReplaceAll: ((String, String, Bool, Bool, Bool) -> Void)?
    public var onCount: ((String, Bool, Bool, Bool) -> Void)?
    public var onClose: (() -> Void)?

    private let findField = NSSearchField()
    private let replaceField = NSTextField()
    private let matchCaseCheck = NSButton(checkboxWithTitle: "Match case", target: nil, action: nil)
    private let wholeWordCheck = NSButton(checkboxWithTitle: "Whole word", target: nil, action: nil)
    private let regexCheck = NSButton(checkboxWithTitle: "Regex", target: nil, action: nil)
    public let statusLabel = NSTextField(labelWithString: "")
    private var isDarkMode: Bool = false

    public init() {
        super.init(frame: .zero)
        wantsLayer = true
        clipsToBounds = true
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bgColor = isDarkMode
            ? NSColor(calibratedRed: 0.16, green: 0.16, blue: 0.17, alpha: 1.0)
            : NSColor(calibratedRed: 0.93, green: 0.93, blue: 0.94, alpha: 1.0)
        bgColor.setFill()
        bounds.fill()

        let borderColor = isDarkMode
            ? NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.25, alpha: 1.0)
            : NSColor(calibratedRed: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
        borderColor.setStroke()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: 0.5))
        path.line(to: NSPoint(x: bounds.width, y: 0.5))
        path.lineWidth = 1
        path.stroke()
    }

    public func applyTheme(isDark: Bool) {
        self.isDarkMode = isDark
        needsDisplay = true
    }

    private func setupUI() {
        findField.placeholderString = "Find what..."
        replaceField.placeholderString = "Replace with..."

        let nextBtn = NSButton(title: "Find Next", target: self, action: #selector(handleNext))
        nextBtn.bezelStyle = .rounded
        let prevBtn = NSButton(title: "Find Prev", target: self, action: #selector(handlePrev))
        prevBtn.bezelStyle = .rounded
        let replaceBtn = NSButton(title: "Replace", target: self, action: #selector(handleReplace))
        replaceBtn.bezelStyle = .rounded
        let replaceAllBtn = NSButton(title: "Replace All", target: self, action: #selector(handleReplaceAll))
        replaceAllBtn.bezelStyle = .rounded
        let countBtn = NSButton(title: "Count", target: self, action: #selector(handleCount))
        countBtn.bezelStyle = .rounded

        let closeBtn = NSButton(title: "✕", target: self, action: #selector(handleClose))
        closeBtn.isBordered = false
        closeBtn.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        closeBtn.toolTip = "Close (Esc)"

        statusLabel.textColor = .secondaryLabelColor
        statusLabel.font = NSFont.systemFont(ofSize: 11)

        let topRow = NSStackView(views: [findField, nextBtn, prevBtn, countBtn, statusLabel, NSView(), closeBtn])
        topRow.orientation = .horizontal
        topRow.spacing = 8
        topRow.alignment = .centerY

        let bottomRow = NSStackView(views: [replaceField, replaceBtn, replaceAllBtn, matchCaseCheck, wholeWordCheck, regexCheck])
        bottomRow.orientation = .horizontal
        bottomRow.spacing = 8
        bottomRow.alignment = .centerY

        let mainStack = NSStackView(views: [topRow, bottomRow])
        mainStack.orientation = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.edgeInsets = NSEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            findField.widthAnchor.constraint(equalToConstant: 220),
            replaceField.widthAnchor.constraint(equalToConstant: 220)
        ])
    }

    @objc private func handleNext() {
        onFindNext?(findField.stringValue, matchCaseCheck.state == .on, wholeWordCheck.state == .on, regexCheck.state == .on)
    }

    @objc private func handlePrev() {
        onFindPrev?(findField.stringValue, matchCaseCheck.state == .on, wholeWordCheck.state == .on, regexCheck.state == .on)
    }

    @objc private func handleReplace() {
        onReplace?(findField.stringValue, replaceField.stringValue, matchCaseCheck.state == .on, wholeWordCheck.state == .on, regexCheck.state == .on)
    }

    @objc private func handleReplaceAll() {
        onReplaceAll?(findField.stringValue, replaceField.stringValue, matchCaseCheck.state == .on, wholeWordCheck.state == .on, regexCheck.state == .on)
    }

    @objc private func handleCount() {
        onCount?(findField.stringValue, matchCaseCheck.state == .on, wholeWordCheck.state == .on, regexCheck.state == .on)
    }

    @objc private func handleClose() {
        onClose?()
    }

    public func focusFind() {
        window?.makeFirstResponder(findField)
    }
}
#endif
