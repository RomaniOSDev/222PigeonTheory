import Foundation

struct EntryFilter: Equatable {
    var searchText = ""
    var emoji: String?
    var theme: String?
    var tag: String?
    var favoritesOnly = false
    var dateFrom: Date?
    var dateTo: Date?

    var isActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || emoji != nil
            || theme != nil
            || tag != nil
            || favoritesOnly
            || dateFrom != nil
            || dateTo != nil
    }

    mutating func reset() {
        searchText = ""
        emoji = nil
        theme = nil
        tag = nil
        favoritesOnly = false
        dateFrom = nil
        dateTo = nil
    }
}

enum EntryTemplate: String, CaseIterable, Identifiable {
    case todayIFelt = "Today I felt…"
    case highlight = "Highlight of the day"
    case grateful = "Grateful for…"

    var id: String { rawValue }

    var starterText: String {
        switch self {
        case .todayIFelt: return "Today I felt "
        case .highlight: return "Highlight of the day:\n"
        case .grateful: return "Grateful for:\n"
        }
    }
}

struct ActivityDay: Identifiable {
    let id: String
    let date: Date
    let count: Int
}

struct EmojiStat: Identifiable {
    let id: String
    let emoji: String
    let count: Int
}

struct TimeOfDayStat: Identifiable {
    let id: String
    let label: String
    let count: Int
}
