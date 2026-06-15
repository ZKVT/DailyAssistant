# Daily Local Assistant

Daily Local Assistant is a SwiftUI iOS MVP for a local daily lifestyle dashboard. It helps users open the app once a day and quickly understand the weather, nearby food, activity options, local news, and saved places that matter for today.

The app is built as a portfolio-quality MVP with real Apple framework integrations where they make sense, plus reliable sample-data fallbacks so the experience remains usable when permissions, capabilities, network access, or local services are unavailable.

## Portfolio Summary

This project demonstrates a clean SwiftUI app architecture with onboarding, location permission handling, live weather, local search, RSS news, favorites, adaptive UI states, and polished detail flows. It is intentionally scoped as a practical lifestyle assistant rather than a social app, subscription product, or backend-heavy platform.

## Key Features

- First-launch onboarding flow
- Location setup with CoreLocation when-in-use permission
- Live WeatherKit weather with sample weather fallback
- Dynamic daily recommendation generated from current weather
- MapKit local search for nearby restaurants, cafes, parks, museums, malls, and attractions
- Weather-aware activity search for rainy, cold, sunny, and balanced days
- Apple Maps opening for food and activity detail pages with coordinates
- RSS-based local news service layer with mock fallback
- Safari opening for news articles with URLs
- Explore tab with search, filters, saved items, and empty states
- Local favorites stored with `UserDefaults`
- Loading, empty, and error state components
- Pull to refresh for weather, food, activities, and news
- Settings persisted with `@AppStorage`
- Light mode and dark mode friendly visual design

## Tech Stack

- Swift
- SwiftUI
- CoreLocation
- WeatherKit
- MapKit and `MKLocalSearch`
- URLSession and XMLParser for RSS news
- `@AppStorage` and `UserDefaults`
- SF Symbols
- Apple frameworks only, no third-party dependencies

## Architecture

- `DailyLocalAssistant/Models`: weather, food, news, activity, detail, map launch, and view state models
- `DailyLocalAssistant/MockData`: sample fallback data for the MVP
- `DailyLocalAssistant/ViewModels`: home state, recommendation engine, favorites store
- `DailyLocalAssistant/Services`: CoreLocation, WeatherKit, MapKit local search, and RSS news services
- `DailyLocalAssistant/Views`: onboarding, location setup, tabs, home, explore, details, settings
- `DailyLocalAssistant/Components`: reusable cards, rows, design system, loading, empty, and error states

The service layer is intentionally small and replaceable, so production APIs can be introduced later without rewriting the UI.

## Screenshots

Replace these placeholder paths with real screenshots exported from Xcode or the simulator:

| Home Screen | Explore Screen |
| --- | --- |
| ![Home Screen](renders/home.png) | ![Explore Screen](renders/explore.png) |

| Detail Screen | Settings Screen |
| --- | --- |
| ![Detail Screen](renders/detail.png) | ![Settings Screen](renders/settings.png) |

| Onboarding Screen |
| --- |
| ![Onboarding Screen](renders/onboarding.png) |

## App Icon Guidance

Recommended app icon concept:

- Modern iOS lifestyle assistant icon
- Sun symbol
- Map pin
- Subtle city skyline
- Soft gradient background
- No text
- Clean, premium, friendly style

Asset requirements:

- Provide a full App Store icon at `1024x1024`
- Avoid transparency for the final app icon
- Keep important visual elements centered and readable at small sizes
- Export through Xcode asset catalogs using `Assets.xcassets/AppIcon.appiconset`
- Test the icon on light and dark home screen wallpapers

## Setup Instructions

1. Open `DailyLocalAssistant.xcodeproj` in Xcode on macOS.
2. Select an iPhone simulator or a physical iPhone.
3. Configure signing for your development team.
4. Run the app with `Cmd + R`.
5. Complete onboarding and choose either live location or sample location.

## WeatherKit Setup

Live WeatherKit requires:

- An Apple Developer account
- WeatherKit capability enabled for the app identifier
- Proper signing configuration in Xcode
- A simulator or device that can provide location

If WeatherKit is unavailable, the app falls back to sample weather.

## Data And Fallbacks

- Location denied or restricted: app continues with sample location
- WeatherKit unavailable: sample weather is shown
- MapKit local search failure: sample food and activity suggestions are shown
- RSS/news fetch failure: sample news is shown
- Missing map coordinates: detail page shows `Map location unavailable`
- Missing news URL: detail page shows `Article link unavailable`
- Empty favorites: Explore shows a friendly saved-items placeholder
- Empty search results: Explore shows a reusable empty state

## Current Status

This is a final MVP polish pass suitable for portfolio presentation. It has live Apple framework integrations for location, weather, maps, and RSS-based news, with graceful sample-data fallback. There is no login, subscription, backend, AI chat, or third-party dependency.

## Future Improvements

- Add richer MapKit categories, sorting, and distance controls
- Replace RSS with a dedicated local news API when ready
- Add real directions actions and route previews
- Add richer saved place management
- Add home screen widgets for the daily summary
- Add unit tests for recommendation rules, service fallbacks, and favorites persistence
- Add UI tests for onboarding, permission fallback, search, and detail actions
