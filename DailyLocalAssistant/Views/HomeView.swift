import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadIfNeeded()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DetailPage.self) { page in
                DetailView(page: page)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            LoadingStateView()
        case .loaded:
            dashboardContent
        case .empty:
            EmptyStateView(
                title: "Nothing to show yet",
                message: "Pull to refresh and we will rebuild today's local suggestions.",
                systemImage: "sparkles",
                tint: .purple
            )
        case .error(let message):
            ErrorStateView(message: message) {
                Task {
                    await viewModel.refresh()
                }
            }
        }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        header
        weatherCard
        recommendationCard
        foodCard
        newsCard
        activitiesCard
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greeting)
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Label(viewModel.location, systemImage: "location.fill")
                Text(viewModel.formattedDate)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var weatherCard: some View {
        NavigationLink(value: viewModel.weatherDetailPage()) {
            CardContainer(tint: .blue) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        SectionTitle(title: "Weather", systemImage: viewModel.weather.symbolName, tint: .blue)

                        Spacer()

                        Text("\(viewModel.weather.temperature)°")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(.primary)
                    }

                    Text(viewModel.weather.condition)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(viewModel.weather.suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    MetricPill(text: "\(viewModel.weather.rainChance)% rain chance", systemImage: "drop.fill")
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var recommendationCard: some View {
        NavigationLink(value: viewModel.recommendationDetailPage()) {
            CardContainer(tint: .purple) {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "Today's Recommendation", systemImage: "sparkles", tint: .purple)

                    Text(viewModel.recommendation.summary)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    MetricPill(text: viewModel.recommendation.focus, systemImage: "target")
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var foodCard: some View {
        CardContainer(tint: .orange) {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Food Suggestions", systemImage: "fork.knife", tint: .orange)

                VStack(spacing: 14) {
                    ForEach(viewModel.foodSuggestions) { item in
                        NavigationLink(value: viewModel.foodDetailPage(for: item)) {
                            ListItemRow(
                                title: item.name,
                                subtitle: item.category,
                                metadata: "\(item.distance)\nStar \(item.rating)",
                                systemImage: "fork.knife.circle.fill",
                                tint: .orange
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var newsCard: some View {
        CardContainer(tint: .teal) {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Local News", systemImage: "newspaper.fill", tint: .teal)

                VStack(spacing: 14) {
                    ForEach(viewModel.newsItems) { item in
                        NavigationLink(value: viewModel.newsDetailPage(for: item)) {
                            ListItemRow(
                                title: item.title,
                                subtitle: item.source,
                                metadata: item.time,
                                systemImage: "doc.text.fill",
                                tint: .teal
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var activitiesCard: some View {
        CardContainer(tint: .green) {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Things To Do", systemImage: "figure.walk", tint: .green)

                VStack(spacing: 14) {
                    ForEach(viewModel.activities) { item in
                        NavigationLink(value: viewModel.activityDetailPage(for: item)) {
                            ListItemRow(
                                title: item.title,
                                subtitle: item.locationHint,
                                metadata: item.duration,
                                systemImage: item.symbolName,
                                tint: .green
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
