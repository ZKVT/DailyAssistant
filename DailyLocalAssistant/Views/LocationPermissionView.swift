import SwiftUI

struct LocationPermissionView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @AppStorage("hasCompletedLocationSetup") private var hasCompletedLocationSetup = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.large) {
                Spacer(minLength: DesignSystem.Spacing.large)

                Image(systemName: "location.circle.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 118, height: 118)
                    .background(DesignSystem.Gradient.explore, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.xLarge, style: .continuous))
                    .shadow(color: DesignSystem.Shadow.softColor, radius: DesignSystem.Shadow.softRadius, x: 0, y: DesignSystem.Shadow.softY)

                VStack(spacing: DesignSystem.Spacing.medium) {
                    Text("Enable Location-Based Suggestions")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Daily Local Assistant can use your area to provide better weather, food, news, and activity recommendations.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let message = locationManager.authorizationMessage {
                        Text(message)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, DesignSystem.Spacing.small)
                    }
                }

                VStack(spacing: DesignSystem.Spacing.small) {
                    Button {
                        locationManager.requestAuthorization()
                        if locationManager.isAuthorized {
                            hasCompletedLocationSetup = true
                        }
                    } label: {
                        Label("Enable Location", systemImage: "location.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        locationManager.useSampleLocation()
                        hasCompletedLocationSetup = true
                    } label: {
                        Text("Use Sample Location")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Spacer(minLength: DesignSystem.Spacing.large)
            }
            .padding(.horizontal, DesignSystem.Padding.screenHorizontal)
        }
        .onChange(of: locationManager.authorizationStatus) { _, status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                hasCompletedLocationSetup = true
            }
        }
    }
}

#Preview {
    LocationPermissionView()
        .environmentObject(LocationManager())
}
