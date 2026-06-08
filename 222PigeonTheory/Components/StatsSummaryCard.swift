import SwiftUI

struct StatsSummaryCard: View {
    let itemsAdded: Int
    let entriesWritten: Int
    let streakDays: Int
    let minutesUsed: Int

    var body: some View {
        CardContainer(accent: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    SectionHeaderView(title: "Summary", subtitle: "Your activity at a glance")
                    Spacer()
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Color("AppAccent"))
                }

                HStack(spacing: 10) {
                    statItem(value: itemsAdded, label: "Items", icon: "square.stack.3d.up.fill")
                    statItem(value: entriesWritten, label: "Entries", icon: "book.fill")
                    statItem(value: streakDays, label: "Streak", icon: "flame.fill")
                    statItem(value: minutesUsed, label: "Minutes", icon: "clock.fill")
                }
            }
            .padding(16)
        }
    }

    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color("AppBackground").opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
