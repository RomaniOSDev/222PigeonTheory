import Combine
import Foundation

final class TabRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var journalSection = 0
}
