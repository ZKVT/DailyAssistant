import MapKit
import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @Environment(\.openURL) private var openURL

    let page: DetailPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                hero
                metadataCard

                CardContainer(tint: accentColor) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(overviewTitle)
                            .font(.headline)

                        Text(page.body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                CardContainer(tint: accentColor) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Helpful Details")
                            .font(.headline)

                        ForEach(page.highlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.subheadline)

                                Text(highlight)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                mapUnavailableMessage
                articleUnavailableMessage
                actionButton
            }
            .padding(DesignSystem.Padding.screenHorizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if page.favoriteID != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        favoritesStore.toggle(page.favoriteID)
                    } label: {
                        Image(systemName: favoritesStore.isFavorite(page.favoriteID) ? "heart.fill" : "heart")
                            .foregroundStyle(favoritesStore.isFavorite(page.favoriteID) ? .red : accentColor)
                    }
                    .accessibilityLabel(favoritesStore.isFavorite(page.favoriteID) ? "Remove Favorite" : "Add Favorite")
                }
            }
        }
    }

    private var hero: some View {
        CardContainer(tint: accentColor) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: page.symbolName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 66, height: 66)
                        .background(accentColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(page.title)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(page.subtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if page.favoriteID != nil {
                    Button {
                        favoritesStore.toggle(page.favoriteID)
                    } label: {
                        Label(favoritesStore.isFavorite(page.favoriteID) ? "Saved" : "Add to Favorites", systemImage: favoritesStore.isFavorite(page.favoriteID) ? "heart.fill" : "heart")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(favoritesStore.isFavorite(page.favoriteID) ? .red : accentColor)
                }
            }
        }
    }

    @ViewBuilder
    private var metadataCard: some View {
        if !page.metadata.isEmpty {
            CardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)

                    ForEach(page.metadata) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Text(item.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(item.value)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private var actionButton: some View {
        Button {
            handlePrimaryAction()
        } label: {
            Label(page.actionTitle, systemImage: actionIconName)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(accentColor)
        .disabled(isPrimaryActionUnavailable)
        .opacity(isPrimaryActionUnavailable ? 0.62 : 1)
    }

    @ViewBuilder
    private var mapUnavailableMessage: some View {
        if isMapAction && page.mapLaunchInfo == nil {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "map")
                    .foregroundStyle(.secondary)

                Text("Map location unavailable")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
        }
    }

    @ViewBuilder
    private var articleUnavailableMessage: some View {
        if isArticleAction && page.articleURL == nil {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)

                Text("Article link unavailable")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
        }
    }

    private var isMapAction: Bool {
        page.actionTitle == "Open in Maps" || (page.kind == .food || page.kind == .activity)
    }

    private var isArticleAction: Bool {
        page.actionTitle == "Read Full Article" || page.kind == .news
    }

    private var isPrimaryActionUnavailable: Bool {
        (isMapAction && page.mapLaunchInfo == nil) || (isArticleAction && page.articleURL == nil)
    }

    private func handlePrimaryAction() {
        if isMapAction {
            openInMaps()
        } else if isArticleAction {
            openArticle()
        }
    }

    private func openInMaps() {
        guard let mapLaunchInfo = page.mapLaunchInfo else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: mapLaunchInfo.latitude, longitude: mapLaunchInfo.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = mapLaunchInfo.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func openArticle() {
        guard let articleURL = page.articleURL else { return }
        openURL(articleURL)
    }

    private var overviewTitle: String {
        switch page.kind {
        case .food:
            return "Why This Works Today"
        case .news:
            return "Story Summary"
        case .activity:
            return "Activity Plan"
        case .weather:
            return "Weather Guidance"
        case .recommendation:
            return "Daily Plan"
        case .general:
            return "Overview"
        }
    }

    private var actionIconName: String {
        if isMapAction {
            return "map.fill"
        }

        switch page.kind {
        case .food, .activity:
            return "location.fill"
        case .news:
            return "safari.fill"
        default:
            return "bookmark.fill"
        }
    }

    private var accentColor: Color {
        switch page.accentName {
        case "WeatherAccent":
            return .blue
        case "RecommendationAccent":
            return .purple
        case "FoodAccent":
            return .orange
        case "NewsAccent":
            return .teal
        case "ActivityAccent":
            return .green
        default:
            return .accentColor
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(page: HomeViewModel().recommendationDetailPage())
            .environmentObject(FavoritesStore())
    }
}
