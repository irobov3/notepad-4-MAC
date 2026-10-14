import Cocoa

public class TabBarView: NSView {
    public var onSelectTab: ((Int) -> Void)?
    public var onCloseTab: ((Int) -> Void)?
    public var onNewTab: (() -> Void)?

    private let stackView = NSStackView()
    private let newTabBtn = NSButton()
    private var isDarkMode: Bool = false
    private var documents: [DocumentModel] = []
    private var selectedIndex: Int = 0

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
            ? NSColor(calibratedRed: 0.13, green: 0.13, blue: 0.14, alpha: 1.0)
            : NSColor(calibratedRed: 0.88, green: 0.88, blue: 0.90, alpha: 1.0)
        bgColor.setFill()
        bounds.fill()

        // Bottom separator line
        let borderColor = isDarkMode
            ? NSColor(calibratedRed: 0.22, green: 0.22, blue: 0.23, alpha: 1.0)
            : NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
        borderColor.setStroke()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: 0.5))
        path.line(to: NSPoint(x: bounds.width, y: 0.5))
        path.lineWidth = 1
        path.stroke()
    }

    public func applyTheme(isDark: Bool) {
        self.isDarkMode = isDark
        newTabBtn.contentTintColor = isDark ? .white : NSColor(calibratedWhite: 0.15, alpha: 1.0)
        updateTabs(documents: documents, selected: selectedIndex)
        needsDisplay = true
    }

    private func setupUI() {
        stackView.orientation = .horizontal
        stackView.spacing = 3
        stackView.alignment = .centerY
        stackView.translatesAutoresizingMaskIntoConstraints = false

        newTabBtn.title = "+"
        newTabBtn.bezelStyle = .texturedRounded
        newTabBtn.isBordered = true
        newTabBtn.contentTintColor = NSColor(calibratedWhite: 0.15, alpha: 1.0)
        newTabBtn.target = self
        newTabBtn.action = #selector(handleNewTab)
        newTabBtn.toolTip = "New Tab (⌘N)"
        newTabBtn.font = NSFont.boldSystemFont(ofSize: 13)
        newTabBtn.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(newTabBtn)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 26),

            newTabBtn.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 6),
            newTabBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            newTabBtn.widthAnchor.constraint(equalToConstant: 24),
            newTabBtn.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    @objc private func handleNewTab() {
        onNewTab?()
    }

    public func updateTabs(documents: [DocumentModel], selected: Int) {
        self.documents = documents
        self.selectedIndex = selected
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, doc) in documents.enumerated() {
            let isSelected = (index == selected)
            let tab = makeTab(doc: doc, index: index, isSelected: isSelected)
            stackView.addArrangedSubview(tab)
        }
    }

    private func makeTab(doc: DocumentModel, index: Int, isSelected: Bool) -> NSView {
        let tab = NSView()
        tab.wantsLayer = true
        tab.layer?.cornerRadius = 4
        if isSelected {
            tab.layer?.backgroundColor = isDarkMode
                ? NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).cgColor
                : NSColor.white.cgColor
            tab.layer?.borderColor = isDarkMode
                ? NSColor(white: 0.35, alpha: 1.0).cgColor
                : NSColor(white: 0.70, alpha: 1.0).cgColor
            tab.layer?.borderWidth = 1
        } else {
            tab.layer?.backgroundColor = isDarkMode
                ? NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.19, alpha: 1.0).cgColor
                : NSColor(white: 0.82, alpha: 1.0).cgColor
            tab.layer?.borderColor = isDarkMode
                ? NSColor(white: 0.25, alpha: 1.0).cgColor
                : NSColor(white: 0.74, alpha: 1.0).cgColor
            tab.layer?.borderWidth = 0.5
        }
        tab.translatesAutoresizingMaskIntoConstraints = false

        // Notepad++ Status Disk: Red = modified, Blue = clean/saved
        let dot = NSView()
        dot.wantsLayer = true
        dot.layer?.cornerRadius = 3.5
        dot.layer?.backgroundColor = doc.isModified
            ? NSColor(calibratedRed: 0.95, green: 0.20, blue: 0.15, alpha: 1.0).cgColor
            : NSColor(calibratedRed: 0.05, green: 0.50, blue: 0.90, alpha: 1.0).cgColor
        dot.translatesAutoresizingMaskIntoConstraints = false

        let lbl = NSTextField(labelWithString: doc.title)
        lbl.font = isSelected ? NSFont.boldSystemFont(ofSize: 11) : NSFont.systemFont(ofSize: 11)
        lbl.textColor = isSelected
            ? (isDarkMode ? NSColor.white : NSColor.labelColor)
            : (isDarkMode ? NSColor.lightGray : NSColor.secondaryLabelColor)
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let closeBtn = NSButton(title: "✕", target: self, action: #selector(handleCloseTab(_:)))
        closeBtn.tag = index
        closeBtn.isBordered = false
        closeBtn.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        closeBtn.contentTintColor = isDarkMode ? NSColor.lightGray : NSColor.secondaryLabelColor
        closeBtn.toolTip = "Close Tab (⌘W)"
        closeBtn.translatesAutoresizingMaskIntoConstraints = false

        tab.addSubview(dot)
        tab.addSubview(lbl)
        tab.addSubview(closeBtn)

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleTabClick(_:)))
        tab.addGestureRecognizer(click)

        NSLayoutConstraint.activate([
            tab.heightAnchor.constraint(equalToConstant: 24),
            dot.leadingAnchor.constraint(equalTo: tab.leadingAnchor, constant: 8),
            dot.centerYAnchor.constraint(equalTo: tab.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 7),
            dot.heightAnchor.constraint(equalToConstant: 7),

            lbl.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            lbl.centerYAnchor.constraint(equalTo: tab.centerYAnchor),
            lbl.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor, constant: -4),

            closeBtn.trailingAnchor.constraint(equalTo: tab.trailingAnchor, constant: -4),
            closeBtn.centerYAnchor.constraint(equalTo: tab.centerYAnchor),
            closeBtn.widthAnchor.constraint(equalToConstant: 16),
            closeBtn.heightAnchor.constraint(equalToConstant: 16)
        ])
        return tab
    }

    @objc private func handleTabClick(_ sender: NSClickGestureRecognizer) {
        if let tab = sender.view, let idx = stackView.arrangedSubviews.firstIndex(of: tab) {
            onSelectTab?(idx)
        }
    }

    @objc private func handleCloseTab(_ sender: NSButton) {
        onCloseTab?(sender.tag)
    }
}
