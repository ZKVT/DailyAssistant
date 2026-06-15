import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @StateObject private var detailProvider = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: ExploreFilter = .all

    private let foodSuggestions = MockDailyData.foodSuggestions
    private let activities = MockDailyData.activities
    private let highlights = MockDailyData.newsItems

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    header
                    searchField
                    filterChips
                    filteredContent
                }
                .padding(.horizontal, DesignSystem.Padding.screenHorizontal)
                .padding(.top, DesignSystem.Spacing.medium)
                .padding(.bottom, DesignSystem.Spacing.xLarge)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DetailPage.self) { page in
                DetailView(page: page)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("Explore Nearby")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Search food, activities, saved items, and local highlights around Richmond.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DesignSystem.Spacing.xSmall)
    }

    private var searchField: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search restaurants, parks, news", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.medium)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.small) {
                ForEach(ExploreFilter.allCases) { filter in
                    Button {
                        withAnimation(.snappy) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var filteredContent: some View {
        switch selectedFilter {
        case .all:
            if allVisibleItems.isEmpty {
                noResultsView
            } else {
                itemSection(title: "Popular Food Nearby", systemImage: "fork.knife", tint: .orange, items: visibleFoodItems)
                itemSection(title: "Recommended Activities", systemImage: "figure.walk", tint: .green, items: visibleActivityItems)
                itemSection(title: "Local Highlights", systemImage: "sparkles", tint: .teal, items: visibleNewsItems)
                savedItemsSection
            }
        case .food:
            filteredSection(title: "Food Results", systemImage: "fork.knife", tint: .orange, items: visibleFoodItems)
        case .activities:
            filteredSection(title: "Activity Results", systemImage: "figure.walk", tint: .green, items: visibleActivityItems)
        case .news:
            filteredSection(title: "News Results", systemImage: "newspaper.fill", tint: .teal, items: visibleNewsItems)
        case .saved:
            filteredSection(title: "Saved Items", systemImage: "bookmark.fill", tint: .blue, items: visibleSavedItems)
        }
    }

    private var savedItemsSection: some View {
        CardContainer(tint: .blue) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                SectionTitle(title: "Saved Items", systemImage: "bookmark.fill", tint: .blue)

                if visibleSavedItems.isEmpty {
                    savedPlaceholder
                } else {
                    itemRows(visibleSavedItems)
                }
            }
        }
    }

    private func filteredSection(title: String, systemImage: String, tint: Color, items: [ExploreItem]) -> some View {
        Group {
            if items.isEmpty {
                noResultsView
            } else {
                itemSection(title: title, systemImage: systemImage, tint: tint, items: items)
            }
        }
    }

    private func itemSection(title: String, systemImage: String, tint: Color, items: [ExploreItem]) -> some View {
        Group {
            if !items.isEmpty {
                CardContainer(tint: tint) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        SectionTitle(title: title, systemImage: systemImage, tint: tint)
                        itemRows(items)
                    }
                }
            }
        }
    }

    private func itemRows(_ items: [ExploreItem]) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            ForEach(items) { item in
                NavigationLink(value: item.page) {
                    ListItemRow(
                        title: item.title,
                        subtitle: item.subtitle,
                        metadata: item.metadata,
                        systemImage: item.symbolName,
                        tint: item.tint
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var savedPlaceholder: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Image(systemName: "bookmark")
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 34, height: 34)
                .background(Color.blue.opacity(0.13), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("No saved items yet")
                    .font(.subheadline.weight(.semibold))

                Text("Favorite food, activities, or news to keep them here for quick planning.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var noResultsView: some View {
        EmptyStateView(
            title: "No results found",
            message: "Try a different search term or switch filters.",
            systemImage: "magnifyingglass",
            tint: .blue
        )
    }

    private var visibleFoodItems: [ExploreItem] {
        filterSearch(foodItems)
    }

    private var visibleActivityItems: [ExploreItem] {
        filterSearch(activityItems)
    }

    private var visibleNewsItems: [ExploreItem] {
        filterSearch(newsItems)
    }

    private var visibleSavedItems: [ExploreItem] {
        filterSearch(savedItems)
    }

    private var allVisibleItems: [ExploreItem] {
        visibleFoodItems + visibleActivityItems + visibleNewsItems + visibleSavedItems
    }

    private var foodItems: [ExploreItem] {
        foodSuggestions.map { item in
            ExploreItem(
                id: item.id,
                title: item.name,
                subtitle: item.category,
                category: item.category,
                metadata: "\(item.distance)\nStar \(item.rating)",
                symbolName: "fork.knife.circle.fill",
                tint: .orange,
                page: detailProvider.foodDetailPage(for: item)
            )
        }
    }

    private var activityItems: [ExploreItem] {
        activities.map { item in
            ExploreItem(
                id: item.id,
                title: item.title,
                subtitle: item.locationHint,
                category: "Activity",
                metadata: item.duration,
                symbolName: item.symbolName,
                tint: .green,
                page: detailProvider.activityDetailPage(for: item)
            )
        }
    }

    private var newsItems: [ExploreItem] {
        highlights.map { item in
            ExploreItem(
                id: item.id,
                title: item.title,
                subtitle: item.source,
                category: "News",
                metadata: item.time,
                symbolName: "mappin.and.ellipse",
                tint: .teal,
                page: detailProvider.newsDetailPage(for: item)
            )
        }
    }

    private var savedItems: [ExploreItem] {
        favoritesStore.savedItems.map { page in
            ExploreItem(
                id: "saved-\(page.id)",
                title: page.title,
                subtitle: page.subtitle,
                category: page.kind.rawValue,
                metadata: savedMetadata(for: page),
                symbolName: page.symbolName,
                tint: .blue,
                page: page
            )
        }
    }

    private func filterSearch(_ items: [ExploreItem]) -> [ExploreItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return items }

        return items.filter { item in
            item.title.localizedCaseInsensitiveContains(query)
                || item.subtitle.localizedCaseInsensitiveContains(query)
                || item.category.localizedCaseInsensitiveContains(query)
        }
    }

    private func savedMetadata(for page: DetailPage) -> String {
        switch page.kind {
        case .food:
            return page.metadata.first { $0.label == "Distance" }?.value ?? "Saved"
        case .activity:
            return page.metadata.first { $0.label == "Duration" }?.value ?? "Saved"
        case .news:
            return page.metadata.first { $0.label == "Time" }?.value ?? "Saved"
        default:
            return "Saved"
        }
    }
}

private enum ExploreFilter: String, CaseIterable, Identifiable {
    case all
    case food
    case activities
    case news
    case saved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .food:
            return "Food"
        case .activities:
            return "Activities"
        case .news:
            return "News"
        case .saved:
            return "Saved"
        }
    }
}

private struct ExploreItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let metadata: String
    let symbolName: String
    let tint: Color
    let page: DetailPage
}

#Preview {
    ExploreView()
        .environmentObject(FavoritesStore())
}
