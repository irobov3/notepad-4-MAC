#if os(iOS)
import SwiftUI

public struct FindReplaceBar_iPad: View {
    @Binding public var isPresented: Bool
    @Binding public var findText: String
    @Binding public var replaceText: String
    @Binding public var matchCase: Bool
    @Binding public var wholeWord: Bool
    @Binding public var regex: Bool
    public var statusText: String
    public var onFindNext: () -> Void
    public var onFindPrev: () -> Void
    public var onReplace: () -> Void
    public var onReplaceAll: () -> Void
    public var onCount: () -> Void
    public var isDarkMode: Bool

    public init(
        isPresented: Binding<Bool>,
        findText: Binding<String>,
        replaceText: Binding<String>,
        matchCase: Binding<Bool>,
        wholeWord: Binding<Bool>,
        regex: Binding<Bool>,
        statusText: String,
        onFindNext: @escaping () -> Void,
        onFindPrev: @escaping () -> Void,
        onReplace: @escaping () -> Void,
        onReplaceAll: @escaping () -> Void,
        onCount: @escaping () -> Void,
        isDarkMode: Bool
    ) {
        self._isPresented = isPresented
        self._findText = findText
        self._replaceText = replaceText
        self._matchCase = matchCase
        self._wholeWord = wholeWord
        self._regex = regex
        self.statusText = statusText
        self.onFindNext = onFindNext
        self.onFindPrev = onFindPrev
        self.onReplace = onReplace
        self.onReplaceAll = onReplaceAll
        self.onCount = onCount
        self.isDarkMode = isDarkMode
    }

    public var body: some View {
        if isPresented {
            VStack(spacing: 8) {
                // Top Row: Find text, Find Next/Prev, Count, Status, Close
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Find what...", text: $findText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color(white: 0.22) : Color.white)
                    .cornerRadius(6)
                    .frame(maxWidth: 240)

                    Button("Next", action: onFindNext)
                        .buttonStyle(.borderedProminent)
                        .tint(Color.accentColor)

                    Button("Prev", action: onFindPrev)
                        .buttonStyle(.bordered)

                    Button("Count", action: onCount)
                        .buttonStyle(.bordered)

                    if !statusText.isEmpty {
                        Text(statusText)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }

                // Bottom Row: Replace text, Replace/Replace All, Toggles (Match case, Whole word, Regex)
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                        TextField("Replace with...", text: $replaceText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color(white: 0.22) : Color.white)
                    .cornerRadius(6)
                    .frame(maxWidth: 240)

                    Button("Replace", action: onReplace)
                        .buttonStyle(.bordered)

                    Button("Replace All", action: onReplaceAll)
                        .buttonStyle(.bordered)

                    Spacer().frame(width: 8)

                    Toggle("Match case", isOn: $matchCase)
                        .toggleStyle(CheckToggleStyle())

                    Toggle("Whole word", isOn: $wholeWord)
                        .toggleStyle(CheckToggleStyle())

                    Toggle("Regex", isOn: $regex)
                        .toggleStyle(CheckToggleStyle())

                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isDarkMode ? Color(white: 0.15) : Color(white: 0.94))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(isDarkMode ? Color(white: 0.25) : Color(white: 0.78)),
                alignment: .bottom
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

public struct CheckToggleStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 4) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                    .font(.system(size: 13))
                configuration.label
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
#endif
