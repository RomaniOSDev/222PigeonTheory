import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementCatalog.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 16) {
                        StatsSummaryCard(
                            itemsAdded: store.itemsAdded,
                            entriesWritten: store.entriesWritten,
                            streakDays: store.streakDays,
                            minutesUsed: store.totalMinutesUsed
                        )

                        SectionHeaderView(
                            title: "Badges",
                            subtitle: "Unlock by journaling and organizing",
                            trailing: "\(unlockedCount)/\(AchievementCatalog.all.count)"
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AchievementCatalog.all) { achievement in
                                AchievementBadgeCell(
                                    achievement: achievement,
                                    unlocked: store.isAchievementUnlocked(achievement.id)
                                )
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }
}
