import Foundation
import Combine

public enum LineEnding: String, CaseIterable {
    case crlf = "Windows (CR LF)"
    case lf = "Unix (LF)"
    case cr = "Macintosh (CR)"

    public var stringValue: String {
        switch self {
        case .crlf: return "\r\n"
        case .lf: return "\n"
        case .cr: return "\r"
        }
    }
}

public class DocumentModel: Identifiable, ObservableObject {
    public let id: UUID = UUID()
    @Published public var title: String
    @Published public var fileURL: URL?
    @Published public var content: String
    @Published public var isModified: Bool = false
    @Published public var encodingName: String = "UTF-8"
    @Published public var lineEnding: LineEnding = .lf
    @Published public var language: SyntaxLanguage = .plainText
    @Published public var cursorLine: Int = 1
    @Published public var cursorCol: Int = 1
    @Published public var cursorPosition: Int = 0
    @Published public var selectionLength: Int = 0

    public init(title: String, content: String = "", fileURL: URL? = nil) {
        self.title = title
        self.content = content
        self.fileURL = fileURL
        if let url = fileURL {
            self.language = SyntaxLanguage.detect(from: url.path)
            self.title = url.lastPathComponent
        }
    }

    public func markSaved(at url: URL) {
        self.fileURL = url
        self.title = url.lastPathComponent
        self.isModified = false
        self.language = SyntaxLanguage.detect(from: url.path)
    }
}
