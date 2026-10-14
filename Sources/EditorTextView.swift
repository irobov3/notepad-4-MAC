import Cocoa

public class EditorTextView: NSTextView {
    public weak var documentModel: DocumentModel?
    public var currentTheme: SyntaxTheme = .classic {
        didSet {
            applyTheme()
        }
    }
    public var currentFont: NSFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular) {
        didSet {
            applyTheme()
        }
    }

    public override init(frame: NSRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupEditor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEditor()
    }

    private func setupEditor() {
        self.isRichText = false
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticDashSubstitutionEnabled = false
        self.isAutomaticTextReplacementEnabled = false
        self.isAutomaticSpellingCorrectionEnabled = false
        self.font = currentFont
        self.textContainerInset = NSSize(width: 8, height: 8)
        self.allowsUndo = true
    }

    public func applyTheme() {
        self.backgroundColor = currentTheme.backgroundColor
        self.insertionPointColor = currentTheme.textColor
        self.selectedTextAttributes = [
            .backgroundColor: currentTheme.selectionColor
        ]
        if let storage = self.textStorage, let doc = documentModel {
            SyntaxHighlighter.highlight(
                textStorage: storage,
                language: doc.language,
                theme: currentTheme,
                font: currentFont
            )
        }
        self.enclosingScrollView?.verticalRulerView?.needsDisplay = true
    }

    public override func keyDown(with event: NSEvent) {
        // Tab key support (4 spaces)
        if event.keyCode == 48 && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.command) {
            self.insertText("    ", replacementRange: self.selectedRange())
            return
        }

        // Return key: auto-indent
        if event.keyCode == 36 {
            let selected = self.selectedRange()
            let text = (self.string as NSString)
            let lineRange = text.lineRange(for: NSRange(location: selected.location, length: 0))
            let currentLine = text.substring(with: lineRange)
            let leadingSpaces = currentLine.prefix(while: { $0 == " " || $0 == "\t" })

            super.keyDown(with: event)
            if !leadingSpaces.isEmpty {
                self.insertText(String(leadingSpaces), replacementRange: self.selectedRange())
            }
            return
        }

        super.keyDown(with: event)
    }

    public func updateCursorStats() {
        guard let doc = documentModel else { return }
        let selected = self.selectedRange()
        let text = self.string as NSString
        let location = selected.location

        var line = 1
        var col = 1
        var index = 0

        while index < location && index < text.length {
            if text.character(at: index) == 0x0A {
                line += 1
                col = 1
            } else {
                col += 1
            }
            index += 1
        }

        doc.cursorLine = line
        doc.cursorCol = col
        doc.cursorPosition = location
        doc.selectionLength = selected.length
    }
}
