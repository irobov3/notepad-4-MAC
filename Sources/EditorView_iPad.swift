#if os(iOS)
import SwiftUI
import UIKit

public class iPadCodeTextView: UITextView {
    public weak var gutterView: LineGutterView_iPad?

    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let key = press.key {
                // Tab key on physical Magic Keyboard / external keyboard
                if key.keyCode == .keyboardTab && key.modifierFlags.isEmpty {
                    insertText("    ")
                    return
                }

                // Return key: auto-indent
                if key.keyCode == .keyboardReturnOrEnter && key.modifierFlags.isEmpty {
                    let selected = selectedRange
                    let str = (text as NSString)
                    let lineRange = str.lineRange(for: selected)
                    let currentLine = str.substring(with: lineRange)
                    let leadingSpaces = currentLine.prefix(while: { $0 == " " || $0 == "\t" })

                    super.pressesBegan(presses, with: event)
                    if !leadingSpaces.isEmpty {
                        insertText(String(leadingSpaces))
                    }
                    return
                }
            }
        }
        super.pressesBegan(presses, with: event)
    }
}

public struct EditorView_iPad: UIViewRepresentable {
    @ObservedObject public var document: DocumentModel
    public var isDarkMode: Bool
    public var fontSize: CGFloat
    public var wordWrap: Bool
    public var onCursorChange: (() -> Void)?

    public init(
        document: DocumentModel,
        isDarkMode: Bool,
        fontSize: CGFloat = 14,
        wordWrap: Bool = false,
        onCursorChange: (() -> Void)? = nil
    ) {
        self.document = document
        self.isDarkMode = isDarkMode
        self.fontSize = fontSize
        self.wordWrap = wordWrap
        self.onCursorChange = onCursorChange
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground

        let gutter = LineGutterView_iPad()
        gutter.translatesAutoresizingMaskIntoConstraints = false

        let textView = iPadCodeTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = context.coordinator
        textView.gutterView = gutter
        gutter.textView = textView

        // Editor properties
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.keyboardType = .asciiCapable
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 8)

        // Custom iPad on-screen keyboard accessory bar
        let accessory = AccessoryBar_iPad(textView: textView)
        textView.inputAccessoryView = accessory

        container.addSubview(gutter)
        container.addSubview(textView)

        NSLayoutConstraint.activate([
            gutter.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            gutter.topAnchor.constraint(equalTo: container.topAnchor),
            gutter.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            gutter.widthAnchor.constraint(equalToConstant: 46),

            textView.leadingAnchor.constraint(equalTo: gutter.trailingAnchor),
            textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textView.topAnchor.constraint(equalTo: container.topAnchor),
            textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        context.coordinator.textView = textView
        context.coordinator.gutterView = gutter

        // Initial text load and styling
        textView.text = document.content
        context.coordinator.applyThemeAndHighlight(isDark: isDarkMode, fontSz: fontSize, wrap: wordWrap)
        context.coordinator.updateCursorStats()

        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        guard let textView = context.coordinator.textView else { return }

        if textView.text != document.content {
            textView.text = document.content
        }

        context.coordinator.applyThemeAndHighlight(isDark: isDarkMode, fontSz: fontSize, wrap: wordWrap)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: EditorView_iPad
        weak var textView: iPadCodeTextView?
        weak var gutterView: LineGutterView_iPad?

        init(_ parent: EditorView_iPad) {
            self.parent = parent
        }

        public func applyThemeAndHighlight(isDark: Bool, fontSz: CGFloat, wrap: Bool) {
            guard let tv = textView else { return }
            let theme: SyntaxTheme = isDark ? .darkMode : .classic
            let font = UIFont.monospacedSystemFont(ofSize: max(10, min(32, fontSz)), weight: .regular)

            tv.backgroundColor = theme.backgroundColor
            tv.tintColor = theme.textColor
            gutterView?.theme = theme

            // Word wrap
            if wrap {
                tv.textContainer.lineBreakMode = .byWordWrapping
                tv.textContainer.widthTracksTextView = true
                tv.isScrollEnabled = true
            } else {
                tv.textContainer.lineBreakMode = .byClipping
                tv.textContainer.widthTracksTextView = false
                tv.textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            }

            // Syntax highlighting
            let storage = tv.textStorage
            SyntaxHighlighter.highlight(
                textStorage: storage,
                language: parent.document.language,
                theme: theme,
                font: font
            )
            gutterView?.setNeedsDisplay()
        }

        public func textViewDidChange(_ textView: UITextView) {
            parent.document.content = textView.text
            parent.document.isModified = true

            let theme: SyntaxTheme = parent.isDarkMode ? .darkMode : .classic
            let font = UIFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            let storage = textView.textStorage
            SyntaxHighlighter.highlight(
                textStorage: storage,
                language: parent.document.language,
                theme: theme,
                font: font
            )

            updateCursorStats()
            gutterView?.setNeedsDisplay()
        }

        public func textViewDidChangeSelection(_ textView: UITextView) {
            updateCursorStats()
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            gutterView?.setNeedsDisplay()
        }

        public func updateCursorStats() {
            guard let tv = textView else { return }
            let selected = tv.selectedRange
            let text = tv.text as NSString
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

            parent.document.cursorLine = line
            parent.document.cursorCol = col
            parent.document.cursorPosition = location
            parent.document.selectionLength = selected.length
            parent.onCursorChange?()
        }
    }
}
#endif
