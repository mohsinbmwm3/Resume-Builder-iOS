import UIKit

enum PDFExportError: Error { case renderFailed }

enum PDFExport {
    // US Letter 8.5x11in @ 72dpi; adjust for A4 if needed
    static let pageSize = CGSize(width: 612, height: 792)
    static let contentInsets = UIEdgeInsets(top: 48, left: 48, bottom: 48, right: 48)

    static func makePDF(resume: Resume) throws -> Data {
        switch resume.layoutMode {
        case .structured:
            return try makeStructuredPDF(resume)
        case .freeform:
            return try makeFreeformPDF(resume)
        }
    }

    private static func makeStructuredPDF(_ resume: Resume) throws -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let contentRect = CGRect(x: contentInsets.left,
                                     y: contentInsets.top,
                                     width: pageSize.width - contentInsets.left - contentInsets.right,
                                     height: pageSize.height - contentInsets.top - contentInsets.bottom)
            var y = contentRect.minY

            func draw(_ attr: NSAttributedString) {
                let framesetter = CTFramesetterCreateWithAttributedString(attr as CFAttributedString)
                var fitRange = CFRange(location: 0, length: 0)
                let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: attr.length), nil, CGSize(width: contentRect.width, height: .greatestFiniteMagnitude), &fitRange)
                let rect = CGRect(x: contentRect.minX, y: y, width: contentRect.width, height: size.height)
                let path = CGMutablePath(); path.addRect(rect)
                let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attr.length), path, nil)
                CTFrameDraw(frame, ctx.cgContext)
                y += size.height + 10
            }

            // Header
            draw(Attr.header(text: resume.person.fullName))
            draw(Attr.subheader(text: resume.person.headline))
            draw(Attr.caption(text: "\(resume.person.email) • \(resume.person.phone) • \(resume.person.location)"))

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

    private static func makeFreeformPDF(_ resume: Resume) throws -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            for block in resume.blocks.sorted(by: { $0.z < $1.z }) {
                switch block.kind {
                case .text:
                    let attr = Attr.body(text: block.text)
                    let framesetter = CTFramesetterCreateWithAttributedString(attr as CFAttributedString)
                    let path = CGMutablePath(); path.addRect(block.frame)
                    let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attr.length), path, nil)
                    CTFrameDraw(frame, ctx.cgContext)
                case .image:
                    if let data = block.imageData, let img = UIImage(data: data) {
                        ctx.cgContext.saveGState();
                        ctx.cgContext.interpolationQuality = .high
                        ctx.cgContext.draw(img.cgImage!, in: block.frame)
                        ctx.cgContext.restoreGState()
                    } else {
                        ctx.cgContext.setStrokeColor(UIColor.systemGray.cgColor)
                        ctx.cgContext.stroke(block.frame)
                    }
                }
            }
        }
    }
}

