#if os(iOS)
import SwiftUI

public struct StatusBarView_iPad: View {
    @ObservedObject public var document: DocumentModel
    public var isDarkMode: Bool

    public init(document: DocumentModel, isDarkMode: Bool) {
        self.document = document
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        let linesCount = (document.content as NSString).components(separatedBy: "\n").count
        let charCount = document.content.count

        HStack(spacing: 12) {
            Text("Ln : \(document.cursorLine)   Col : \(document.cursorCol)   Pos : \(document.cursorPosition)")
            Divider().frame(height: 12)
            Text("lines : \(linesCount)   length : \(charCount)")
            Divider().frame(height: 12)
            Text(document.lineEnding.rawValue)
            Divider().frame(height: 12)
            Text(document.encodingName)
            Divider().frame(height: 12)
            Text(document.language.rawValue)
            Divider().frame(height: 12)
            Text("INS")
            Spacer()
        }
        .font(.system(size: 11, design: .monospaced))
        .foregroundColor(isDarkMode ? Color(.lightGray) : Color(.secondaryLabel))
        .padding(.horizontal, 12)
        .frame(height: 24)
        .background(isDarkMode ? Color(white: 0.12) : Color(white: 0.93))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(isDarkMode ? Color(white: 0.22) : Color(white: 0.78)),
            alignment: .top
        )
    }
}
#endif
