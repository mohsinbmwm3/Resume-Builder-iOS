import UIKit

enum Attr {
    private static func font(_ name: String, size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if let f = UIFont(name: name, size: size) { return f }
        return .systemFont(ofSize: size, weight: weight)
    }

    static func header(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle(); p.minimumLineHeight = 20; p.maximumLineHeight = 20
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label,
            .paragraphStyle: p
        ])
    }

    static func subheader(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle(); p.minimumLineHeight = 16; p.maximumLineHeight = 16
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.label
        ])
    }

    static func caption(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle(); p.alignment = .left
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: p
        ])
    }

    static func sectionTitle(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle()
        p.paragraphSpacingBefore = 10
        p.paragraphSpacing = 4
        return NSAttributedString(string: text.uppercased(), attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.label,
            .paragraphStyle: p
        ])
    }

    static func itemTitle(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.label
        ])
    }

    static func body(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle(); p.lineBreakMode = .byWordWrapping
        p.minimumLineHeight = 13; p.maximumLineHeight = 13
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.label,
            .paragraphStyle: p
        ])
    }

    static func bullet(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle()
        p.headIndent = 12
        p.firstLineHeadIndent = 12
        p.paragraphSpacing = 2
        p.minimumLineHeight = 13
        p.maximumLineHeight = 13
        return NSAttributedString(string: "• " + text, attributes: [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.label,
            .paragraphStyle: p
        ])
    }
    
    static func links(text: String) -> NSAttributedString {
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.systemBlue,  // looks link-ish
            .paragraphStyle: p
        ])
    }
    
    static func roleLine(company: String, role: String?, dates: String?, location: String?) -> NSAttributedString {
        let line = NSMutableAttributedString()
        // Company (bold)
        line.append(NSAttributedString(string: company, attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.label
        ]))
        // Tail parts (skip empties)
        var tail: [String] = []
        if let role, !role.isEmpty { tail.append(role) }
        if let dates, !dates.isEmpty { tail.append(dates) }
        if let loc = location?.trimmingCharacters(in: .whitespacesAndNewlines), !loc.isEmpty {
            tail.append(loc) // no trailing comma
        }
        if !tail.isEmpty {
            line.append(NSAttributedString(string: "  •  " + tail.joined(separator: "  •  "), attributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.secondaryLabel
            ]))
        }
        let p = NSMutableParagraphStyle()
        p.lineBreakMode = .byWordWrapping
        line.addAttribute(.paragraphStyle, value: p, range: NSRange(location: 0, length: line.length))
        return line
    }
}

