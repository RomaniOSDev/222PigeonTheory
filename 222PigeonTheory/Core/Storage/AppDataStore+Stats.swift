import Foundation

extension AppDataStore {
    func activityByDay(days: Int = 84) -> [ActivityDay] {
        var counts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for moment in memoryMoments {
            let key = formatter.string(from: moment.timestamp)
            counts[key, default: 0] += 1
        }
        for note in storyNotes {
            let key = formatter.string(from: note.date)
            counts[key, default: 0] += 1
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).compactMap { offset -> ActivityDay? in
            guard let date = calendar.date(byAdding: .day, value: -((days - 1) - offset), to: today) else {
                return nil
            }
            let key = formatter.string(from: date)
            return ActivityDay(id: key, date: date, count: counts[key, default: 0])
        }
    }

    func emojiUsageStats() -> [EmojiStat] {
        var counts: [String: Int] = [:]
        for moment in memoryMoments {
            counts[moment.emoji, default: 0] += 1
        }
        return counts
            .sorted { $0.value > $1.value }
            .map { EmojiStat(id: $0.key, emoji: $0.key, count: $0.value) }
    }

    func timeOfDayStats() -> [TimeOfDayStat] {
        var buckets = ["Morning": 0, "Afternoon": 0, "Evening": 0, "Night": 0]
        let calendar = Calendar.current

        for note in storyNotes {
            let hour = calendar.component(.hour, from: note.date)
            switch hour {
            case 5..<12: buckets["Morning", default: 0] += 1
            case 12..<17: buckets["Afternoon", default: 0] += 1
            case 17..<22: buckets["Evening", default: 0] += 1
            default: buckets["Night", default: 0] += 1
            }
        }

        return ["Morning", "Afternoon", "Evening", "Night"].map {
            TimeOfDayStat(id: $0, label: $0, count: buckets[$0, default: 0])
        }
    }

    func tagUsageStats() -> [(tag: String, count: Int)] {
        var counts: [String: Int] = [:]
        for tag in memoryMoments.flatMap(\.tags) + storyNotes.flatMap(\.tags) {
            counts[tag, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }
}
