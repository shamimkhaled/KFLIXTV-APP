# Kloud TV

A lightweight, **APK-only** Android app that aggregates ISP FTP servers,
movie portals, and Live TV streams into a single Netflix-style home screen.

- **No backend** - no auth, no registration, no database.
- **No API keys** - everything is static, offline-config-driven.
- Portals are loaded on-device via `WebView`.

---

## Features

- Material 3 UI with Dark mode (default), Light mode, and System theme.
- Home screen with gradient header, category filters, "Recently Opened" and
  "Featured Portals" rails, and a responsive 2-column portal grid.
- Real-time search across portal names and categories.
- Favorites, persisted locally with `shared_preferences`.
- Best-effort online/offline status indicator per portal (async HTTP check).
- Global "No internet connection" banner via `connectivity_plus`.
- Full-screen WebView player with:
  - JavaScript enabled, mixed HTTP content allowed.
  - Landscape rotation for fullscreen HTML5 video.
  - Pull-to-refresh, loading progress bar, WebView back-history navigation.
  - Error fallback with **Retry** and **Open in Browser**.
- Settings screen: theme toggle, clear WebView cache, clear favorites, about,
  and app version (via `package_info_plus`).

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, providers, theming
├── models/
│   └── portal.dart            # Portal model + enums
├── data/
│   └── portals.dart            # Static list of all portals (edit me!)
├── providers/
│   ├── theme_provider.dart
│   ├── favorites_provider.dart
│   └── portal_provider.dart
├── services/
│   ├── storage_service.dart        # SharedPreferences wrapper
│   ├── connectivity_service.dart   # Device online/offline state
│   └── portal_status_service.dart  # Per-portal reachability checks
├── screens/
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   ├── webview_screen.dart
│   └── root_scaffold.dart      # Bottom navigation shell
├── widgets/
│   ├── portal_card.dart
│   ├── category_tabs.dart
│   ├── status_indicator.dart
│   └── offline_banner.dart
└── utils/
    ├── app_theme.dart
    └── app_router.dart          # go_router configuration
```

---

## Adding / Editing Portals

All portals are defined as a static `const` list in
[`lib/data/portals.dart`](lib/data/portals.dart). To add a portal:

```dart
Portal(
  name: 'My New Portal',
  url: 'http://example.com/',
  category: PortalCategory.movies, // or PortalCategory.liveTv
  isFeatured: false,                // true to show in "Featured Portals"
),
```

No other code changes are required - the grid, search, favorites, and
status checks all read from this list automatically.

---

## Setup

### Prerequisites

- [Flutter SDK 3.x](https://docs.flutter.dev/get-started/install) (stable channel)
- Android SDK with **API level 35** installed (via Android Studio SDK Manager)
- A connected device or emulator running Android 5.0 (API 21) or higher

### Install dependencies

```bash
flutter pub get
```

### Run in debug mode

```bash
flutter run
```

---

## Building the Release APK

```bash
flutter build apk --release
```

The output APK will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

To build a smaller, per-architecture set of APKs:

```bash
flutter build apk --release --split-per-abi
```

> **Note:** The release build uses the debug signing config out of the box
> so it can be built immediately for testing/sideloading. Before publishing,
> create your own keystore and update `android/app/build.gradle`
> (`signingConfigs`) accordingly.

---

## Notes on Portals

- Most portals use **plain HTTP**. `usesCleartextTraffic="true"` is enabled
  in `AndroidManifest.xml` and the WebView's mixed-content mode is set to
  `alwaysAllow` so these load correctly.
- Many portals reference **private/LAN IP addresses** (e.g. `172.16.x.x`,
  `10.x.x.x`). These will only be reachable while connected to the
  corresponding ISP's network (e.g. via their broadband connection or a VPN
  that routes to that network). The online/offline indicator reflects this -
  a portal showing "Offline" may simply be unreachable from your current
  network.

---

## Tech Stack

| Concern              | Package              |
| --------------------- | -------------------- |
| State management      | `provider`            |
| Navigation             | `go_router`           |
| WebView                | `webview_flutter` (+ Android/WKWebView platform packages) |
| Local persistence      | `shared_preferences`  |
| Connectivity           | `connectivity_plus`   |
| App version info       | `package_info_plus`   |
| Reachability checks    | `http`                |
| "Open in Browser"      | `url_launcher`        |
