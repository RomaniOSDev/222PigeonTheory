import Foundation

struct MemoryMoment: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var emoji: String
    var timestamp: Date
    var tags: [String]
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        text: String,
        emoji: String,
        timestamp: Date = Date(),
        tags: [String] = [],
        isPinned: Bool = false
    ) {
        self.id = id
        self.text = text
        self.emoji = emoji
        self.timestamp = timestamp
        self.tags = tags
        self.isPinned = isPinned
    }

    enum CodingKeys: String, CodingKey {
        case id, text, emoji, timestamp, tags, isPinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        emoji = try container.decode(String.self, forKey: .emoji)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(tags, forKey: .tags)
        try container.encode(isPinned, forKey: .isPinned)
    }
}
