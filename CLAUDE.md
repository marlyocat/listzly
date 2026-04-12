# Listzly - Claude Code Guidelines

## Project Overview

Listzly is a Flutter mobile app for music practice tracking. Students and teachers use it to log practice sessions, complete quests, track streaks, earn XP, and manage student groups. The backend is Supabase (PostgreSQL + Auth + Storage). Subscriptions are handled via RevenueCat.

## Tech Stack

- **Framework:** Flutter (Dart SDK ^3.10.8)
- **State Management:** Riverpod 3 with code generation (`@riverpod` annotations)
- **Backend:** Supabase (auth, database, storage)
- **Subscriptions:** RevenueCat (purchases_flutter)
- **Serialization:** json_annotation + json_serializable with build_runner code generation
- **Platforms:** iOS and Android (primary), web/desktop (experimental)

## Project Structure

```
lib/
  main.dart              # Entry point, initialization, routing
  config/                # Supabase and RevenueCat configuration
  models/                # Data classes with JSON serialization (*.g.dart generated)
  services/              # Business logic and Supabase API calls
  providers/             # Riverpod providers (*.g.dart generated)
  pages/                 # Full-screen pages/routes
  components/            # Reusable UI widgets
  theme/                 # Color constants and design tokens
  utils/                 # Helpers (level math, responsive, avatars)
  images/licensed/       # SVG icons, Lottie animations, avatars
assets/                  # App icons, splash assets
google_fonts/            # Bundled Nunito and DM Serif Display fonts
```

## Key Commands

```bash
# Get dependencies
flutter pub get

# Run code generation (models, providers, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate app icons
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create
```

## Architecture & Patterns

### State Management (Riverpod)
- All providers live in `lib/providers/` with `@riverpod` annotations
- Generated files (`*.g.dart`) must be regenerated after changing provider signatures
- Providers use `ref.watch()` for reactive dependencies
- Profile provider uses local caching (SharedPreferences) with background Supabase refresh

### Models
- All models use `@JsonSerializable()` from json_annotation
- Generated files (`*.g.dart`) must be regenerated after changing model fields
- Supabase column names use snake_case; Dart fields use camelCase (handled by `@JsonKey`)

### Services
- Each service is a plain Dart class that calls Supabase directly
- Services do NOT hold state; state lives in providers
- `OfflineSessionQueue` stores sessions locally when offline and flushes on reconnect

### Routing
- No declarative router; uses imperative `Navigator.push()` with a global `navigatorKey`
- Auth flow: `IntroPage` -> `AuthPage` -> `AuthGate` -> `OnboardingPage` (role selection) -> `HomePage`
- `HomePage` uses a bottom nav bar with tabs: Home, Quests, Activity, Students (teacher only), Profile

## Key Features & Behavior

### Practice Sessions
- Instrument selection with daily goal-based duration suggestion (remaining minutes to goal)
- Duration slider clamped to 5–120 minutes
- Optional audio recording during sessions (M4A codec, Pro feature)
- Background music auto-pauses during practice, resumes after

### Music Player
- Built-in song library + local music uploads (up to 5 songs stored in `local_music/`)
- Full playback controls: play/pause/seek, loop modes (off/all/one), queue management
- Favorites system for both built-in and uploaded songs
- Now Playing banner on home tab

### Recordings
- Saved locally and optionally shared with teacher (`shared_with_teacher` toggle)
- Teachers stream shared recordings via Supabase signed URLs
- Download to device via `flutter_file_dialog`, delete locally + from storage
- File size tracking per recording

### Teacher Groups & Notifications
- Real-time group notifications: student joined/left/removed
- Mark as read / delete all notifications
- Per-instrument stats visible on student detail pages

### Settings (persisted in Supabase `user_settings` table)
- Daily goal minutes, reminder time, sound effects toggle
- Theme (system/dark), language, first day of week
- Progress bar visibility toggle

### Role Switching
- Users can switch between Teacher and Self-Learner from Profile page at any time

## User Roles & Subscriptions

### Roles (selected during onboarding)
- **Self-Learner** - Practices independently
- **Student** - Can join a teacher's group via QR code
- **Teacher** - Creates groups, assigns quests, views student progress

### Subscription Tiers
- **Free** - Basic practice tracking
- **Pro** - Recording, full activity history, background music
- **Teacher Lite/Pro/Premium** - Teacher features with 10/25/50 student limits
- Teacher plan students inherit Pro features
- Free trial support via RevenueCat (trial eligibility checks, trial periods shown on paywall)

## Important Conventions

- Dark theme only with purple gradient backgrounds (see `lib/theme/colors.dart`)
- Primary color: Deep Violet `#7C3AED`, Accent: Coral `#F4A68E`
- Custom fonts: Nunito (body), DM Serif Display (headings)
- Portrait-locked on phones (<600dp), tablets can rotate
- XP system: 1 XP per minute practiced; level formula: `xp = 30 * (level-1)^1.2`
- Max level: 999

## Sensitive Files

- `lib/config/supabase_config.dart` - Supabase URL, anon key, Google OAuth client ID
- `lib/config/revenuecat_config.dart` - RevenueCat API keys

## Testing

- Test directory: `test/`
- Uses `flutter_test` (standard Flutter testing framework)
