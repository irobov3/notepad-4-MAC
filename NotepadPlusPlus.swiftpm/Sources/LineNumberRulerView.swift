#if os(macOS)
import Cocoa

public class LineNumberRulerView: NSRulerView {
    public var theme: SyntaxTheme = .classic {
        didSet { needsDisplay = true }
    }

    public init(scrollView: NSScrollView, textView: NSTextView) {
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        self.clientView = textView
        self.ruleThickness = 48
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var isFlipped: Bool {
        return true
    }

    public override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = clientView as? NSTextView,
              let layoutManager = textView.layoutManager else { return }

        // CRITICAL: Only fill the ruler gutter bounds (48px wide), NEVER the unbounded dirty rect!
        let gutterRect = NSRect(x: 0, y: 0, width: ruleThickness, height: bounds.height)
        theme.gutterColor.setFill()
        gutterRect.fill()

        // Separator hairline on right edge of gutter
        NSColor.separatorColor.setStroke()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: ruleThickness - 0.5, y: 0))
        path.line(to: NSPoint(x: ruleThickness - 0.5, y: bounds.height))
        path.lineWidth = 1
        path.stroke()

        let text = textView.string as NSString
        let textLength = text.length
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: theme.gutterTextColor
        ]

        var lineNumber = 1
        var glyphIndex = 0

        while glyphIndex < layoutManager.numberOfGlyphs {
            let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            var lineRange = NSRange()
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange)

            if charIndex == 0 || (charIndex > 0 && text.character(at: charIndex - 1) == 0x0A) {
                let pointInTextView = NSPoint(x: 0, y: lineRect.origin.y + textView.textContainerInset.height)
                let y = self.convert(pointInTextView, from: textView).y
                if y >= -20 && y <= bounds.height + 20 {
                    let lineStr = "\(lineNumber)" as NSString
                    let stringSize = lineStr.size(withAttributes: attributes)
                    let drawPoint = NSPoint(x: ruleThickness - stringSize.width - 8, y: y)
                    lineStr.draw(at: drawPoint, withAttributes: attributes)
                }
                lineNumber += 1
            }

            glyphIndex = NSMaxRange(lineRange)
        }

        if textLength == 0 {
            let pointInTextView = NSPoint(x: 0, y: textView.textContainerInset.height)
            let y = self.convert(pointInTextView, from: textView).y
            let lineStr = "1" as NSString
            let stringSize = lineStr.size(withAttributes: attributes)
            let drawPoint = NSPoint(x: ruleThickness - stringSize.width - 8, y: y)
            lineStr.draw(at: drawPoint, withAttributes: attributes)
        }
    }
}
#endif
