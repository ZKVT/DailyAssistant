import SwiftUI

struct MainTabView: View {
    @StateObject private var favoritesStore = FavoritesStore()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(favoritesStore)
    }
}

#Preview {
    MainTabView()
}
