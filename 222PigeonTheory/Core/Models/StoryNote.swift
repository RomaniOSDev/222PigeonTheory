import Foundation

struct StoryNote: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var thumbnailStyle: Int
    var date: Date
    var isFavorite: Bool
    var tags: [String]
    var isPinned: Bool
    var linkedMomentID: UUID?
    var linkedTheme: String?

    init(
        id: UUID = UUID(),
        text: String,
        thumbnailStyle: Int,
        date: Date = Date(),
        isFavorite: Bool = false,
        tags: [String] = [],
        isPinned: Bool = false,
        linkedMomentID: UUID? = nil,
        linkedTheme: String? = nil
    ) {
        self.id = id
        self.text = text
        self.thumbnailStyle = thumbnailStyle
        self.date = date
        self.isFavorite = isFavorite
        self.tags = tags
        self.isPinned = isPinned
        self.linkedMomentID = linkedMomentID
        self.linkedTheme = linkedTheme
    }

    enum CodingKeys: String, CodingKey {
        case id, text, thumbnailStyle, date, isFavorite, tags, isPinned, linkedMomentID, linkedTheme
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        thumbnailStyle = try container.decode(Int.self, forKey: .thumbnailStyle)
        date = try container.decode(Date.self, forKey: .date)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        linkedMomentID = try container.decodeIfPresent(UUID.self, forKey: .linkedMomentID)
        linkedTheme = try container.decodeIfPresent(String.self, forKey: .linkedTheme)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(thumbnailStyle, forKey: .thumbnailStyle)
        try container.encode(date, forKey: .date)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(tags, forKey: .tags)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encodeIfPresent(linkedMomentID, forKey: .linkedMomentID)
        try container.encodeIfPresent(linkedTheme, forKey: .linkedTheme)
    }
}
