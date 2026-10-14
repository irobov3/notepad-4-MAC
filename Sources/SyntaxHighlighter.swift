import Cocoa

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

public struct SyntaxTheme {
    public let name: String
    public let backgroundColor: NSColor
    public let textColor: NSColor
    public let gutterColor: NSColor
    public let gutterTextColor: NSColor
    public let selectionColor: NSColor
    public let currentLineColor: NSColor
    public let keywordColor: NSColor
    public let stringColor: NSColor
    public let commentColor: NSColor
    public let numberColor: NSColor
    public let preprocessorColor: NSColor

    public static let classic = SyntaxTheme(
        name: "Notepad++ Classic",
        backgroundColor: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        textColor: NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        gutterColor: NSColor(calibratedRed: 0.94, green: 0.94, blue: 0.94, alpha: 1.0),
        gutterTextColor: NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
        selectionColor: NSColor(calibratedRed: 0.76, green: 0.85, blue: 1.0, alpha: 0.7),
        currentLineColor: NSColor(calibratedRed: 0.95, green: 0.98, blue: 1.0, alpha: 0.8),
        keywordColor: NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.8, alpha: 1.0),
        stringColor: NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
        commentColor: NSColor(calibratedRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
        numberColor: NSColor(calibratedRed: 1.0, green: 0.4, blue: 0.0, alpha: 1.0),
        preprocessorColor: NSColor(calibratedRed: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
    )

    public static let darkMode = SyntaxTheme(
        name: "Notepad++ Dark Mode",
        backgroundColor: NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.12, alpha: 1.0),
        textColor: NSColor(calibratedRed: 0.86, green: 0.86, blue: 0.86, alpha: 1.0),
        gutterColor: NSColor(calibratedRed: 0.16, green: 0.16, blue: 0.16, alpha: 1.0),
        gutterTextColor: NSColor(calibratedRed: 0.45, green: 0.45, blue: 0.45, alpha: 1.0),
        selectionColor: NSColor(calibratedRed: 0.2, green: 0.35, blue: 0.55, alpha: 0.8),
        currentLineColor: NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.2, alpha: 0.7),
        keywordColor: NSColor(calibratedRed: 0.35, green: 0.65, blue: 0.95, alpha: 1.0),
        stringColor: NSColor(calibratedRed: 0.85, green: 0.6, blue: 0.45, alpha: 1.0),
        commentColor: NSColor(calibratedRed: 0.4, green: 0.65, blue: 0.35, alpha: 1.0),
        numberColor: NSColor(calibratedRed: 0.7, green: 0.85, blue: 0.65, alpha: 1.0),
        preprocessorColor: NSColor(calibratedRed: 0.8, green: 0.5, blue: 0.85, alpha: 1.0)
    )
}

public class SyntaxHighlighter {
    public static func highlight(textStorage: NSTextStorage, language: SyntaxLanguage, theme: SyntaxTheme, font: NSFont) {
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
