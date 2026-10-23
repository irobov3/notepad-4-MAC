#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

public struct MainView_iPad: View {
    @State public var documents: [DocumentModel] = []
    @State public var activeIndex: Int = 0
    @State private var docCounter: Int = 1

    // Editor settings
    @State public var isDarkMode: Bool = false
    @State public var fontSize: CGFloat = 14
    @State public var isWordWrapEnabled: Bool = false

    // Find & Replace state
    @State public var isFindPresented: Bool = false
    @State public var findText: String = ""
    @State public var replaceText: String = ""
    @State public var matchCase: Bool = false
    @State public var wholeWord: Bool = false
    @State public var useRegex: Bool = false
    @State public var findStatus: String = ""

    // File Import / Export
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var exportDocument: PlainTextFile?

    public init() {}

    public var activeDoc: DocumentModel? {
        guard !documents.isEmpty && activeIndex < documents.count else { return nil }
        return documents[activeIndex]
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 1. Classic Notepad++ iPad Top Toolbar
            toolbarView

            // 2. Tab Bar with red/blue status disks
            if !documents.isEmpty {
                TabBarView_iPad(
                    documents: $documents,
                    activeIndex: $activeIndex,
                    isDarkMode: isDarkMode,
                    onNewTab: { createNewDocument() },
                    onCloseTab: { index in closeDocument(at: index) }
                )
            }

            // 3. Collapsible Find & Replace Panel
            FindReplaceBar_iPad(
                isPresented: $isFindPresented,
                findText: $findText,
                replaceText: $replaceText,
                matchCase: $matchCase,
                wholeWord: $wholeWord,
                regex: $useRegex,
                statusText: findStatus,
                onFindNext: { search(backwards: false) },
                onFindPrev: { search(backwards: true) },
                onReplace: { replaceCurrent() },
                onReplaceAll: { replaceAllOccurrences() },
                onCount: { countMatches() },
                isDarkMode: isDarkMode
            )

            // 4. Main Code Editor with Line Gutter
            if let doc = activeDoc {
                EditorView_iPad(
                    document: doc,
                    isDarkMode: isDarkMode,
                    fontSize: fontSize,
                    wordWrap: isWordWrapEnabled
                )
                .id(doc.id) // Reload editor when switching tabs
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Document Open")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button("Create New Document", action: { createNewDocument() })
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDarkMode ? Color(white: 0.12) : Color.white)
            }

