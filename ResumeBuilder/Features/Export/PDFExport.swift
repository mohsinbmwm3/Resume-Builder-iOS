import UIKit
import CoreText

enum PDFExportError: Error { case renderFailed }

enum PDFPageFormat {
    case usLetter   // 8.5 x 11 in @ 72 dpi
    case a4         // 210 x 297 mm @ 72 dpi

    var size: CGSize {
        switch self {
        case .usLetter: return CGSize(width: 612, height: 792)
        case .a4:       return CGSize(width: 595, height: 842)
        }
    }
}

enum PDFExport {
    // Margins (top/left/bottom/right)
    static let contentInsets = UIEdgeInsets(top: 48, left: 48, bottom: 48, right: 48)
    
    private struct LinkToken {
        let label: String
        let url: URL
    }
    
    private static func tokens(from items: [LinkItem]) -> [LinkToken] {
        items.compactMap { item in
            guard let url = URL(string: item.url.trimmingCharacters(in: .whitespacesAndNewlines)),
                  !item.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  url.scheme != nil
            else { return nil }
            return LinkToken(label: item.label, url: url)
        }
    }

    /// Public entry
    static func makePDF(resume: Resume, pageFormat: PDFPageFormat = .usLetter) throws -> Data {
        switch resume.layoutMode {
        case .structured:
            return try makeStructuredPDF(resume, pageSize: pageFormat.size)
        case .freeform:
            return try makeFreeformPDF(resume, pageSize: pageFormat.size)
        }
    }

    // MARK: - Structured (ATS-friendly)

    private static func makeStructuredPDF(_ resume: Resume, pageSize: CGSize) throws -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        return renderer.pdfData { ctx in
            ctx.beginPage()

            let contentRect = CGRect(
                x: contentInsets.left,
                y: contentInsets.top,
                width: pageSize.width - contentInsets.left - contentInsets.right,
                height: pageSize.height - contentInsets.top - contentInsets.bottom
            )

            var y = contentRect.minY
            var pageIndex = 1
            let lineSpacing: CGFloat = 10

            // Helper: accurate text measurement using CoreText
            func suggestedHeight(for attr: NSAttributedString, width: CGFloat) -> CGFloat {
                let framesetter = CTFramesetterCreateWithAttributedString(attr as CFAttributedString)
                var fitRange = CFRange(location: 0, length: 0)
                let size = CTFramesetterSuggestFrameSizeWithConstraints(
                    framesetter,
                    CFRange(location: 0, length: attr.length),
                    nil,
                    CGSize(width: width, height: .greatestFiniteMagnitude),
                    &fitRange
                )
                return ceil(size.height)
            }

            func drawFooter(page: Int) {
                let footerText = "\(resume.person.fullName) · Page \(page)"
                let footer = NSAttributedString(
                    string: footerText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 9),
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                )
                let size = footer.size()
                // Footer position: 16pt from bottom edge
                // Using UIKit drawing which expects top-left origin
                let footerY = pageSize.height - contentInsets.bottom - 16 - size.height
                let rect = CGRect(
                    x: contentRect.minX,
                    y: footerY,
                    width: size.width,
                    height: size.height
                )
                footer.draw(in: rect)
            }
            
            func newPageIfNeeded(for height: CGFloat) {
                if y + height > contentRect.maxY {
                    // Draw footer on current page before starting new one
                    if pageIndex > 1 {
                        drawFooter(page: pageIndex)
                    }
                    ctx.beginPage()               // start a new page
                    pageIndex += 1
                    y = contentRect.minY          // reset cursor
                }
            }

            func drawLinksRow(_ items: [LinkItem]) {
                let ts = tokens(from: items)
                guard !ts.isEmpty else { return }
                
                let labelsJoined = ts.map(\.label).joined(separator: "  •  ")
                let attr = Attr.links(text: labelsJoined)
                let rowHeight = suggestedHeight(for: attr, width: contentRect.width)
                newPageIfNeeded(for: rowHeight)
                
                var x = contentRect.minX
                let baseY = y
                
                for (i, t) in ts.enumerated() {
                    let titleAttr = Attr.links(text: t.label)
                    let size = titleAttr.size()
                    let rect = CGRect(x: x, y: baseY, width: size.width, height: size.height)
                    
                    titleAttr.draw(in: rect)
                    // Make clickable - ctx.setURL needs Core Graphics coordinates (bottom-left origin)
                    let urlRect = CGRect(
                        x: x,
                        y: pageSize.height - baseY - size.height,
                        width: size.width,
                        height: size.height
                    )
                    ctx.setURL(t.url, for: urlRect) // clickable region over the label
                    
                    x = rect.maxX
                    if i < ts.count - 1 {
                        let sep = Attr.links(text: "  •  ")
                        let sepSize = sep.size()
                        let sepRect = CGRect(x: x, y: baseY, width: sepSize.width, height: sepSize.height)
                        sep.draw(in: sepRect)
                        x = sepRect.maxX
                    }
                }
                
                y += rowHeight + lineSpacing
            }
            
