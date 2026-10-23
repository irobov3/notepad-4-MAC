#if os(iOS)
import SwiftUI

public struct TabBarView_iPad: View {
    @Binding public var documents: [DocumentModel]
    @Binding public var activeIndex: Int
    public var isDarkMode: Bool
    public var onNewTab: () -> Void
    public var onCloseTab: (Int) -> Void

    public init(
        documents: Binding<[DocumentModel]>,
        activeIndex: Binding<Int>,
        isDarkMode: Bool,
        onNewTab: @escaping () -> Void,
        onCloseTab: @escaping (Int) -> Void
    ) {
        self._documents = documents
        self._activeIndex = activeIndex
        self.isDarkMode = isDarkMode
        self.onNewTab = onNewTab
        self.onCloseTab = onCloseTab
    }

    public var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(Array(documents.enumerated()), id: \.element.id) { index, doc in
                        let isSelected = (index == activeIndex)

                        Button(action: {
                            activeIndex = index
                        }) {
                            HStack(spacing: 6) {
                                // Notepad++ status dot: Red = modified, Blue = saved
                                Circle()
                                    .fill(doc.isModified ? Color(red: 0.95, green: 0.20, blue: 0.15) : Color(red: 0.05, green: 0.50, blue: 0.90))
                                    .frame(width: 7, height: 7)

                                Text(doc.title)
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                    .foregroundColor(isSelected ? (isDarkMode ? .white : .primary) : (isDarkMode ? Color(.lightGray) : .secondary))
                                    .lineLimit(1)

                                Button(action: {
                                    onCloseTab(index)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(isDarkMode ? Color(.lightGray) : Color(.secondaryLabel))
                                        .padding(4)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected
                                          ? (isDarkMode ? Color(white: 0.18) : Color.white)
                                          : (isDarkMode ? Color(white: 0.12) : Color(white: 0.88)))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected
                                            ? (isDarkMode ? Color(white: 0.35) : Color(white: 0.70))
                                            : (isDarkMode ? Color(white: 0.20) : Color(white: 0.80)), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // "+" New Tab Button
                    Button(action: onNewTab) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isDarkMode ? .white : Color(.label))
                            .frame(width: 28, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isDarkMode ? Color(white: 0.15) : Color(white: 0.88))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isDarkMode ? Color(white: 0.25) : Color(white: 0.75), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .frame(height: 36)
        .background(isDarkMode ? Color(white: 0.10) : Color(white: 0.92))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(isDarkMode ? Color(white: 0.22) : Color(white: 0.78)),
            alignment: .bottom
        )
    }
}
#endif
