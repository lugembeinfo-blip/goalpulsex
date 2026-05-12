# GoalPulseX

GoalPulseX is a modern, high-performance live football scores application built with Flutter. It provides real-time updates, news, and match statistics from leagues across the globe.

## Features

- **Live Scores:** Real-time updates for ongoing matches.
- **Match Filtering:** View Live, Finished, and Upcoming matches.
- **News Feed:** Stay updated with the latest football news.
- **Search:** Easily find your favorite teams and leagues.
- **Favorites:** Save matches to your favorites for quick access.
- **Settings:** Customize your experience with dark mode, timezone settings, and auto-refresh options.

## Project Structure

The project follows a clean architecture pattern:

- `lib/models/`: Data models for matches and news.
- `lib/screens/`: Main application screens (Home, News, Settings).
- `lib/widgets/`: Reusable UI components.
- `lib/services/`: API communication and state management.

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- API-Sports Key (Get one at [api-sports.io](https://api-sports.io/))

### Installation

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Update the API key in `lib/services/api_service.dart`.
4. Run the app using `flutter run`.

## Built With

- [Flutter](https://flutter.dev/) - UI Framework
- [Provider](https://pub.dev/packages/provider) - State Management
- [HTTP](https://pub.dev/packages/http) - Network Requests
- [Cached Network Image](https://pub.dev/packages/cached_network_image) - Image Caching
- [Shimmer](https://pub.dev/packages/shimmer) - Loading Animations
- [Google Fonts](https://pub.dev/packages/google_fonts) - Typography
