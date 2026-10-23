#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

public enum SyntaxLanguage: String, CaseIterable, Identifiable {
    case plainText = "Normal text"
    case c = "C"
    case cpp = "C++"
    case python = "Python"
    case javascript = "JavaScript"
    case typescript = "TypeScript"
    case html = "HTML"
    case xml = "XML"
    case json = "JSON"
    case markdown = "Markdown"
    case sql = "SQL"
    case swift = "Swift"
    case shell = "Shell / Bash"

    public var id: String { rawValue }

    public static func detect(from path: String) -> SyntaxLanguage {
        let ext = (path as NSString).pathExtension.lowercased()
        switch ext {
        case "c", "h": return .c
        case "cpp", "cxx", "cc", "hpp": return .cpp
        case "py": return .python
        case "js", "mjs", "cjs": return .javascript
        case "ts", "tsx": return .typescript
        case "html", "htm": return .html
        case "xml", "plist": return .xml
        case "json": return .json
        case "md", "markdown": return .markdown
        case "sql": return .sql
        case "swift": return .swift
        case "sh", "bash", "zsh": return .shell
        default: return .plainText
        }
    }
}

public struct SyntaxTheme: @unchecked Sendable {
    public let name: String
    public let backgroundColor: PlatformColor
    public let textColor: PlatformColor
    public let gutterColor: PlatformColor
    public let gutterTextColor: PlatformColor
    public let selectionColor: PlatformColor
    public let currentLineColor: PlatformColor
    public let keywordColor: PlatformColor
    public let stringColor: PlatformColor
    public let commentColor: PlatformColor
    public let numberColor: PlatformColor
    public let preprocessorColor: PlatformColor

    public static let classic = SyntaxTheme(
        name: "Notepad++ Classic",
        backgroundColor: .rgb(1.0, 1.0, 1.0),
        textColor: .rgb(0.0, 0.0, 0.0),
        gutterColor: .rgb(0.94, 0.94, 0.94),
        gutterTextColor: .rgb(0.5, 0.5, 0.5),
        selectionColor: .rgb(0.76, 0.85, 1.0, 0.7),
        currentLineColor: .rgb(0.95, 0.98, 1.0, 0.8),
        keywordColor: .rgb(0.0, 0.0, 0.8),
        stringColor: .rgb(0.5, 0.5, 0.5),
        commentColor: .rgb(0.0, 0.5, 0.0),
        numberColor: .rgb(1.0, 0.4, 0.0),
        preprocessorColor: .rgb(0.5, 0.0, 0.5)
    )

    public static let darkMode = SyntaxTheme(
        name: "Notepad++ Dark Mode",
        backgroundColor: .rgb(0.12, 0.12, 0.12),
        textColor: .rgb(0.86, 0.86, 0.86),
        gutterColor: .rgb(0.16, 0.16, 0.16),
        gutterTextColor: .rgb(0.45, 0.45, 0.45),
        selectionColor: .rgb(0.2, 0.35, 0.55, 0.8),
        currentLineColor: .rgb(0.18, 0.18, 0.2, 0.7),
        keywordColor: .rgb(0.35, 0.65, 0.95),
        stringColor: .rgb(0.85, 0.6, 0.45),
        commentColor: .rgb(0.4, 0.65, 0.35),
        numberColor: .rgb(0.7, 0.85, 0.65),
        preprocessorColor: .rgb(0.8, 0.5, 0.85)
    )
}

