import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()
    @StateObject private var router = TabRouter()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environmentObject(router)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
