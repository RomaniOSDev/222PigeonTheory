import Combine
import Foundation

final class MediaInsightsViewModel: ObservableObject {
    enum Segment: String, CaseIterable {
        case collections = "Collections"
        case trends = "Trends"
        case activity = "Activity"
        case stats = "Stats"
    }

    @Published var selectedSegment: Segment = .collections
    @Published var expandedInsightIDs: Set<String> = []
    @Published var scaledFavoriteTheme: String?
    @Published var isRefreshing = false

    func toggleExpanded(_ insight: MediaInsight) {
        if expandedInsightIDs.contains(insight.id) {
            expandedInsightIDs.remove(insight.id)
        } else {
            expandedInsightIDs.insert(insight.id)
        }
    }

    func analyze(store: AppDataStore) {
        HapticManager.mediumTap()
        store.runAnalysis()
        HapticManager.saveFeedback()
    }

    func refresh(store: AppDataStore) async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        store.runAnalysis()
        isRefreshing = false
    }

    func toggleFavorite(theme: String, store: AppDataStore) {
        store.toggleThemeFavorite(theme)
        scaledFavoriteTheme = theme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.scaledFavoriteTheme = nil
        }
    }
}
