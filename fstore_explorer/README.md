# 🛍️ Product Feed App — fstore_explorer

A Flutter product discovery app built on [FakeStoreAPI](https://fakestoreapi.com) — browse products, express style preferences with like/dislike, and explore products in a built-in WebView browser with full browsing history tracking. Powered by **Riverpod** for state management and **Hive** for local persistence.

---

## 📱 Screenshots    
<img width="622" height="911" alt="image" src="https://github.com/user-attachments/assets/e194a0b5-b4ba-4a4e-879c-de986aad692e" />     <img width="622" height="906" alt="image" src="https://github.com/user-attachments/assets/c83dd155-2618-4b27-9461-1e9dac30b2e7" />
<img width="622" height="907" alt="image" src="https://github.com/user-attachments/assets/a873de72-eb19-49a2-b4ee-c76efcae4d74" />      <img width="620" height="906" alt="image" src="https://github.com/user-attachments/assets/84f2166b-62c0-4b5d-93bf-f2097bb2d9ed" />


> 

---

## ✨ Features

- 🛒 **Product Feed** — Browse all products with image, title, price, and rating
- 🔍 **Search** — Real-time search across product titles and categories
- 🏷️ **Category Filter** — Filter by electronics, clothing, jewelery, and more
- ❤️ **Like / Dislike** — Express preferences per product with instant UI feedback
- 💾 **Persistent Preferences** — Likes and dislikes survive app restarts
- 📦 **Offline Caching** — Products cached locally; works without internet after first load
- 🌐 **In-App Browser** — Open any product in a built-in WebView
- 🔗 **URL Launcher** — Platform-aware external URL launching (mobile/web/stub)
- 🕐 **Browsing History** — All visited URLs tracked and displayed with timestamps
- ⬛ **Shimmer Loading** — Skeleton loaders for a polished loading experience
- 🎞️ **Staggered Animations** — Smooth grid entry animations

---

## 🏗️ Project Structure

```
lib/
├── main.dart                            # App entry point, Hive init, ProviderScope
├── models/
│   ├── product_model.dart               # Product data class + Hive adapter
│   └── browse_history_model.dart        # BrowseHistory data class + Hive adapter
├── services/
│   ├── api_service.dart                 # Dio-based HTTP client for FakeStoreAPI
│   └── storage_service.dart             # Hive operations (likes, history, cache)
├── providers/
│   ├── product_provider.dart            # Products state — loading, filtering, search
│   ├── preference_provider.dart         # Like/dislike toggle logic
│   └── history_provider.dart            # Browse history state
├── screens/
│   ├── home_screen.dart                 # Main product feed with search + tabs
│   ├── product_detail_screen.dart       # Product info + like/dislike + open browser
│   ├── webview_screen.dart              # In-app browser with history tracking
│   └── history_screen.dart             # Browsing history list
├── utils/
│   ├── url_launcher_mobile.dart         # Mobile-specific URL launch implementation
│   ├── url_launcher_stub.dart           # Stub for unsupported platforms
│   ├── url_launcher_web.dart            # Web-specific URL launch implementation
│   └── url_utils.dart                   # Conditional URL launching (mobile/web/stub)
└── widgets/
    ├── product_card.dart                # Reusable product grid card
    └── shimmer_loader.dart              # Skeleton loading grid
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin

### Installation

**Step 1 — Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/fstore_explorer.git
cd fstore_explorer
```

**Step 2 — Install all dependencies**
```bash
flutter pub add flutter_riverpod dio hive hive_flutter shared_preferences webview_flutter url_launcher cached_network_image shimmer flutter_staggered_animations
```

**Step 3 — Install dev dependencies**
```bash
flutter pub add --dev hive_generator build_runner flutter_lints
```

**Step 4 — Generate Hive adapters (required before first run)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Step 5 — Run the app**
```bash
flutter run
```

---

### Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Packages Used

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client with timeout & error handling |
| `hive` | Local NoSQL database |
| `hive_flutter` | Flutter-specific Hive integration |
| `hive_generator` | Code generation for Hive adapters |
| `build_runner` | Runs code generation |
| `shared_preferences` | Simple key-value storage |
| `webview_flutter` | In-app browser |
| `url_launcher` | Platform-aware external URL launching |
| `cached_network_image` | Network image caching |
| `shimmer` | Skeleton loading animations |
| `flutter_staggered_animations` | Grid entry animations |
| `flutter_lints` | Dart lint rules |

---

## 🌐 API Reference

Base URL: `https://fakestoreapi.com`

| Endpoint | Used For |
|---|---|
| `GET /products` | Fetch all products |
| `GET /products/:id` | Fetch single product |
| `GET /products/categories` | Fetch all categories |
| `GET /products/category/:name` | Fetch products by category |

---

## 🗺️ Screen Overview

### 🏠 Home Screen
- 2-column product grid with shimmer skeleton on load
- Horizontal category chip filter bar
- Real-time search bar
- Tab filter — **All / Liked ❤️ / Disliked 👎**
- History icon → navigates to History Screen

### 📄 Product Detail Screen
- Full product image, title, price, category badge, rating, description
- Like / Dislike buttons (animated and persistent)
- **"Open in Browser"** button → opens WebView Screen

### 🌐 WebView Screen
- Full in-app browser with progress bar
- Every page visited automatically saved to history
- Refresh button in app bar

### 🕐 History Screen
- All visited URLs sorted newest first
- Product thumbnail shown where available
- Relative timestamps — *"3m ago", "2h ago"*
- Tap any entry to re-open in WebView
- Clear all history with confirmation dialog

---

## 🧠 Approach

### Architecture
Clean layered architecture with clear separation of concerns:

- **Data Layer** — `ApiService` handles all HTTP calls via Dio. `StorageService` wraps all Hive operations so the rest of the app never touches Hive directly.
- **State Layer** — Riverpod `StateNotifier` classes manage each domain (products, preferences, history) independently.
- **UI Layer** — Screens consume providers via `ConsumerWidget`. Zero business logic in the UI.
- **Utils Layer** — Platform-aware utilities like URL launching are isolated in the `utils/` folder using conditional imports, keeping platform differences out of business logic.

### Offline-First Strategy
Products load from Hive cache instantly on startup, then the API is called silently in the background to refresh data. Users always see content immediately, even on a slow or no connection.

### Platform-Aware URL Launching
The `utils/` folder follows a **conditional import pattern**:

```
url_utils.dart
 ├── imports url_launcher_mobile.dart  →  on Android / iOS
 ├── imports url_launcher_web.dart     →  on Flutter Web
 └── imports url_launcher_stub.dart    →  on unsupported platforms
```

This keeps platform-specific code fully isolated and makes the rest of the app platform-agnostic.

---

## ⚙️ State Management — Riverpod

**Why Riverpod?**

| Reason | Benefit |
|---|---|
| `StateNotifier` | Clean separation of state logic from UI |
| Provider overrides | Easy to inject `StorageService` initialized in `main()` |
| No `BuildContext` needed | Providers work anywhere, including services |
| Compile-time safety | Catch provider errors at build time, not runtime |
| Easy to test | Override providers in tests with no ceremony |

Three `StateNotifier` providers used:
- `productsProvider` — API fetch, category filter, search, caching
- `preferenceProvider` — like/dislike toggles and persistence
- `historyProvider` — adding and clearing browse history

---

## 💾 Data Persistence — Hive

**Why Hive over SharedPreferences or SQLite?**

- **Speed** — Pure Dart NoSQL; reads/writes are nearly instant
- **No native code** — Works on all platforms without extra setup
- **Type-safe adapters** — `@HiveType` annotations generate compile-safe serialization
- **Simple API** — Feels like a Map but with full persistence

**What is stored:**

| Hive Box | Content |
|---|---|
| `preferences` | Sets of liked and disliked product IDs |
| `history` | `BrowseHistory` objects — url, title, timestamp, image |
| `cached_products` | All products from API for offline access |

---

## 🐛 Error Handling

- **Network errors** — User-friendly message shown with a Retry button on the feed
- **API timeout** — Dio configured with 10s connect and receive timeouts
- **Cached fallback** — If API fails but cache exists, cached data shown silently
- **Image errors** — `CachedNetworkImage` shows a broken image icon gracefully
- **WebView errors** — Loading indicator dismissed cleanly on resource errors
- **URL launch errors** — Stub implementation handles unsupported platforms gracefully

---

## 🔧 What I Would Improve With More Time

1. **Unit & Widget Tests** — Test `ProductsNotifier`, `PreferenceNotifier`, and key widgets
2. **Pagination** — Load products in pages for better performance at scale
3. **Swipe Cards** — Tinder-style swipe left (dislike) / right (like) interaction
4. **Offline Banner** — Show a notice when app is running on cached data
5. **Sort Options** — Sort by price (low/high) and by rating
6. **Share Product** — Share product links via the native share sheet
7. **Dark / Light Theme Toggle** — User-selectable theme preference
8. **Better WebView** — Add forward/back navigation buttons

---

## ⏱️ Approximate Time Spent

| Task | Time |
|---|---|
| Project setup + dependencies | ~30 min |
| Models + Hive adapters | ~30 min |
| API service + Storage service | ~45 min |
| Riverpod providers | ~1 hr |
| Home screen + Product card | ~1.5 hr |
| Product detail screen | ~45 min |
| WebView screen + History tracking | ~1 hr |
| History screen | ~30 min |
| Utils — URL launcher (platform-aware) | ~30 min |
| Polish (shimmer, animations, error UI) | ~45 min |
| README + cleanup | ~30 min |
| **Total** | **~8 hrs** |

---

## 📤 Submission Checklist

- ✅ GitHub repository with full source code
- ✅ APK file (attached separately)
- ✅ 3–5 minute demo video
- ✅ README with approach, decisions, and improvements

---

## 📬 Contact

Built by **Nitin**
Submitted to: viswas@beespoke.ai

---

*Built with ❤️ using Flutter · Riverpod · Hive · FakeStoreAPI*