            // 5. Classic Notepad++ Bottom Telemetry Status Bar
            if let doc = activeDoc {
                StatusBarView_iPad(document: doc, isDarkMode: isDarkMode)
            }
        }
        .onAppear {
            if documents.isEmpty {
                let welcome = """
// Welcome to Notepad++ for iPad Air M3! 🦎
// Authentic Notepad++ aesthetics, line ruler, syntax highlighting, and telemetry.
//
// Optimized for Apple Silicon M3, 11-inch Liquid Retina display,
// Apple Pencil (Scribble), and Magic Keyboard shortcuts.
//
// Shortcuts:
//   ⌘N: New File        ⌘O: Open File       ⌘S: Save File
//   ⌘F: Find/Replace    ⌘W: Close Tab       ⌘+ / ⌘-: Zoom Font
//
#include <iostream>

int main() {
    std::cout << "Hello from iPad Air M3!" << std::endl;
    return 0;
}
"""
                let doc = DocumentModel(title: "New 1", content: welcome)
                doc.language = .cpp
                documents.append(doc)
                activeIndex = 0
                docCounter = 2
            }
        }
        // iPadOS Files App file importer
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item, .text, .plainText, .sourceCode],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result: result)
        }
        // iPadOS Files App file exporter
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .plainText,
            defaultFilename: activeDoc?.title ?? "Document.txt"
        ) { result in
            handleFileExport(result: result)
        }
    }

    // MARK: - Toolbar View
    private var toolbarView: some View {
        HStack(spacing: 8) {
            // Notepad++ Chameleon Branding
            HStack(spacing: 6) {
                Text("🦎")
                    .font(.system(size: 18))
                Text("Notepad++")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : .primary)
            }
            .padding(.leading, 8)

            Divider().frame(height: 20)

            // File operations
            Button(action: { createNewDocument() }) {
                Image(systemName: "doc.badge.plus")
            }
            .keyboardShortcut("n", modifiers: .command)
            .help("New (⌘N)")

            Button(action: { isImporting = true }) {
                Image(systemName: "folder")
            }
            .keyboardShortcut("o", modifiers: .command)
            .help("Open File (⌘O)")

            Button(action: { saveActiveDocument() }) {
                Image(systemName: "square.and.arrow.down")
            }
            .keyboardShortcut("s", modifiers: .command)
            .help("Save (⌘S)")

            Button(action: {
                if let doc = activeDoc {
                    exportDocument = PlainTextFile(text: doc.content)
                    isExporting = true
                }
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .help("Export / Save As")

            Divider().frame(height: 20)

            // Find & Replace
            Button(action: { withAnimation { isFindPresented.toggle() } }) {
                Image(systemName: "magnifyingglass")
            }
            .keyboardShortcut("f", modifiers: .command)
            .help("Find & Replace (⌘F)")

            Divider().frame(height: 20)

            // Zoom In / Out
            Button(action: { fontSize = min(32, fontSize + 1) }) {
                Image(systemName: "plus.magnifyingglass")
            }
            .keyboardShortcut("+", modifiers: .command)
            .help("Zoom In (⌘+)")

            Button(action: { fontSize = max(9, fontSize - 1) }) {
                Image(systemName: "minus.magnifyingglass")
            }
            .keyboardShortcut("-", modifiers: .command)
            .help("Zoom Out (⌘-)")

            Button(action: { isWordWrapEnabled.toggle() }) {
                Image(systemName: isWordWrapEnabled ? "text.word.spacing" : "text.alignleft")
            }
            .foregroundColor(isWordWrapEnabled ? .accentColor : .primary)
            .help("Toggle Word Wrap")

            Divider().frame(height: 20)

            // Language Selector Menu
            Menu {
                ForEach(SyntaxLanguage.allCases) { lang in
                    Button(action: {
                        activeDoc?.language = lang
                    }) {
                        HStack {
                            Text(lang.rawValue)
                            if activeDoc?.language == lang {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(activeDoc?.language.rawValue ?? "Language")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isDarkMode ? Color(white: 0.22) : Color(white: 0.88))
                .cornerRadius(5)
            }

            Spacer()

            // Dark / Light Theme Toggle
            Button(action: { isDarkMode.toggle() }) {
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
            }
            .padding(.trailing, 8)
            .help("Toggle Theme")
        }
        .frame(height: 44)
        .padding(.horizontal, 6)
        .background(isDarkMode ? Color(white: 0.14) : Color(white: 0.94))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(isDarkMode ? Color(white: 0.24) : Color(white: 0.78)),
            alignment: .bottom
        )
    }

    // MARK: - Document Actions
    public func createNewDocument(initialContent: String = "", initialLanguage: SyntaxLanguage = .plainText) {
        let title = "New \(docCounter)"
        docCounter += 1
        let doc = DocumentModel(title: title, content: initialContent)
        doc.language = initialLanguage
        documents.append(doc)
        activeIndex = documents.count - 1
    }

    public func closeDocument(at index: Int) {
        guard index >= 0 && index < documents.count else { return }
        documents.remove(at: index)
        if documents.isEmpty {
            createNewDocument()
        } else {
            activeIndex = min(index, documents.count - 1)
        }
    }

    public func saveActiveDocument() {
        guard let doc = activeDoc else { return }
        if let url = doc.fileURL {
            let accessing = url.startAccessingSecurityScopedResource()
            do {
                try doc.content.write(to: url, atomically: true, encoding: .utf8)
                doc.markSaved(at: url)
            } catch {
                print("Failed to save: \(error)")
            }
            if accessing { url.stopAccessingSecurityScopedResource() }
        } else {
            exportDocument = PlainTextFile(text: doc.content)
            isExporting = true
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                let accessing = url.startAccessingSecurityScopedResource()
                if let content = try? String(contentsOf: url) {
                    let doc = DocumentModel(title: url.lastPathComponent, content: content, fileURL: url)
                    documents.append(doc)
                }
                if accessing { url.stopAccessingSecurityScopedResource() }
            }
            if !urls.isEmpty {
                activeIndex = documents.count - 1
            }
        case .failure(let error):
            print("Import error: \(error)")
        }
    }

    private func handleFileExport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            activeDoc?.markSaved(at: url)
        case .failure(let error):
            print("Export error: \(error)")
        }
    }

    // MARK: - Search & Replace Engine
    private func search(backwards: Bool) {
        guard !findText.isEmpty, let doc = activeDoc else { return }
        let text = doc.content as NSString
        var options: NSString.CompareOptions = []
        if !matchCase { options.insert(.caseInsensitive) }
        if backwards { options.insert(.backwards) }
        if useRegex { options.insert(.regularExpression) }

        var term = findText
        if wholeWord && !useRegex {
            term = "\\b\(NSRegularExpression.escapedPattern(for: findText))\\b"
            options.insert(.regularExpression)
        }

        let currentPos = doc.cursorPosition
        let searchRange = backwards
            ? NSRange(location: 0, length: currentPos)
            : NSRange(location: currentPos, length: text.length - currentPos)

        var match = text.range(of: term, options: options, range: searchRange)
        if match.location == NSNotFound {
            // Wrap around
            match = text.range(of: term, options: options, range: NSRange(location: 0, length: text.length))
        }

        if match.location != NSNotFound {
            doc.cursorPosition = match.location
            findStatus = "Found at pos \(match.location)"
        } else {
            findStatus = "Not found"
        }
    }

    private func replaceCurrent() {
        guard !findText.isEmpty, let doc = activeDoc else { return }
        let text = doc.content as NSString
        let selectedRange = NSRange(location: doc.cursorPosition, length: (findText as NSString).length)
        if selectedRange.location + selectedRange.length <= text.length &&
            text.substring(with: selectedRange).lowercased() == findText.lowercased() {
            let newText = text.replacingCharacters(in: selectedRange, with: replaceText)
            doc.content = newText
            doc.isModified = true
            doc.cursorPosition = selectedRange.location + (replaceText as NSString).length
        }
        search(backwards: false)
    }

    private func replaceAllOccurrences() {
        guard !findText.isEmpty, let doc = activeDoc else { return }
        let modified = doc.content.replacingOccurrences(of: findText, with: replaceText)
        doc.content = modified
        doc.isModified = true
        findStatus = "Replaced occurrences"
    }

    private func countMatches() {
        guard !findText.isEmpty, let doc = activeDoc else { return }
        let text = doc.content as NSString
        var options: NSString.CompareOptions = []
        if !matchCase { options.insert(.caseInsensitive) }
        if useRegex { options.insert(.regularExpression) }

        var count = 0
        var range = NSRange(location: 0, length: text.length)
        while range.location < text.length {
            let match = text.range(of: findText, options: options, range: range)
            if match.location == NSNotFound { break }
            count += 1
            let next = NSMaxRange(match)
            if next >= text.length { break }
            range = NSRange(location: next, length: text.length - next)
        }
        findStatus = "\(count) matches found"
    }
}

// Helper for iPadOS File Export
public struct PlainTextFile: FileDocument {
    public static var readableContentTypes: [UTType] { [.plainText, .text, .sourceCode] }
    public var text: String

    public init(text: String = "") {
        self.text = text
    }

    public init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.text = String(decoding: data, as: UTF8.self)
        } else {
            self.text = ""
        }
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
#endif
