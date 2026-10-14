import Cocoa

public class ToolbarView: NSView {
    public var onNew: (() -> Void)?
    public var onOpen: (() -> Void)?
    public var onSave: (() -> Void)?
    public var onSaveAll: (() -> Void)?
    public var onClose: (() -> Void)?
    public var onCut: (() -> Void)?
    public var onCopy: (() -> Void)?
    public var onPaste: (() -> Void)?
    public var onUndo: (() -> Void)?
    public var onRedo: (() -> Void)?
    public var onFind: (() -> Void)?
    public var onZoomIn: (() -> Void)?
    public var onZoomOut: (() -> Void)?
    public var onToggleWordWrap: (() -> Void)?
    public var onToggleTheme: (() -> Void)?

    private let stack = NSStackView()
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

        // Background (always fill own bounds only)
        let bgColor = isDarkMode
            ? NSColor(calibratedRed: 0.16, green: 0.16, blue: 0.17, alpha: 1.0)
            : NSColor(calibratedRed: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
        bgColor.setFill()
        bounds.fill()

        // Bottom border line
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
        let tint = isDark ? NSColor.white : NSColor(calibratedWhite: 0.15, alpha: 1.0)
        for view in stack.arrangedSubviews {
            if let btn = view as? NSButton {
                btn.contentTintColor = tint
            }
        }
        needsDisplay = true
    }

    private func setupUI() {
        let newBtn = makeButton(title: "New (⌘N)", symbol: "doc.badge.plus", action: #selector(handleNew))
        let openBtn = makeButton(title: "Open... (⌘O)", symbol: "folder", action: #selector(handleOpen))
        let saveBtn = makeButton(title: "Save (⌘S)", symbol: "square.and.arrow.down", action: #selector(handleSave))
        let saveAllBtn = makeButton(title: "Save All (⇧⌘S)", symbol: "square.and.arrow.down.on.square", action: #selector(handleSaveAll))
        let closeBtn = makeButton(title: "Close Tab (⌘W)", symbol: "xmark", action: #selector(handleClose))

        let cutBtn = makeButton(title: "Cut (⌘X)", symbol: "scissors", action: #selector(handleCut))
        let copyBtn = makeButton(title: "Copy (⌘C)", symbol: "doc.on.doc", action: #selector(handleCopy))
        let pasteBtn = makeButton(title: "Paste (⌘V)", symbol: "clipboard", action: #selector(handlePaste))

        let undoBtn = makeButton(title: "Undo (⌘Z)", symbol: "arrow.uturn.backward", action: #selector(handleUndo))
        let redoBtn = makeButton(title: "Redo (⇧⌘Z)", symbol: "arrow.uturn.forward", action: #selector(handleRedo))

        let findBtn = makeButton(title: "Find & Replace (⌘F)", symbol: "magnifyingglass", action: #selector(handleFind))

        let zoomInBtn = makeButton(title: "Zoom In (⌘+)", symbol: "plus.magnifyingglass", action: #selector(handleZoomIn))
        let zoomOutBtn = makeButton(title: "Zoom Out (⌘-)", symbol: "minus.magnifyingglass", action: #selector(handleZoomOut))
        let wrapBtn = makeButton(title: "Toggle Word Wrap", symbol: "text.word.spacing", action: #selector(handleWrap))
        let themeBtn = makeButton(title: "Toggle Light/Dark Theme", symbol: "circle.righthalf.filled", action: #selector(handleTheme))

        let items: [NSView] = [
            newBtn, openBtn, saveBtn, saveAllBtn, closeBtn,
            makeSeparator(),
            cutBtn, copyBtn, pasteBtn,
            makeSeparator(),
            undoBtn, redoBtn,
            makeSeparator(),
            findBtn,
            makeSeparator(),
            zoomInBtn, zoomOutBtn, wrapBtn,
            makeSeparator(),
            themeBtn
        ]

        items.forEach { stack.addArrangedSubview($0) }
        stack.orientation = .horizontal
        stack.spacing = 3
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    private func makeButton(title: String, symbol: String, action: Selector) -> NSButton {
        let btn = NSButton(frame: .zero)
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: title) {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
            btn.image = img.withSymbolConfiguration(config) ?? img
            btn.imagePosition = .imageOnly
        } else {
            btn.title = String(title.prefix(3))
        }

        btn.bezelStyle = .texturedRounded
        btn.isBordered = true
        btn.contentTintColor = NSColor(calibratedWhite: 0.15, alpha: 1.0)
        btn.toolTip = title
        btn.target = self
        btn.action = action
        btn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 28),
            btn.heightAnchor.constraint(equalToConstant: 24)
        ])
        return btn
    }

    private func makeSeparator() -> NSView {
        let sep = NSBox()
        sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sep.widthAnchor.constraint(equalToConstant: 1),
            sep.heightAnchor.constraint(equalToConstant: 18)
        ])
        return sep
    }

    @objc private func handleNew() { onNew?() }
    @objc private func handleOpen() { onOpen?() }
    @objc private func handleSave() { onSave?() }
    @objc private func handleSaveAll() { onSaveAll?() }
    @objc private func handleClose() { onClose?() }
    @objc private func handleCut() { onCut?() }
    @objc private func handleCopy() { onCopy?() }
    @objc private func handlePaste() { onPaste?() }
    @objc private func handleUndo() { onUndo?() }
    @objc private func handleRedo() { onRedo?() }
    @objc private func handleFind() { onFind?() }
    @objc private func handleZoomIn() { onZoomIn?() }
    @objc private func handleZoomOut() { onZoomOut?() }
    @objc private func handleWrap() { onToggleWordWrap?() }
    @objc private func handleTheme() { onToggleTheme?() }
}
