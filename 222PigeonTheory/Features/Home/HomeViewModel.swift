import Foundation

struct HomeViewModel {
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    func recentMoments(from store: AppDataStore, limit: Int = 6) -> [MemoryMoment] {
        Array(store.sortedMoments(store.memoryMoments).prefix(limit))
    }

    func recentNotes(from store: AppDataStore, limit: Int = 4) -> [StoryNote] {
        Array(store.sortedNotes(store.storyNotes).prefix(limit))
    }

    func topTheme(from store: AppDataStore) -> (name: String, count: Int)? {
        guard let top = store.insights().first else { return nil }
        return (top.theme, top.count)
    }

    func weekActivity(from store: AppDataStore) -> [ActivityDay] {
        Array(store.activityByDay(days: 28).suffix(28))
    }

    func todayEntryCount(from store: AppDataStore) -> Int {
        let calendar = Calendar.current
        let moments = store.memoryMoments.filter { calendar.isDateInToday($0.timestamp) }.count
        let notes = store.storyNotes.filter { calendar.isDateInToday($0.date) }.count
        return moments + notes
    }
}
