#if os(macOS)
import Cocoa

public class EditorContainerView: NSView, NSTextViewDelegate {
    public let scrollView: NSScrollView
    public let textView: EditorTextView
    public let rulerView: LineNumberRulerView
    public var documentModel: DocumentModel {
        didSet {
            textView.documentModel = documentModel
            textView.string = documentModel.content
            textView.applyTheme()
        }
    }
    public var currentFontSize: CGFloat = 13 {
        didSet {
            let font = NSFont.monospacedSystemFont(ofSize: max(8, min(36, currentFontSize)), weight: .regular)
            textView.currentFont = font
        }
    }

    public init(documentModel: DocumentModel) {
        self.documentModel = documentModel
        self.scrollView = NSScrollView(frame: .zero)
        let textContainer = NSTextContainer(containerSize: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        self.textView = EditorTextView(frame: .zero, textContainer: textContainer)
        self.rulerView = LineNumberRulerView(scrollView: scrollView, textView: textView)

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var onCursorOrTextChange: (() -> Void)?

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.delegate = self
        textView.documentModel = documentModel
        textView.string = documentModel.content

        scrollView.documentView = textView
        scrollView.verticalRulerView = rulerView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true

        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { [weak self] _ in
            self?.rulerView.needsDisplay = true
        }

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        textView.applyTheme()
    }

    public func textDidChange(_ notification: Notification) {
        documentModel.content = textView.string
        documentModel.isModified = true
        textView.updateCursorStats()
        textView.applyTheme()
        rulerView.needsDisplay = true
        onCursorOrTextChange?()
    }

    public func textViewDidChangeSelection(_ notification: Notification) {
        textView.updateCursorStats()
        onCursorOrTextChange?()
    }

    public func setWordWrap(_ enabled: Bool) {
        if enabled {
            textView.textContainer?.widthTracksTextView = true
            textView.isHorizontallyResizable = false
            scrollView.hasHorizontalScroller = false
        } else {
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.isHorizontallyResizable = true
            scrollView.hasHorizontalScroller = true
        }
    }
}
#endif