            func draw(_ attr: NSAttributedString) {
                let h = suggestedHeight(for: attr, width: contentRect.width)
                newPageIfNeeded(for: h)
                let rect = CGRect(x: contentRect.minX, y: y, width: contentRect.width, height: h)
                attr.draw(in: rect)             // UIKit text drawing (upright, no flips)
                y += h + lineSpacing
            }

            // Header
            draw(Attr.header(text: resume.person.fullName))
            draw(Attr.subheader(text: resume.person.headline))
            
            // Build contact row safely (no trailing commas or double spaces)
            let contactBits = [resume.person.email, resume.person.phone, resume.person.location]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            draw(Attr.caption(text: contactBits.joined(separator: " • ")))
            
            // Make email clickable
            let email = resume.person.email.trimmingCharacters(in: .whitespacesAndNewlines)
            if !contactBits.isEmpty, !email.isEmpty {
                if let mail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "mailto:\(mail)") {
                    let title = Attr.caption(text: contactBits.joined(separator: " • "))
                    let h = suggestedHeight(for: title, width: contentRect.width)
                    // Draw rect uses top-left, but setURL needs bottom-left origin
                    let drawY = y - (h + lineSpacing)
                    let urlRect = CGRect(
                        x: contentRect.minX,
                        y: pageSize.height - drawY - h,
                        width: contentRect.width,
                        height: h
                    )
                    ctx.setURL(url, for: urlRect)
                }
            }
            
            // Links row with clickable URLs
            drawLinksRow(resume.person.links)

            // Draw footer on last page if multi-page
            func finalizePDF() {
                if pageIndex > 1 {
                    drawFooter(page: pageIndex)
                }
            }
            
            // Sections & items
            for section in resume.sections where section.isVisible {
                draw(Attr.sectionTitle(text: section.title))
                for item in section.items {
                    // For Summary section, if headline is empty, just draw bullets
                    if section.kind == .summary && item.headline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Summary section: just draw bullets directly
                        for b in item.bullets { draw(Attr.body(text: b)) }
                    } else {
                        // Format dates
                        let dates: String? = {
                            switch (item.startDate, item.endDate) {
                            case let (s?, e?): return DateFormatter.resumeRange(s, e)
                            case let (s?, nil): return DateFormatter.resumeRange(s, Date())
                            default: return nil
                            }
                        }()
                        
                        // Use roleLine for better formatting
                        draw(Attr.roleLine(
                            company: item.headline,
                            role: item.subheadline,
                            dates: dates,
                            location: item.meta["location"]
                        ))
                        
                        for b in item.bullets { draw(Attr.bullet(text: b)) }
                    }
                }
            }
            
            // Draw footer on last page
            finalizePDF()
        }
    }

    // MARK: - Free-form (canvas blocks)

    private static func makeFreeformPDF(_ resume: Resume, pageSize: CGSize) throws -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        return renderer.pdfData { ctx in
            ctx.beginPage()
            let cg = ctx.cgContext

            // Draw each block at its saved frame.
            // CoreGraphics uses bottom-left origin, so convert our top-left frames.
            for block in resume.blocks.sorted(by: { $0.z < $1.z }) {
                switch block.kind {
                case .text:
                    let attr = Attr.body(text: block.text)

                    let flippedFrame = CGRect(
                        x: block.frame.minX,
                        y: pageSize.height - block.frame.maxY,
                        width: block.frame.width,
                        height: block.frame.height
                    )

                    let framesetter = CTFramesetterCreateWithAttributedString(attr as CFAttributedString)
                    let path = CGMutablePath(); path.addRect(flippedFrame)
                    let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attr.length), path, nil)

                    cg.saveGState()
                    cg.textMatrix = .identity
                    CTFrameDraw(frame, cg)
                    cg.restoreGState()

                case .image:
                    if let data = block.imageData, let img = UIImage(data: data), let cgImg = img.cgImage {
                        let flippedFrame = CGRect(
                            x: block.frame.minX,
                            y: pageSize.height - block.frame.maxY,
                            width: block.frame.width,
                            height: block.frame.height
                        )
                        cg.saveGState()
                        cg.interpolationQuality = .high
                        cg.draw(cgImg, in: flippedFrame)
                        cg.restoreGState()
                    } else {
                        // Placeholder border
                        let flippedFrame = CGRect(
                            x: block.frame.minX,
                            y: pageSize.height - block.frame.maxY,
                            width: block.frame.width,
                            height: block.frame.height
                        )
                        cg.setStrokeColor(UIColor.systemGray.cgColor)
                        cg.stroke(flippedFrame)
                    }
                }
            }
        }
    }
}
