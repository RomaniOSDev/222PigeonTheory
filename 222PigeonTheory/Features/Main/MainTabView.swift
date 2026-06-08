import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case moments
    case journal
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .moments: return "Moments"
        case .journal: return "Journal"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .moments: return "sparkles"
        case .journal: return "book.pages"
        case .achievements: return "rosette"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var router: TabRouter
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Group {
                        switch router.selectedTab {
                        case .home:
                            HomeView()
                        case .moments:
                            MemoryMomentsView()
                        case .journal:
                            JournalHubView()
                        case .achievements:
                            AchievementsView()
                        case .settings:
                            NavigationStack {
                                SettingsView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.3), value: router.selectedTab)

                    if let achievement = store.newlyUnlockedAchievement {
                        AchievementBannerView(achievement: achievement) {
                            store.dismissAchievementBanner()
                        }
                        .padding(.top, 8)
                        .zIndex(1)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }

                customTabBar
            }
        }
        .onAppear {
            store.beginSession()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.beginSession()
            case .background, .inactive:
                store.endSessionIfNeeded()
            @unknown default:
                break
            }
        }
        .onChange(of: router.selectedTab) { _ in
            HapticManager.lightTap()
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color("AppSurface"))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.18), lineWidth: 1)
                }
                .shadow(color: Color("AppPrimary").opacity(0.2), radius: 14, y: -4)
        }
        .padding(.horizontal, 10)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background {
            Color("AppBackground")
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = router.selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                router.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 30)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Color("AppSurface") : Color("AppTextSecondary"))
                }
                .frame(height: 30)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
        }
        .buttonStyle(TabPressStyle())
    }
}

private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
