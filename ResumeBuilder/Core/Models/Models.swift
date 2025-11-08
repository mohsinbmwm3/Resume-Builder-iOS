import Foundation
import SwiftData
import SwiftUI

@Model
final class Resume: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var person: Person
    var sections: [SectionModel]
    var theme: ThemeModel
    var layoutMode: LayoutMode
    var blocks: [Block] // used in Free-form mode

    init(
        id: UUID = UUID(),
        title: String = "My Résumé",
        person: Person = Person(),
        sections: [SectionModel] = [],
        theme: ThemeModel = ThemeModel.default,
        layoutMode: LayoutMode = .structured,
        blocks: [Block] = []
    ) {
        self.id = id
        self.title = title
        self.person = person
        self.sections = sections
        self.theme = theme
        self.layoutMode = layoutMode
        self.blocks = blocks
    }
}

enum LayoutMode: String, Codable, CaseIterable {
    case structured
    case freeform
}

// Link item with label and URL
struct LinkItem: Codable, Hashable, Identifiable {
    var id: UUID = .init()
    var label: String = ""          // e.g., "LinkedIn"
    var url: String = ""            // e.g., "https://linkedin.com/in/..."
}

struct Person: Codable, Hashable {
    var fullName: String = "Your Name"
    var headline: String = "iOS Engineer"
    var email: String = "you@example.com"
    var phone: String = "+91-XXXXXXXXXX"
    var location: String = "Pune, India"
    var links: [LinkItem] = []      // <-- now editable, label + url
}

@Model
final class SectionModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var kind: SectionKind
    var title: String
    var items: [ItemModel]
    var isVisible: Bool

    init(id: UUID = UUID(), kind: SectionKind, title: String, items: [ItemModel] = [], isVisible: Bool = true) {
        self.id = id
        self.kind = kind
        self.title = title
        self.items = items
        self.isVisible = isVisible
    }
}

enum SectionKind: String, Codable, CaseIterable, Identifiable {
    case summary, experience, education, skills, projects, achievements, custom
    var id: String { rawValue }
}

@Model
final class ItemModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var headline: String
    var subheadline: String?
    var startDate: Date?
    var endDate: Date?
    var bullets: [String]
    var meta: [String: String]

    init(id: UUID = UUID(), headline: String, subheadline: String? = nil, startDate: Date? = nil, endDate: Date? = nil, bullets: [String] = [], meta: [String: String] = [:]) {
        self.id = id
        self.headline = headline
        self.subheadline = subheadline
        self.startDate = startDate
        self.endDate = endDate
        self.bullets = bullets
        self.meta = meta
    }
}

@Model
final class ThemeModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var accentHex: String
    var bodyFontName: String
    var headerFontName: String
    var bodySize: Double
    var headerSize: Double

    static var `default`: ThemeModel { ThemeModel(name: "Classic", accentHex: "#0A84FF", bodyFontName: "SFProText-Regular", headerFontName: "SFProDisplay-Semibold", bodySize: 11, headerSize: 15) }

    init(id: UUID = UUID(), name: String, accentHex: String, bodyFontName: String, headerFontName: String, bodySize: Double, headerSize: Double) {
        self.id = id
        self.name = name
        self.accentHex = accentHex
        self.bodyFontName = bodyFontName
        self.headerFontName = headerFontName
        self.bodySize = bodySize
        self.headerSize = headerSize
    }
}

// Free-form block for canvas mode
struct Block: Codable, Hashable, Identifiable {
    enum Kind: String, Codable { case text, image }
    var id: UUID = .init()
    var kind: Kind
    var text: String = ""
    var imageData: Data? = nil
    var frame: CGRect = CGRect(x: 48, y: 48, width: 300, height: 24)
    var z: Double = 0
}

