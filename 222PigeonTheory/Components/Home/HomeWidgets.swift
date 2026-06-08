import SwiftUI

struct HomeHeroWidget: View {
    let greeting: String
    let subtitle: String
    let todayCount: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 190)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.clear, Color.black.opacity(0.25)],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppSurface"))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppSurface").opacity(0.92))
                if todayCount > 0 {
                    ChipView(text: "\(todayCount) entries today", icon: "checkmark.circle.fill", style: .accent)
                }
            }
            .padding(18)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
        }
        .shadow(color: Color("AppPrimary").opacity(0.2), radius: 12, y: 6)
    }
}

struct HomeStatWidget: View {
    let value: String
    let label: String
    let icon: String
    var accent = false

    var body: some View {
        CardContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }
}

struct HomeQuickActionWidget: View {
    let title: String
    let subtitle: String
    let imageName: String?
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            CardContainer {
                HStack(spacing: 12) {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppPrimary").opacity(0.25))
                                .frame(width: 56, height: 56)
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HomeStreakWidget: View {
    let streakDays: Int
    let journalStreak: Int

    var body: some View {
        CardContainer(accent: streakDays >= 7) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.25))
                        .frame(width: 58, height: 58)
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent"))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Streaks")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    HStack(spacing: 10) {
                        ChipView(text: "\(streakDays) day activity", icon: "calendar", style: .accent)
                        ChipView(text: "\(journalStreak) day journal", icon: "book", style: .primary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }
}

struct HomeRecentMomentChip: View {
    let moment: MemoryMoment
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            VStack(spacing: 10) {
                Text(moment.emoji)
                    .font(.system(size: 34))
                    .frame(width: 72, height: 72)
                    .background(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.3), Color("AppAccent").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(moment.text)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HomeRecentStoryRow: View {
    let note: StoryNote
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            CardContainer {
                HStack(spacing: 12) {
                    ThumbnailPlaceholderView(style: note.thumbnailStyle, size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.text)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                        Text(DateFormatting.relativeLabel(for: note.date))
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(12)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HomeMiniHeatmapWidget: View {
    let days: [ActivityDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: "This Month",
                    subtitle: "Your writing rhythm",
                    trailing: "\(days.reduce(0) { $0 + $1.count }) total"
                )

                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(days) { day in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(heatColor(day.count))
                            .frame(height: 18)
                    }
                }
            }
            .padding(16)
        }
    }

    private func heatColor(_ count: Int) -> Color {
        switch count {
        case 0: return Color("AppBackground")
        case 1: return Color("AppPrimary").opacity(0.4)
        case 2: return Color("AppPrimary").opacity(0.65)
        default: return Color("AppAccent")
        }
    }
}

struct HomeInsightTeaserWidget: View {
    let theme: String
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            CardContainer(accent: true) {
                HStack(spacing: 14) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 44, height: 44)
                        .background(Color("AppAccent").opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top Theme")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text(theme)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(count) items in your collection")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}
