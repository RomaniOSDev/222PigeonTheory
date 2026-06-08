import SwiftUI

struct MediaInsightsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = MediaInsightsViewModel()

    private var insights: [MediaInsight] {
        store.insights()
    }

    private var hasContent: Bool {
        !store.memoryMoments.isEmpty || !store.storyNotes.isEmpty
    }

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                segmentPicker

                if !hasContent {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "magnifyingglass",
                            title: "No Insights Yet",
                            message: "Add photos and notes to discover trends in your collection."
                        )
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            switch viewModel.selectedSegment {
                            case .collections:
                                collectionsContent
                            case .trends:
                                trendsContent
                            case .activity:
                                ActivityHeatmapView(days: store.activityByDay())
                            case .stats:
                                statsContent
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await viewModel.refresh(store: store)
                    }

                    if viewModel.selectedSegment == .collections || viewModel.selectedSegment == .trends {
                        PrimaryButton(title: "Analyze Now") {
                            viewModel.analyze(store: store)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MediaInsightsViewModel.Segment.allCases, id: \.self) { segment in
                    Button {
                        HapticManager.lightTap()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedSegment = segment
                        }
                    } label: {
                        Text(segment.rawValue)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectedSegment == segment
                                    ? Color("AppPrimary")
                                    : Color("AppSurface")
                            )
                            .foregroundStyle(
                                viewModel.selectedSegment == segment
                                    ? Color("AppSurface")
                                    : Color("AppTextPrimary")
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var collectionsContent: some View {
        Group {
            if insights.isEmpty {
                emptyInsightsCard
            } else {
                ForEach(insights) { insight in
                    InsightCardCell(
                        title: insight.title,
                        subtitle: "\(insight.count) items tracked",
                        count: insight.count,
                        peakCount: insights.first?.count ?? 1,
                        isFavored: store.favoredThemes.contains(insight.theme),
                        isExpanded: viewModel.expandedInsightIDs.contains(insight.id),
                        detail: "\(insight.count) photos related to \(insight.theme.lowercased()) themes in your collection.",
                        onFavorite: {
                            viewModel.toggleFavorite(theme: insight.theme, store: store)
                        },
                        onToggle: {
                            HapticManager.lightTap()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleExpanded(insight)
                            }
                        }
                    )
                }
            }
        }
    }

    private var trendsContent: some View {
        Group {
            if insights.isEmpty {
                emptyInsightsCard
            } else {
                ForEach(insights) { insight in
                    InsightCardCell(
                        title: insight.theme,
                        subtitle: "Trend strength",
                        count: insight.count,
                        peakCount: insights.first?.count ?? 1,
                        isFavored: store.favoredThemes.contains(insight.theme),
                        expandable: false,
                        onFavorite: {
                            viewModel.toggleFavorite(theme: insight.theme, store: store)
                        },
                        onToggle: {}
                    )
                }
            }
        }
    }

    private var statsContent: some View {
        VStack(spacing: 14) {
            StatBlockCell(
                title: "Top Emojis",
                icon: "face.smiling",
                items: store.emojiUsageStats().map { "\($0.emoji) — \($0.count) uses" }
            )
            StatBlockCell(
                title: "Writing Time",
                icon: "clock",
                items: store.timeOfDayStats().map { "\($0.label) — \($0.count) entries" }
            )
            StatBlockCell(
                title: "Popular Tags",
                icon: "number",
                items: store.tagUsageStats().map { "#\($0.tag) — \($0.count)" }
            )
        }
    }

    private var emptyInsightsCard: some View {
        CardContainer {
            VStack(spacing: 10) {
                Image(systemName: "wand.and.stars")
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
                Text("Tap Analyze Now to generate insights from your entries.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }
}
