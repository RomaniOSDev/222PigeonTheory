import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var router: TabRouter
    private let viewModel = HomeViewModel()
    @State private var showMomentEditor = false
    @State private var showStoryEditor = false
    @StateObject private var momentVM = MemoryMomentsViewModel()
    @StateObject private var storyVM = StoryNotesViewModel()

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 16) {
                        HomeHeroWidget(
                            greeting: viewModel.greeting,
                            subtitle: heroSubtitle,
                            todayCount: viewModel.todayEntryCount(from: store)
                        )

                        statsGrid

                        quickActionsSection

                        HomeStreakWidget(
                            streakDays: store.streakDays,
                            journalStreak: store.journalStreakDays
                        )

                        if let top = viewModel.topTheme(from: store) {
                            HomeInsightTeaserWidget(theme: top.name, count: top.count) {
                                router.journalSection = 1
                                router.selectedTab = .journal
                            }
                        }

                        HomeMiniHeatmapWidget(days: viewModel.weekActivity(from: store))

                        recentMomentsSection

                        recentStoriesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.lightTap()
                        router.selectedTab = .settings
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $showMomentEditor) {
                MomentEditorSheet(viewModel: momentVM)
            }
            .sheet(isPresented: $showStoryEditor) {
                StoryNoteEditorSheet(viewModel: storyVM)
            }
            .onAppear {
                if store.insights().isEmpty,
                   !store.memoryMoments.isEmpty || !store.storyNotes.isEmpty {
                    store.runAnalysis()
                }
            }
        }
    }

    private var heroSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            HomeStatWidget(
                value: "\(store.itemsAdded)",
                label: "Total Items",
                icon: "square.stack.3d.up.fill",
                accent: store.itemsAdded > 0
            )
            HomeStatWidget(
                value: "\(store.entriesWritten)",
                label: "Stories",
                icon: "book.fill"
            )
            HomeStatWidget(
                value: "\(store.streakDays)",
                label: "Day Streak",
                icon: "flame.fill",
                accent: store.streakDays >= 3
            )
            HomeStatWidget(
                value: "\(store.totalMinutesUsed)",
                label: "Minutes",
                icon: "clock.fill"
            )
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", subtitle: "Jump right in")

            HomeQuickActionWidget(
                title: "Add Moment",
                subtitle: "Capture a reflection with emoji",
                imageName: "WidgetMoments",
                icon: "sparkles"
            ) {
                momentVM.prepareNew(lastEmoji: store.lastUsedEmoji)
                showMomentEditor = true
            }

            HomeQuickActionWidget(
                title: "Write Story",
                subtitle: "Start a new journal entry",
                imageName: "WidgetJournal",
                icon: "book.pages"
            ) {
                storyVM.prepareNew(template: EntryTemplate.todayIFelt.starterText)
                showStoryEditor = true
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeQuickActionWidget(
                    title: "Focus",
                    subtitle: "5–15 min session",
                    imageName: nil,
                    icon: "brain.head.profile"
                ) {
                    router.journalSection = 2
                    router.selectedTab = .journal
                }

                HomeQuickActionWidget(
                    title: "Insights",
                    subtitle: "View your trends",
                    imageName: nil,
                    icon: "chart.bar.fill"
                ) {
                    router.journalSection = 1
                    router.selectedTab = .journal
                }
            }
        }
    }

    @ViewBuilder
    private var recentMomentsSection: some View {
        let moments = viewModel.recentMoments(from: store)
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Moments",
                subtitle: moments.isEmpty ? "Nothing yet" : "Tap to open",
                trailing: moments.isEmpty ? nil : "See all"
            )
            .onTapGesture {
                if !moments.isEmpty {
                    HapticManager.lightTap()
                    router.selectedTab = .moments
                }
            }

            if moments.isEmpty {
                emptyWidget(
                    icon: "sparkles",
                    message: "Add your first moment to see it here."
                ) {
                    momentVM.prepareNew(lastEmoji: store.lastUsedEmoji)
                    showMomentEditor = true
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(moments) { moment in
                            HomeRecentMomentChip(moment: moment) {
                                router.selectedTab = .moments
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recentStoriesSection: some View {
        let notes = viewModel.recentNotes(from: store)
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Stories",
                subtitle: notes.isEmpty ? "Start journaling" : "Latest entries",
                trailing: notes.isEmpty ? nil : "See all"
            )
            .onTapGesture {
                if !notes.isEmpty {
                    HapticManager.lightTap()
                    router.journalSection = 0
                    router.selectedTab = .journal
                }
            }

            if notes.isEmpty {
                emptyWidget(
                    icon: "book.closed",
                    message: "Write a story to fill this feed."
                ) {
                    storyVM.prepareNew()
                    showStoryEditor = true
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(notes) { note in
                        HomeRecentStoryRow(note: note) {
                            router.journalSection = 0
                            router.selectedTab = .journal
                        }
                    }
                }
            }
        }
    }

    private func emptyWidget(icon: String, message: String, action: @escaping () -> Void) -> some View {
        CardContainer {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                Button("Get Started") {
                    HapticManager.lightTap()
                    action()
                }
                .font(.caption.bold())
                .foregroundStyle(Color("AppAccent"))
                .frame(minHeight: 44)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
    }
}
