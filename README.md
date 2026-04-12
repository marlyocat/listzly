# Listzly

A music practice app for students and teachers to track sessions, set goals, and stay motivated.

## Features

### Practice Tracking
- Timed practice sessions with instrument selection and duration targets
- XP and leveling system (1 XP per minute, exponential level curve)
- Streak tracking with daily reminders and streak-loss warnings
- Offline session queuing with automatic sync

### Quest System
- Daily quests (XP goals, time goals, session count goals)
- Teacher-assigned quests for students with custom targets and XP rewards
- Recurring and one-time quest support

### Teacher & Student Tools
- Teachers create groups and invite students via QR code
- Student progress dashboard with per-instrument stats, recordings, and quest tracking
- Real-time group notifications (student joined/left/removed, mark as read)
- Per-student detail views with practice history and assigned quests

### Settings & Personalization
- Daily practice goal (minutes), reminder time, sound effects
- Role switching between Teacher and Self-Learner at any time
- Customizable avatar selection

### Audio & Music
- Record practice sessions (M4A) and optionally share with teachers
- Background music player with loop modes, queue, and favorites
- Upload local music files (up to 5 songs)
- Now Playing banner on the home screen
- Auto-pause music during practice, resume after

### Recordings Management
- Download recordings to device or delete from storage
- Students toggle per-recording sharing with their teacher
- Teachers stream shared student recordings

### Subscriptions
- **Free** - Core practice tracking, quests, and streaks
- **Personal Pro** - Audio recording, full activity history, background music (with free trial)
- **Teacher Lite / Pro / Premium** - Student management (10 / 25 / 50 students), quest assignment, student recording access
- Teacher-plan students inherit Pro features automatically

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod 3 (code generation) |
| Backend | Supabase (PostgreSQL, Auth, Storage) |
| Subscriptions | RevenueCat |
| Auth | Email/password, Google Sign-In |
| Notifications | flutter_local_notifications (timezone-aware) |
| Audio | record, just_audio |
| QR Codes | qr_flutter, mobile_scanner |

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.8
- Dart SDK ^3.10.8
- Android Studio or Xcode (for mobile builds)

### Setup

```bash
# Clone the repository
git clone https://github.com/listzly/listzly.git
cd listzly

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device
flutter run
```

### Code Generation

Models and providers use code generation. After modifying any `@riverpod` provider or `@JsonSerializable` model, regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
  main.dart              # App entry point and initialization
  config/                # Supabase and RevenueCat configuration
  models/                # Data models with JSON serialization
  services/              # Backend services and business logic
  providers/             # Riverpod state providers
  pages/                 # App screens and routes
  components/            # Reusable UI components
  theme/                 # Colors and design tokens
  utils/                 # Helpers (leveling, responsive layout, avatars)
```

## Architecture

- **Riverpod providers** manage all reactive state; services are stateless
- **Supabase** handles auth (email + Google OAuth), PostgreSQL database, and file storage (recordings)
- **RevenueCat** manages subscription purchases and entitlement checks
- **Offline-first** session queue stores practice data locally and syncs when connected
- **Profile caching** returns cached data instantly while refreshing from Supabase in the background

## Design

- Dark theme with purple gradient backgrounds
- Primary: Deep Violet (`#7C3AED`), Accent: Coral (`#F4A68E`)
- Fonts: Nunito (body), DM Serif Display (headings)
- Portrait-locked on phones, free rotation on tablets

## Version

Current: **1.0.5** (Build 20)
