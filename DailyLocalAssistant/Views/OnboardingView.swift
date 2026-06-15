import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedPage = 0

    private let pages = [
        OnboardingPage(
            title: "Welcome to Daily Local Assistant",
            subtitle: "Your daily guide for weather, food, news, and local activities.",
            symbolName: "sun.max.fill",
            tint: Color.orange
        ),
        OnboardingPage(
            title: "Smart Daily Suggestions",
            subtitle: "Get simple recommendations based on weather, time, and your preferences.",
            symbolName: "sparkles",
            tint: Color.purple
        ),
        OnboardingPage(
            title: "Explore Your Area",
            subtitle: "Discover food, local highlights, and things to do nearby.",
            symbolName: "map.fill",
            tint: Color.green
        )
    ]

    var body: some View {
        ZStack {
            DesignSystem.Gradient.morning
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.large) {
                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal, DesignSystem.Padding.screenHorizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))

                Button {
                    if selectedPage == pages.count - 1 {
                        hasCompletedOnboarding = true
                    } else {
                        withAnimation(.snappy) {
                            selectedPage += 1
                        }
                    }
                } label: {
                    Text(selectedPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, DesignSystem.Padding.screenHorizontal)
                .padding(.bottom, DesignSystem.Spacing.large)
            }
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let symbolName: String
    let tint: Color
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xLarge) {
            Spacer(minLength: DesignSystem.Spacing.large)

            Image(systemName: page.symbolName)
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 112, height: 112)
                .background(page.tint.opacity(0.88), in: RoundedRectangle(cornerRadius: DesignSystem.Radius.xLarge, style: .continuous))
                .shadow(color: DesignSystem.Shadow.softColor, radius: DesignSystem.Shadow.softRadius, x: 0, y: DesignSystem.Shadow.softY)

            VStack(spacing: DesignSystem.Spacing.medium) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.large)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.large, style: .continuous))

            Spacer(minLength: DesignSystem.Spacing.large)
        }
    }
}

#Preview {
    OnboardingView()
}
