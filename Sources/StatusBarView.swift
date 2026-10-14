import Cocoa

public class StatusBarView: NSView {
    private let posLabel = NSTextField(labelWithString: "Ln : 1    Col : 1    Pos : 1")
    private let linesLabel = NSTextField(labelWithString: "lines : 1    length : 0")
    private let lineEndingLabel = NSTextField(labelWithString: "Unix (LF)")
    private let encodingLabel = NSTextField(labelWithString: "UTF-8")
    private let languageLabel = NSTextField(labelWithString: "Normal text")
    private let modeLabel = NSTextField(labelWithString: "INS")
    private var isDarkMode: Bool = false

    public init() {
        super.init(frame: .zero)
        wantsLayer = true
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Background (always fill own bounds only)
        let bgColor = isDarkMode
            ? NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.13, alpha: 1.0)
            : NSColor(calibratedRed: 0.93, green: 0.93, blue: 0.94, alpha: 1.0)
        bgColor.setFill()
        bounds.fill()

        // Top border separator line
        let borderColor = isDarkMode
            ? NSColor(calibratedRed: 0.22, green: 0.22, blue: 0.23, alpha: 1.0)
            : NSColor(calibratedRed: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
        borderColor.setStroke()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: bounds.height - 0.5))
        path.line(to: NSPoint(x: bounds.width, y: bounds.height - 0.5))
        path.lineWidth = 1
        path.stroke()
    }

    public func applyTheme(isDark: Bool) {
        self.isDarkMode = isDark
        let textColor = isDark ? NSColor.lightGray : NSColor.secondaryLabelColor
        [posLabel, linesLabel, lineEndingLabel, encodingLabel, languageLabel, modeLabel].forEach {
            $0.textColor = textColor
        }
        needsDisplay = true
    }

    private func setupUI() {
        let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        [posLabel, linesLabel, lineEndingLabel, encodingLabel, languageLabel, modeLabel].forEach {
            $0.font = font
            $0.textColor = .secondaryLabelColor
        }

        let stack = NSStackView(views: [
            posLabel,
            makeSeparator(),
            linesLabel,
            makeSeparator(),
            lineEndingLabel,
            makeSeparator(),
            encodingLabel,
            makeSeparator(),
            languageLabel,
            makeSeparator(),
            modeLabel
        ])
        stack.orientation = .horizontal
        stack.spacing = 10
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func makeSeparator() -> NSView {
        let sep = NSBox()
        sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sep.widthAnchor.constraint(equalToConstant: 1),
            sep.heightAnchor.constraint(equalToConstant: 14)
        ])
        return sep
    }

    public func update(with doc: DocumentModel) {
        let linesCount = (doc.content as NSString).components(separatedBy: "\n").count
        let charCount = doc.content.count

        posLabel.stringValue = "Ln : \(doc.cursorLine)    Col : \(doc.cursorCol)    Pos : \(doc.cursorPosition)"
        linesLabel.stringValue = "lines : \(linesCount)    length : \(charCount)"
        lineEndingLabel.stringValue = doc.lineEnding.rawValue
        encodingLabel.stringValue = doc.encodingName
        languageLabel.stringValue = doc.language.rawValue
    }
}
