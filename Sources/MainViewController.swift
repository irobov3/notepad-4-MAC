#if os(macOS)
import Cocoa

public class MainViewController: NSViewController {
    public var documents: [DocumentModel] = []
    public var activeIndex: Int = 0
    private var docCounter: Int = 1

    private let toolbar = ToolbarView()
    private let tabBar = TabBarView()
    private let findBar = FindReplaceBar()
    private var editorContainer: EditorContainerView?
    private let statusBar = StatusBarView()

    private let editorPlaceholder = NSView()
    private var isDarkMode: Bool = false
    private var isWordWrapEnabled: Bool = false

    private var findBarHeightConstraint: NSLayoutConstraint!

    public override func loadView() {
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 960, height: 640))
        rootView.wantsLayer = true
        self.view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupEventHandlers()
        let welcome = """
// Welcome to Notepad++ for Mac!
// An authentic native macOS editor inspired by Notepad++.
//
// Key Shortcuts:
//   ⌘N: New File       ⌘O: Open File       ⌘S: Save File
//   ⌘F: Find/Replace   ⌘W: Close Tab       ⌘+: Zoom In / Zoom Out
//
#include <iostream>

int main() {
    std::cout << "Hello, Notepad++ for Mac!" << std::endl;
    return 0;
}
"""
        createNewDocument(initialContent: welcome, initialLanguage: .cpp)
    }

    private func setupLayout() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        findBar.translatesAutoresizingMaskIntoConstraints = false
        findBar.isHidden = true
        editorPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        statusBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toolbar)
        view.addSubview(tabBar)
        view.addSubview(findBar)
        view.addSubview(editorPlaceholder)
        view.addSubview(statusBar)

        findBarHeightConstraint = findBar.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            // 1. Toolbar at the very top
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 34),

            // 2. Tab Bar directly below toolbar
            tabBar.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 30),

            // 3. Find Bar (collapsible, 0pt when closed)
            findBar.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            findBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            findBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            findBarHeightConstraint,

            // 4. Editor Placeholder fills the space between Find Bar and Status Bar
            editorPlaceholder.topAnchor.constraint(equalTo: findBar.bottomAnchor),
            editorPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editorPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editorPlaceholder.bottomAnchor.constraint(equalTo: statusBar.topAnchor),

            // 5. Status Bar at the bottom
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func setupEventHandlers() {
        // Toolbar actions
        toolbar.onNew = { [weak self] in self?.createNewDocument() }
        toolbar.onOpen = { [weak self] in self?.openDocument() }
        toolbar.onSave = { [weak self] in self?.saveActiveDocument() }
        toolbar.onSaveAll = { [weak self] in self?.saveAllDocuments() }
        toolbar.onClose = { [weak self] in
            guard let self = self else { return }
            self.closeDocument(at: self.activeIndex)
        }
        toolbar.onCut = { [weak self] in
            self?.editorContainer?.textView.cut(nil)
        }
        toolbar.onCopy = { [weak self] in
            self?.editorContainer?.textView.copy(nil)
        }
        toolbar.onPaste = { [weak self] in
            self?.editorContainer?.textView.paste(nil)
        }
        toolbar.onUndo = { [weak self] in
            self?.editorContainer?.textView.undoManager?.undo()
        }
        toolbar.onRedo = { [weak self] in
            self?.editorContainer?.textView.undoManager?.redo()
        }
        toolbar.onFind = { [weak self] in self?.toggleFindBar() }
        toolbar.onZoomIn = { [weak self] in
            guard let self = self, let container = self.editorContainer else { return }
            container.currentFontSize += 1
        }
        toolbar.onZoomOut = { [weak self] in
            guard let self = self, let container = self.editorContainer else { return }
            container.currentFontSize = max(8, container.currentFontSize - 1)
        }
        toolbar.onToggleWordWrap = { [weak self] in
            guard let self = self else { return }
            self.isWordWrapEnabled.toggle()
            self.editorContainer?.setWordWrap(self.isWordWrapEnabled)
        }
        toolbar.onToggleTheme = { [weak self] in
            guard let self = self else { return }
            self.toggleTheme()
        }

        // Tab bar actions
        tabBar.onNewTab = { [weak self] in self?.createNewDocument() }
        tabBar.onSelectTab = { [weak self] index in self?.selectTab(at: index) }
        tabBar.onCloseTab = { [weak self] index in self?.closeDocument(at: index) }

        // Find & Replace actions
        findBar.onFindNext = { [weak self] term, matchCase, wholeWord, regex in
            self?.search(term: term, backwards: false, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
        }
        findBar.onFindPrev = { [weak self] term, matchCase, wholeWord, regex in
            self?.search(term: term, backwards: true, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
        }
        findBar.onReplace = { [weak self] find, replace, matchCase, wholeWord, regex in
            self?.replace(find: find, replace: replace, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
        }
        findBar.onReplaceAll = { [weak self] find, replace, matchCase, wholeWord, regex in
            self?.replaceAll(find: find, replace: replace, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
        }
        findBar.onCount = { [weak self] term, matchCase, wholeWord, regex in
            self?.countMatches(term: term, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
        }
        findBar.onClose = { [weak self] in
            guard let self = self else { return }
            self.findBar.isHidden = true
            self.findBarHeightConstraint.constant = 0
            self.view.layoutSubtreeIfNeeded()
        }
    }

    public func toggleTheme() {
        isDarkMode.toggle()
        toolbar.applyTheme(isDark: isDarkMode)
        tabBar.applyTheme(isDark: isDarkMode)
        findBar.applyTheme(isDark: isDarkMode)
        statusBar.applyTheme(isDark: isDarkMode)

        let theme: SyntaxTheme = isDarkMode ? .darkMode : .classic
        editorContainer?.textView.currentTheme = theme
        editorContainer?.rulerView.theme = theme
        editorContainer?.textView.applyTheme()
    }

    public func createNewDocument(initialContent: String = "", initialLanguage: SyntaxLanguage = .plainText) {
        let title = "New \(docCounter)"
        docCounter += 1
        let doc = DocumentModel(title: title, content: initialContent)
        doc.language = initialLanguage
        documents.append(doc)
        selectTab(at: documents.count - 1)
    }

    public func openDocument() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                if let content = try? String(contentsOf: url) {
                    let doc = DocumentModel(title: url.lastPathComponent, content: content, fileURL: url)
                    documents.append(doc)
                }
            }
            if !documents.isEmpty {
                selectTab(at: documents.count - 1)
            }
        }
    }

    public func saveActiveDocument() {
        guard !documents.isEmpty, activeIndex < documents.count else { return }
        let doc = documents[activeIndex]

        if let url = doc.fileURL {
            try? doc.content.write(to: url, atomically: true, encoding: .utf8)
            doc.markSaved(at: url)
            tabBar.updateTabs(documents: documents, selected: activeIndex)
        } else {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = doc.title
            if panel.runModal() == .OK, let url = panel.url {
                try? doc.content.write(to: url, atomically: true, encoding: .utf8)
                doc.markSaved(at: url)
                tabBar.updateTabs(documents: documents, selected: activeIndex)
            }
        }
    }

    public func saveAllDocuments() {
        for (i, _) in documents.enumerated() {
            activeIndex = i
            saveActiveDocument()
        }
    }

    public func closeDocument(at index: Int) {
        guard index >= 0 && index < documents.count else { return }
        documents.remove(at: index)
        if documents.isEmpty {
            createNewDocument()
        } else {
            let newIndex = min(index, documents.count - 1)
            selectTab(at: newIndex)
        }
    }

    public func selectTab(at index: Int) {
        guard index >= 0 && index < documents.count else { return }
        activeIndex = index
        let doc = documents[index]

        tabBar.updateTabs(documents: documents, selected: activeIndex)

        // Swap editor view
        editorContainer?.removeFromSuperview()
        let container = EditorContainerView(documentModel: doc)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.setWordWrap(isWordWrapEnabled)
        let theme: SyntaxTheme = isDarkMode ? .darkMode : .classic
        container.textView.currentTheme = theme
        container.rulerView.theme = theme

        container.onCursorOrTextChange = { [weak self] in
            guard let self = self, self.activeIndex < self.documents.count else { return }
            let d = self.documents[self.activeIndex]
            self.statusBar.update(with: d)
            self.tabBar.updateTabs(documents: self.documents, selected: self.activeIndex)
        }

        editorPlaceholder.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: editorPlaceholder.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: editorPlaceholder.trailingAnchor),
            container.topAnchor.constraint(equalTo: editorPlaceholder.topAnchor),
            container.bottomAnchor.constraint(equalTo: editorPlaceholder.bottomAnchor)
        ])
        self.editorContainer = container

        // Update status bar
        statusBar.update(with: doc)
    }

    public func toggleFindBar() {
        findBar.isHidden.toggle()
        findBarHeightConstraint.constant = findBar.isHidden ? 0 : 68
        view.layoutSubtreeIfNeeded()
        if !findBar.isHidden {
            findBar.focusFind()
        }
    }

    // MARK: - Search & Replace Implementation
    private func search(term: String, backwards: Bool, matchCase: Bool, wholeWord: Bool, regex: Bool) {
        guard !term.isEmpty, let textView = editorContainer?.textView else { return }
        let text = (textView.string as NSString)
        var options: NSString.CompareOptions = []
        if !matchCase { options.insert(.caseInsensitive) }
        if backwards { options.insert(.backwards) }
        if regex { options.insert(.regularExpression) }

        var searchTerm = term
        if wholeWord && !regex {
            searchTerm = "\\b\(NSRegularExpression.escapedPattern(for: term))\\b"
            options.insert(.regularExpression)
        }

        let selected = textView.selectedRange()
        let startLocation = backwards ? selected.location : NSMaxRange(selected)
        let searchLength = backwards ? startLocation : (text.length - startLocation)
        let searchRange = NSRange(location: backwards ? 0 : startLocation, length: max(0, searchLength))

        var matchRange = text.range(of: searchTerm, options: options, range: searchRange)

        // Wrap around if not found
        if matchRange.location == NSNotFound {
            let wrapRange = NSRange(location: 0, length: text.length)
            matchRange = text.range(of: searchTerm, options: options, range: wrapRange)
        }

        if matchRange.location != NSNotFound {
            textView.setSelectedRange(matchRange)
            textView.scrollRangeToVisible(matchRange)
            findBar.statusLabel.stringValue = "Found at pos \(matchRange.location)"
        } else {
            findBar.statusLabel.stringValue = "Can't find \"\(term)\""
        }
    }

    private func replace(find: String, replace: String, matchCase: Bool, wholeWord: Bool, regex: Bool) {
        guard let textView = editorContainer?.textView else { return }
        let selected = textView.selectedRange()
        let text = (textView.string as NSString)

        if selected.length > 0 && text.substring(with: selected) == find {
            textView.insertText(replace, replacementRange: selected)
        }
        search(term: find, backwards: false, matchCase: matchCase, wholeWord: wholeWord, regex: regex)
    }

    private func replaceAll(find: String, replace: String, matchCase: Bool, wholeWord: Bool, regex: Bool) {
        guard !find.isEmpty, let textView = editorContainer?.textView else { return }
        let text = textView.string
        let modified = text.replacingOccurrences(of: find, with: replace)
        textView.string = modified
        editorContainer?.textDidChange(Notification(name: NSText.didChangeNotification))
        findBar.statusLabel.stringValue = "Replaced occurrences"
    }

    private func countMatches(term: String, matchCase: Bool, wholeWord: Bool, regex: Bool) {
        guard !term.isEmpty, let textView = editorContainer?.textView else { return }
        let text = (textView.string as NSString)
        var options: NSString.CompareOptions = []
        if !matchCase { options.insert(.caseInsensitive) }
        if regex { options.insert(.regularExpression) }

        var count = 0
        var searchRange = NSRange(location: 0, length: text.length)

        while searchRange.location < text.length {
            let match = text.range(of: term, options: options, range: searchRange)
            if match.location == NSNotFound { break }
            count += 1
            let nextLoc = NSMaxRange(match)
            if nextLoc >= text.length { break }
            searchRange = NSRange(location: nextLoc, length: text.length - nextLoc)
        }

        findBar.statusLabel.stringValue = "\(count) matches found"
    }
}
#endif
