import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedLocationSetup") private var hasCompletedLocationSetup = false

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else if !hasCompletedLocationSetup {
            LocationPermissionView()
        } else {
            MainTabView()
        }
    }
}