public class SyntaxHighlighter {
    public static func highlight(textStorage: NSTextStorage, language: SyntaxLanguage, theme: SyntaxTheme, font: PlatformFont) {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        guard fullRange.length > 0 else { return }

        textStorage.beginEditing()
        textStorage.removeAttribute(.foregroundColor, range: fullRange)
        textStorage.addAttribute(.foregroundColor, value: theme.textColor, range: fullRange)
        textStorage.addAttribute(.font, value: font, range: fullRange)

        let string = textStorage.string as NSString

        if language == .plainText {
            textStorage.endEditing()
            return
        }

        // 1. Comments
        let commentPatterns: [String]
        switch language {
        case .c, .cpp, .javascript, .typescript, .swift, .json:
            commentPatterns = ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        case .python, .shell:
            commentPatterns = ["#.*$"]
        case .html, .xml, .markdown:
            commentPatterns = ["<!--[\\s\\S]*?-->"]
        case .sql:
            commentPatterns = ["--.*$", "/\\*[\\s\\S]*?\\*/"]
        case .plainText:
            commentPatterns = []
        }

        for pattern in commentPatterns {
            applyRegex(pattern, to: string, in: textStorage, options: [.anchorsMatchLines]) { range in
                textStorage.addAttribute(.foregroundColor, value: theme.commentColor, range: range)
            }
        }

        // 2. Strings
        let stringPatterns = ["\"(\\\\.|[^\"\\\\])*\"", "'(\\\\.|[^'\\\\])*'"]
        for pattern in stringPatterns {
            applyRegex(pattern, to: string, in: textStorage) { range in
                textStorage.addAttribute(.foregroundColor, value: theme.stringColor, range: range)
            }
        }

        // 3. Numbers
        let numberPattern = "\\b(?:0[xX][0-9a-fA-F]+|\\d+\\.?\\d*)\\b"
        applyRegex(numberPattern, to: string, in: textStorage) { range in
            textStorage.addAttribute(.foregroundColor, value: theme.numberColor, range: range)
        }

        // 4. Preprocessor (for C/C++)
        if language == .c || language == .cpp {
            applyRegex("^\\s*#[a-zA-Z_]+", to: string, in: textStorage, options: [.anchorsMatchLines]) { range in
                textStorage.addAttribute(.foregroundColor, value: theme.preprocessorColor, range: range)
            }
        }

        // 5. Keywords
        let keywords = getKeywords(for: language)
        if !keywords.isEmpty {
            let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
            applyRegex(keywordPattern, to: string, in: textStorage) { range in
                textStorage.addAttribute(.foregroundColor, value: theme.keywordColor, range: range)
            }
        }

        textStorage.endEditing()
    }

    private static func applyRegex(_ pattern: String, to string: NSString, in textStorage: NSTextStorage, options: NSRegularExpression.Options = [], apply: (NSRange) -> Void) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
        let matches = regex.matches(in: string as String, range: NSRange(location: 0, length: string.length))
        for match in matches {
            apply(match.range)
        }
    }

    private static func getKeywords(for language: SyntaxLanguage) -> [String] {
        switch language {
        case .c, .cpp:
            return ["auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "int", "long", "register", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "class", "namespace", "new", "delete", "this", "public", "protected", "private", "template", "typename", "using", "virtual", "override", "nullptr", "bool", "true", "false", "constexpr", "try", "catch", "throw"]
        case .python:
            return ["and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del", "elif", "else", "except", "False", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "None", "nonlocal", "not", "or", "pass", "raise", "return", "True", "try", "while", "with", "yield"]
        case .javascript, .typescript:
            return ["break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete", "do", "else", "export", "extends", "finally", "for", "function", "if", "import", "in", "instanceof", "new", "return", "super", "switch", "this", "throw", "try", "typeof", "var", "void", "while", "with", "yield", "let", "static", "async", "await", "true", "false", "null", "undefined", "interface", "type", "enum", "namespace", "as"]
        case .swift:
            return ["associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup", "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var", "break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while", "as", "Any", "false", "is", "nil", "self", "Self", "super", "true", "try"]
        case .sql:
            return ["SELECT", "FROM", "WHERE", "INSERT", "UPDATE", "DELETE", "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "ON", "GROUP", "BY", "ORDER", "HAVING", "LIMIT", "OFFSET", "CREATE", "TABLE", "INDEX", "DROP", "ALTER", "ADD", "CONSTRAINT", "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "AND", "OR", "NOT", "NULL", "IS", "IN", "LIKE", "AS", "DISTINCT", "UNION", "ALL", "EXISTS", "BETWEEN", "CASE", "WHEN", "THEN", "END", "ELSE"]
        case .shell:
            return ["if", "then", "else", "elif", "fi", "case", "esac", "for", "select", "while", "until", "do", "done", "in", "function", "time", "return", "exit", "export", "local", "alias", "echo"]
        case .html, .xml:
            return ["html", "head", "body", "div", "span", "p", "a", "script", "style", "link", "meta", "title", "table", "tr", "td", "th", "input", "button", "form"]
        case .json:
            return ["true", "false", "null"]
        case .markdown, .plainText:
            return []
        }
    }
}
