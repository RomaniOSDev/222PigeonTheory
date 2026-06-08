import UIKit

enum ExportManager {
    static func makeTXT(moments: [MemoryMoment], notes: [StoryNote]) -> URL? {
        var lines: [String] = ["Journal Export", "Generated: \(Date().formatted())", ""]
        if !moments.isEmpty {
            lines.append("=== MEMORY MOMENTS ===")
            for moment in moments {
                lines.append("[\(moment.timestamp.formatted())] \(moment.emoji) \(moment.text)")
                if !moment.tags.isEmpty {
                    lines.append("Tags: \(moment.tags.map { "#\($0)" }.joined(separator: ", "))")
                }
                lines.append("")
            }
        }
        if !notes.isEmpty {
            lines.append("=== STORY NOTES ===")
            for note in notes {
                lines.append("[\(note.date.formatted())] \(note.text)")
                if !note.tags.isEmpty {
                    lines.append("Tags: \(note.tags.map { "#\($0)" }.joined(separator: ", "))")
                }
                if let theme = note.linkedTheme {
                    lines.append("Linked theme: \(theme)")
                }
                lines.append("")
            }
        }
        return writeToTempFile(content: lines.joined(separator: "\n"), filename: "journal_export.txt")
    }

    static func makePDF(moments: [MemoryMoment], notes: [StoryNote]) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { context in
            context.beginPage()
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            var y: CGFloat = 40
            "Journal Export".draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttributes)
            y += 32
            Date().formatted().draw(at: CGPoint(x: 40, y: y), withAttributes: bodyAttributes)
            y += 28

            func drawSection(_ header: String) {
                if y > 720 {
                    context.beginPage()
                    y = 40
                }
                header.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttributes)
                y += 24
            }

            func drawLine(_ text: String) {
                if y > 750 {
                    context.beginPage()
                    y = 40
                }
                let rect = CGRect(x: 40, y: y, width: 532, height: 200)
                let measured = text.boundingRect(
                    with: CGSize(width: 532, height: CGFloat.greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: bodyAttributes,
                    context: nil
                )
                text.draw(in: rect, withAttributes: bodyAttributes)
                y += max(18, measured.height + 6)
            }

            if !moments.isEmpty {
                drawSection("Memory Moments")
                for moment in moments {
                    drawLine("\(moment.emoji) \(moment.text)")
                }
            }
            if !notes.isEmpty {
                drawSection("Story Notes")
                for note in notes {
                    drawLine(note.text)
                }
            }
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("journal_export.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func writeToTempFile(content: String, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
