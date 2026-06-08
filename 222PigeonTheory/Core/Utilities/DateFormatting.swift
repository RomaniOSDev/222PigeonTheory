import Foundation

enum DateFormatting {
    static func relativeLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: Date())).day,
           days < 7 {
            return "\(days) days ago"
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    static func detailLabel(for date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
