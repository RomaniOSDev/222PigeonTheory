import Foundation

struct MediaInsight: Identifiable, Equatable {
    let id: String
    let title: String
    let theme: String
    let count: Int
    var isExpanded: Bool = false
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_note",
            title: "First Note",
            description: "Added a note to your first photo.",
            iconName: "note.text"
        ),
        AchievementDefinition(
            id: "journal_kickoff",
            title: "Journal Kickoff",
            description: "Made your first journal entry.",
            iconName: "book"
        ),
        AchievementDefinition(
            id: "photo_collector",
            title: "Photo Collector",
            description: "Added notes to ten photos.",
            iconName: "photo.stack"
        ),
        AchievementDefinition(
            id: "dedicated_diarist",
            title: "Dedicated Diarist",
            description: "Wrote fifty journal entries.",
            iconName: "pencil.and.list.clipboard"
        ),
        AchievementDefinition(
            id: "favorite_fan",
            title: "'Favorite' Fan",
            description: "Favorited five entries.",
            iconName: "heart.fill"
        ),
        AchievementDefinition(
            id: "consistent_tracker",
            title: "Consistent Tracker",
            description: "Tracked notes for fifteen days straight.",
            iconName: "calendar"
        ),
        AchievementDefinition(
            id: "memories_curator",
            title: "Memories Curator",
            description: "Organized twenty-five photos with context.",
            iconName: "square.grid.2x2"
        ),
        AchievementDefinition(
            id: "journal_enthusiast",
            title: "Journal Enthusiast",
            description: "Maintained a journaling streak for a week.",
            iconName: "flame.fill"
        )
    ]
}
