<div align="center">

# 📺 KFLIX TV

**A modern IPTV & Media Portal aggregator for Android, Android TV, Web & Windows**

[![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android)](https://android.com)
[![Android TV](https://img.shields.io/badge/Android%20TV-✓-00BCD4?logo=androidtv)](https://android.com/tv)
[![Web](https://img.shields.io/badge/Web-✓-FF6F00?logo=googlechrome)](https://flutter.dev/web)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

</div>

---

## ✨ Overview

KFLIX TV brings together **ISP FTP servers**, **Movie portals**, and **Live TV streams** into a single, Netflix-style home screen — with a dedicated **FIFA World Cup 2026** section that fetches live match data in real time.

- 🚫 **No backend** — no auth, no registration, no database
- 🚫 **No API keys** — portals are static config-driven
- ✅ **Works offline** — cached data & fallback mode
- ✅ **Runs locally** — everything on your device

---

## 📱 Platform Support

| Platform | Status | Notes |
|---|---|---|
| 📱 Android Mobile | ✅ Full support | WebView embedded player |
| 📺 Android TV / Google TV | ✅ Full support | D-pad navigation, TV launcher banner, NavigationRail |
| 🌐 Web | ✅ Supported | Portals open in new browser tab |
| 🪟 Windows | ✅ Supported | Portals open in default browser |
| 🍎 iOS / macOS | ⚠️ Requires Mac + Xcode | Build with `flutter build ipa` |

---

## 🏆 Features

### Home Screen
- Auto-rotating **hero banner** for featured portals (5s interval, swipeable)
- **Category filters** — All · Movies · Live TV · Favorites
- **Recently Opened** horizontal rail
- Responsive portal grid — 2 cols (mobile) → 3 (tablet) → 4 (TV)
- Portals **sorted by status** — 🟢 Online first, 🔴 Offline last
- Real-time online/offline status indicator per portal

### FIFA World Cup 2026 🏆
- **Live match data** fetched from ESPN public API (no key needed)
- Tabs: Live · Upcoming · Completed · Highlights
- Live match count badge on nav tab with red glow
- Match detail with **6 stream servers** + status indicators
- One-click server switching & auto-failover
- Auto-refresh every 60 s during live matches
- Pull-to-refresh on all tabs

### Portal Player
- Full-screen **WebView** player with JavaScript & mixed content
- Landscape rotation for HTML5 fullscreen video
- Pull-to-refresh, loading progress bar, back-history navigation
- Error fallback with Retry & Open in Browser

### Other
- 🔍 Full-text search across all portals
- ❤️ Favorites — persisted locally
- 🌙 Dark / Light / System theme
- 📶 Global offline banner
- ⚙️ Settings — theme, cache, about

---

## 🗂️ Project Structure

```
lib/
├── main.dart
├── models/
│   ├── portal.dart              # Portal model + enums
│   └── match.dart               # WorldCupMatch model
├── data/
│   ├── portals.dart             # Static portal list (edit here to add portals)
│   └── world_cup_data.dart      # WC stream servers + fallback match data
├── providers/
│   ├── theme_provider.dart
│   ├── favorites_provider.dart
│   ├── portal_provider.dart     # Search, filter, status (sorted online-first)
│   └── world_cup_provider.dart  # Live fetch, server selection, auto-refresh
├── services/
│   ├── storage_service.dart         # SharedPreferences wrapper
│   ├── connectivity_service.dart    # Online/offline detection
│   ├── portal_status_service.dart   # Per-portal HTTP reachability checks
│   └── match_service.dart           # ESPN API — live WC match data
├── screens/
│   ├── root_scaffold.dart           # Responsive nav (bar ↔ rail)
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   ├── webview_screen.dart          # Platform-adaptive portal viewer
│   ├── world_cup_screen.dart        # FIFA WC tabs
│   └── match_detail_screen.dart     # Scoreboard + server picker
├── widgets/
│   ├── hero_banner.dart             # Auto-rotating featured banner
│   ├── portal_card.dart
│   ├── match_card.dart
│   ├── category_tabs.dart
│   ├── status_indicator.dart
│   └── offline_banner.dart
└── utils/
    ├── app_theme.dart
    ├── app_router.dart
    └── country_flags.dart           # Country name → emoji flag mapping
```

---

## ➕ Adding Portals

Edit [`lib/data/portals.dart`](lib/data/portals.dart) — no other changes needed:

```dart
Portal(
  name: 'My Portal',
  url: 'http://example.com/',
  category: PortalCategory.movies,   // or PortalCategory.liveTv
  isFeatured: true,                  // shows in hero banner
),
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK 3.22+](https://docs.flutter.dev/get-started/install) (stable)
- Android SDK API 35 (via Android Studio)
- Android device / emulator running Android 5.0+ (API 21+)

### Install dependencies
```bash
flutter pub get
```

### Run debug
```bash
# Android mobile / TV
flutter run

# Web
flutter run -d web-server --web-port 8080

# Windows
flutter run -d windows
```

---

## 📦 Building

### Android APK (Mobile + Android TV)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Web
```bash
flutter build web --release
# Output: build/web/   ← deploy to Netlify / Firebase / any static host
```

### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### iOS (requires macOS + Xcode)
```bash
flutter create --platforms=ios .
flutter build ipa --release
```

---

## 🛠️ Tech Stack

| Concern | Package |
|---|---|
| State management | `provider` |
| Navigation | `go_router` |
| WebView player | `webview_flutter` |
| Persistence | `shared_preferences` |
| Connectivity | `connectivity_plus` |
| HTTP / API fetch | `http` |
| Open in browser | `url_launcher` |
| App version | `package_info_plus` |

---

## ⚽ FIFA World Cup 2026 Servers

| # | URL |
|---|---|
| Server 1 | `http://172.19.17.28/` |
| Server 2 | `http://172.16.60.2/` |
| Server 3 | `http://172.16.200.205/` |
| Server 4 | `http://10.99.99.99/` |
| Server 5 | `http://moviemazic.xyz/live-tv/tsports.html` |
| Server 6 | `http://172.20.21.22/live_tv.php?key=1` |

> Most LAN IP servers are only reachable on the corresponding ISP's network.

---

## 📝 Notes

- HTTP portals work because `usesCleartextTraffic="true"` is set in the manifest and WebView mixed-content mode is `alwaysAllow`
- LAN IPs (`172.x.x.x`, `10.x.x.x`) are only reachable on their local ISP network
- The 🔴 Offline indicator just means unreachable from your current network — not necessarily down

---

## 📄 License

MIT © 2026 KFLIX TV
