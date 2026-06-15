import SwiftUI

struct LocationPermissionView: View {
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
                }

                VStack(spacing: DesignSystem.Spacing.small) {
                    Button {
                        hasCompletedLocationSetup = true
                    } label: {
                        Label("Use Sample Location", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        hasCompletedLocationSetup = true
                    } label: {
                        Text("Enable Later")
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
    }
}

#Preview {
    LocationPermissionView()
}
