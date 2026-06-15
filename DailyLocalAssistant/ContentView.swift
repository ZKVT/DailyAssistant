import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedLocationSetup") private var hasCompletedLocationSetup = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else if !hasCompletedLocationSetup {
            LocationPermissionView()
                .environmentObject(locationManager)
        } else {
            MainTabView()
                .environmentObject(locationManager)
        }
    }
}
