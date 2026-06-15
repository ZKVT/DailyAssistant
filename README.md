# Daily Local Assistant

Daily Local Assistant is a SwiftUI iOS MVP for a local daily lifestyle dashboard. It helps users quickly understand what to do today using mock weather, food suggestions, local news, activities, saved items, and preference settings.

The current version is designed as a polished pre-API prototype. It uses mock data only and does not connect to WeatherKit, MapKit, news APIs, restaurant APIs, or a backend yet.

## Key Features

- First-launch onboarding flow
- Location setup placeholder without requesting real permission
- Today dashboard with weather, food, news, activities, and a dynamic daily recommendation
- Explore tab with local mock search and filters
- Detail pages with metadata, placeholder actions, and favorite controls
- Local favorites stored on device
- Pull to refresh with simulated mock updates
- Loading, empty, and error state components
- Settings saved locally with `@AppStorage`
- Light mode and dark mode friendly UI

## Tech Stack

- Swift
- SwiftUI
- MVVM-style view models
- `@AppStorage` and `UserDefaults` for lightweight local persistence
- Mock data only
- SF Symbols

## Architecture Overview

- `DailyLocalAssistant/Models`: app data models, detail models, view state models
- `DailyLocalAssistant/MockData`: local mock data for weather, food, news, and activities
- `DailyLocalAssistant/ViewModels`: home state, recommendation engine, favorites store
- `DailyLocalAssistant/Views`: onboarding, location setup, tabs, home, explore, details, settings
- `DailyLocalAssistant/Components`: reusable cards, rows, design system, loading, empty, and error states

The code is structured so real services can be added later behind dedicated service layers without rewriting the core UI.

## Current Status

This is an App Store-quality MVP prototype focused on the local daily assistant experience. It is not production-connected yet. All displayed weather, recommendations, food, news, and activity content comes from mock data.

## Screenshots

Add screenshots here when running the app from Xcode:

- Onboarding
- Today dashboard
- Explore search and filters
- Detail page
- Settings

## Future Improvements

- Add real location permission through CoreLocation
- Connect weather data through WeatherKit
- Add restaurant discovery through a local places API
- Add local news through a trusted news provider
- Add map and directions support
- Add richer saved places management
- Add widget or notification support for the daily summary
- Add unit tests for recommendation rules and favorites persistence

## Notes

- This app is iOS-only.
- The UI text is English-only.
- There is no login, subscription, backend, AI chat, or external API integration in the current version.
