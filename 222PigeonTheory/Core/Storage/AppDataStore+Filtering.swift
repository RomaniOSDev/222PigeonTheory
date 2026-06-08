import Foundation

extension AppDataStore {
    static let insightThemes = ["Travel", "Nature", "Food", "People", "Art", "Daily Life"]

    var allUsedTags: [String] {
        var tags = Set<String>()
        memoryMoments.flatMap(\.tags).forEach { tags.insert($0) }
        storyNotes.flatMap(\.tags).forEach { tags.insert($0) }
        return tags.sorted()
    }

    func normalizedTag(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
    }

    func themeForNote(_ note: StoryNote) -> String {
        if let linked = note.linkedTheme, !linked.isEmpty {
            return linked
        }
        if let firstTag = note.tags.first {
            return firstTag.capitalized
        }
        let themes = Self.insightThemes
        let index = abs(note.thumbnailStyle) % themes.count
        return themes[index]
    }

    func themeForEmoji(_ emoji: String) -> String {
        switch emoji {
        case "🌿", "🌸", "🍃": return "Nature"
        case "✈️", "🗺️", "🏖️": return "Travel"
        case "🍕", "☕", "🍰": return "Food"
        case "👨‍👩‍👧", "🤝", "💬": return "People"
        case "🎨", "🎭", "📷": return "Art"
        default: return "Daily Life"
        }
    }

    func sortedMoments(_ moments: [MemoryMoment]) -> [MemoryMoment] {
        moments.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned && !rhs.isPinned }
            return lhs.timestamp > rhs.timestamp
        }
    }

    func sortedNotes(_ notes: [StoryNote]) -> [StoryNote] {
        notes.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned && !rhs.isPinned }
            return lhs.date > rhs.date
        }
    }

    func filteredMoments(using filter: EntryFilter) -> [MemoryMoment] {
        sortedMoments(memoryMoments.filter { moment in
            matchesSearch(moment.text, filter: filter)
                && matchesEmoji(moment.emoji, filter: filter)
                && matchesTheme(themeForEmoji(moment.emoji), filter: filter)
                && matchesTag(moment.tags, filter: filter)
                && matchesDate(moment.timestamp, filter: filter)
        })
    }

    func filteredNotes(using filter: EntryFilter) -> [StoryNote] {
        sortedNotes(storyNotes.filter { note in
            matchesSearch(note.text, filter: filter)
                && matchesTheme(themeForNote(note), filter: filter)
                && matchesTag(note.tags, filter: filter)
                && matchesDate(note.date, filter: filter)
                && matchesFavorite(note.isFavorite, filter: filter)
        })
    }

    func toggleMomentPin(_ moment: MemoryMoment) {
        guard let index = memoryMoments.firstIndex(where: { $0.id == moment.id }) else { return }
        memoryMoments[index].isPinned.toggle()
        HapticManager.lightTap()
    }

    func toggleNotePin(_ note: StoryNote) {
        guard let index = storyNotes.firstIndex(where: { $0.id == note.id }) else { return }
        storyNotes[index].isPinned.toggle()
        HapticManager.lightTap()
    }

    func momentTitle(for id: UUID) -> String? {
        memoryMoments.first(where: { $0.id == id }).map { "\($0.emoji) \($0.text)" }
    }

    private func matchesSearch(_ text: String, filter: EntryFilter) -> Bool {
        let query = filter.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return text.localizedCaseInsensitiveContains(query)
    }

    private func matchesEmoji(_ emoji: String, filter: EntryFilter) -> Bool {
        guard let selected = filter.emoji else { return true }
        return emoji == selected
    }

    private func matchesTheme(_ theme: String, filter: EntryFilter) -> Bool {
        guard let selected = filter.theme else { return true }
        return theme == selected
    }

    private func matchesTag(_ tags: [String], filter: EntryFilter) -> Bool {
        guard let selected = filter.tag else { return true }
        return tags.contains(selected)
    }

    private func matchesFavorite(_ isFavorite: Bool, filter: EntryFilter) -> Bool {
        filter.favoritesOnly ? isFavorite : true
    }

    private func matchesDate(_ date: Date, filter: EntryFilter) -> Bool {
        if let from = filter.dateFrom, date < Calendar.current.startOfDay(for: from) {
            return false
        }
        if let to = filter.dateTo {
            let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: to)) ?? to
            if date >= end { return false }
        }
        return true
    }
}
