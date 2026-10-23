#if os(iOS)
import UIKit

public class AccessoryBar_iPad: UIView {
    public weak var targetTextView: UITextView?

    public init(textView: UITextView) {
        self.targetTextView = textView
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        setupUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.secondarySystemBackground
        autoresizingMask = [.flexibleWidth]

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        // 1. Indentation & Navigation buttons
        let tabBtn = makeButton(title: "⇥ Tab", action: #selector(handleTab))
        let untabBtn = makeButton(title: "⇤ Untab", action: #selector(handleUntab))
        let undoBtn = makeIconButton(systemName: "arrow.uturn.backward", action: #selector(handleUndo))
        let redoBtn = makeIconButton(systemName: "arrow.uturn.forward", action: #selector(handleRedo))
        let leftBtn = makeIconButton(systemName: "chevron.left", action: #selector(handleLeft))
        let rightBtn = makeIconButton(systemName: "chevron.right", action: #selector(handleRight))
        let dismissBtn = makeIconButton(systemName: "keyboard.chevron.compact.down", action: #selector(handleDismiss))

        [tabBtn, untabBtn, undoBtn, redoBtn, leftBtn, rightBtn].forEach { stack.addArrangedSubview($0) }
        stack.addArrangedSubview(makeSeparator())

        // 2. Common Code Symbols
        let symbols = ["{", "}", "(", ")", "[", "]", "<", ">", ";", ":", "\"", "'", "`", "=", "+", "-", "*", "/", "\\", "_", "$", "@", "&", "|", "!", "?"]
        for sym in symbols {
            let btn = makeButton(title: sym, action: #selector(handleSymbol(_:)))
            stack.addArrangedSubview(btn)
        }

        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(dismissBtn)
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor.tertiarySystemBackground
        config.baseForegroundColor = UIColor.label
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 6
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    private func makeIconButton(systemName: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        config.baseBackgroundColor = UIColor.tertiarySystemBackground
        config.baseForegroundColor = UIColor.label
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 6
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    private func makeSeparator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = UIColor.separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.widthAnchor.constraint(equalToConstant: 1).isActive = true
        sep.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return sep
    }

    @objc private func handleTab() {
        targetTextView?.insertText("    ")
    }

    @objc private func handleUntab() {
        guard let tv = targetTextView else { return }
        let selectedRange = tv.selectedRange
        let text = tv.text as NSString
        let lineRange = text.lineRange(for: selectedRange)
        let lineStr = text.substring(with: lineRange)
        if lineStr.hasPrefix("    ") {
            let newText = text.replacingCharacters(in: NSRange(location: lineRange.location, length: 4), with: "")
            tv.text = newText
            tv.selectedRange = NSRange(location: max(0, selectedRange.location - 4), length: selectedRange.length)
            tv.delegate?.textViewDidChange?(tv)
        }
    }

    @objc private func handleUndo() {
        targetTextView?.undoManager?.undo()
    }

    @objc private func handleRedo() {
        targetTextView?.undoManager?.redo()
    }

    @objc private func handleLeft() {
        guard let tv = targetTextView else { return }
        let newPos = max(0, tv.selectedRange.location - 1)
        tv.selectedRange = NSRange(location: newPos, length: 0)
    }

    @objc private func handleRight() {
        guard let tv = targetTextView else { return }
        let newPos = min((tv.text as NSString).length, tv.selectedRange.location + 1)
        tv.selectedRange = NSRange(location: newPos, length: 0)
    }

    @objc private func handleDismiss() {
        targetTextView?.resignFirstResponder()
    }

    @objc private func handleSymbol(_ sender: UIButton) {
        guard let title = sender.configuration?.title ?? sender.currentTitle else { return }
        targetTextView?.insertText(title)
    }
}
#endif
