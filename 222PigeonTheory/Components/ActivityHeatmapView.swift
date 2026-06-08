import SwiftUI

struct ActivityHeatmapView: View {
    let days: [ActivityDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 12)

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(
                    title: "Activity Calendar",
                    subtitle: "Last 12 weeks of journaling",
                    trailing: "\(totalEntries) entries"
                )

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(days) { day in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(color(for: day.count))
                            .frame(height: 16)
                            .overlay {
                                if day.count > 0 {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(Color("AppAccent").opacity(0.25), lineWidth: 0.5)
                                }
                            }
                            .accessibilityLabel("\(day.count) entries on \(day.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }

                HStack(spacing: 8) {
                    Text("Less")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(color(for: level))
                            .frame(width: 14, height: 14)
                    }
                    Text("More")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(16)
        }
    }

    private var totalEntries: Int {
        days.reduce(0) { $0 + $1.count }
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color("AppBackground")
        case 1: return Color("AppPrimary").opacity(0.35)
        case 2: return Color("AppPrimary").opacity(0.55)
        case 3: return Color("AppAccent").opacity(0.75)
        default: return Color("AppAccent")
        }
    }
}
