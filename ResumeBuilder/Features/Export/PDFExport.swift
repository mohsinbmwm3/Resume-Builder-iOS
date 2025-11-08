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

            func newPageIfNeeded(for height: CGFloat) {
                if y + height > contentRect.maxY {
                    ctx.beginPage()               // start a new page
                    y = contentRect.minY          // reset cursor
                }
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
            draw(Attr.caption(text: "\(resume.person.email) • \(resume.person.phone) • \(resume.person.location)"))

            // Sections & items
            for section in resume.sections where section.isVisible {
                draw(Attr.sectionTitle(text: section.title))
                for item in section.items {
                    draw(Attr.itemTitle(text: item.headline))
                    if let sub = item.subheadline, !sub.isEmpty { draw(Attr.body(text: sub)) }
                    for b in item.bullets { draw(Attr.bullet(text: b)) }
                }
            }
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
