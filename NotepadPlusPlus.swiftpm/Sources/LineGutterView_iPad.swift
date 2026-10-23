#if os(iOS)
import UIKit

public class LineGutterView_iPad: UIView {
    public weak var textView: UITextView? {
        didSet { setNeedsDisplay() }
    }
    public var theme: SyntaxTheme = .classic {
        didSet {
            backgroundColor = theme.gutterColor
            setNeedsDisplay()
        }
    }
    public var gutterWidth: CGFloat = 46.0 {
        didSet { setNeedsDisplay() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = theme.gutterColor
        isOpaque = true
        clipsToBounds = true
        contentMode = .redraw
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext(), let tv = textView else { return }

        // 1. Fill gutter background
        ctx.setFillColor(theme.gutterColor.cgColor)
        ctx.fill(bounds)

        // 2. Draw right border hairline
        let separatorColor = UIColor.separator.cgColor
        ctx.setStrokeColor(separatorColor)
        ctx.setLineWidth(1.0 / UIScreen.main.scale)
        ctx.move(to: CGPoint(x: bounds.width - 0.5, y: 0))
        ctx.addLine(to: CGPoint(x: bounds.width - 0.5, y: bounds.height))
        ctx.strokePath()

        // 3. Draw line numbers
        let layoutManager = tv.layoutManager
        let textStorage = tv.textStorage

        let text = textStorage.string as NSString
        let textLength = text.length

        let font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: theme.gutterTextColor
        ]

        var lineNumber = 1
        var glyphIndex = 0
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        let contentOffsetY = tv.contentOffset.y
        let insetTop = tv.textContainerInset.top

        while glyphIndex < numberOfGlyphs {
            let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            var lineRange = NSRange()
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange)

            if charIndex == 0 || (charIndex > 0 && text.character(at: charIndex - 1) == 0x0A) {
                let y = lineRect.origin.y + insetTop - contentOffsetY
                if y >= -20 && y <= bounds.height + 20 {
                    let lineStr = "\(lineNumber)" as NSString
                    let size = lineStr.size(withAttributes: attributes)
                    let drawPoint = CGPoint(x: bounds.width - size.width - 8, y: y)
                    lineStr.draw(at: drawPoint, withAttributes: attributes)
                }
                lineNumber += 1
            }

            glyphIndex = NSMaxRange(lineRange)
        }

        if textLength == 0 {
            let y = insetTop - contentOffsetY
            let lineStr = "1" as NSString
            let size = lineStr.size(withAttributes: attributes)
            let drawPoint = CGPoint(x: bounds.width - size.width - 8, y: y)
            lineStr.draw(at: drawPoint, withAttributes: attributes)
        }
    }
}
#endif
