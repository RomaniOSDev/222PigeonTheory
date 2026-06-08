import SwiftUI

struct JournalHubView: View {
    @EnvironmentObject private var router: TabRouter

    private let tabs = ["Stories", "Insights", "Focus"]

    private var navigationTitle: String {
        switch router.journalSection {
        case 0: return "Story Notes"
        case 1: return "Insights"
        default: return "Focus"
        }
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                                Button {
                                    HapticManager.lightTap()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        router.journalSection = index
                                    }
                                } label: {
                                    Text(title)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(router.journalSection == index ? Color("AppPrimary") : Color("AppSurface"))
                                        .foregroundStyle(router.journalSection == index ? Color("AppSurface") : Color("AppTextPrimary"))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    Group {
                        switch router.journalSection {
                        case 0:
                            StoryNotesView()
                        case 1:
                            MediaInsightsView()
                        default:
                            FocusSessionView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: router.journalSection)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }
}
