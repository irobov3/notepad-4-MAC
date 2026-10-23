import Foundation

#if os(macOS)
import AppKit

public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont

public extension NSColor {
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> NSColor {
        return NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
    }
}

public extension NSFont {
    static func monospaced(size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
    }
}

#elseif os(iOS)
import UIKit

public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont

public extension UIColor {
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public extension UIFont {
    static func monospaced(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
    }
}
#endif
