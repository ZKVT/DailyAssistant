import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var favoritesStore = FavoritesStore()
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            ExploreView(viewModel: homeViewModel)
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(favoritesStore)
        .task {
            await homeViewModel.loadIfNeeded(locationManager: locationManager)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocationManager())
}
