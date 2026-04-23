# QuickPlay

QuickPlay is a Flutter mini-game hub that brings together short, fast, replayable games in one mobile app experience.

The app includes a multi-screen flow (splash, login, home, profile, leaderboard, settings), smooth route transitions, reusable game UI widgets, and a data-driven game registry for fast expansion.

## Highlights

- 15 playable mini games
- Category-based game discovery
- Pre-game instruction screen per title
- Local state and progression patterns with Provider
- Shared UI components and theme system
- Cross-platform Flutter project setup (Android, iOS, Web)

## Mini Games Included

Total games: 15

### Reflex

1. Color Switch Rush
2. Tile Tap Speed
3. Target Drop

### Survival

1. Dodge Drop
2. Balance the Ball
3. Avoid Laser

### Puzzle

1. Memory Flip
2. Slide Block Mini
3. Connect Lines
4. Merge Numbers

### Brain

1. 5-Second Brain
2. Odd One Out
3. Quick Decision

### Precision

1. Perfect Hit
2. Stack Tower 2.0

## Tech Stack

- Flutter (Dart)
- Provider (state management)
- go_router (navigation)
- shared_preferences (local persistence)
- google_fonts (typography)
- flutter_animate (UI motion)
- device_preview (preview/testing support)

## Project Structure

```text
lib/
	app.dart
	main.dart
	core/
		constants/
		models/
		providers/
		services/
		theme/
		widgets/
	features/
		auth/
		games/
		home/
		leaderboard/
		profile/
		settings/
		splash/
	navigation/
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Dart SDK (bundled with Flutter)
- Android Studio, Xcode, or Chrome (for target platform)

### Install and Run

```bash
flutter pub get
flutter run
```

### Useful Commands

```bash
flutter analyze
flutter test
```

## Navigation Overview

- App starts at splash screen
- Login screen entry flow
- Main shell with bottom navigation:
	- Home
	- Leaderboard
	- Profile
- Settings route
- Data-driven per-game routes:
	- Pre-game route
	- Gameplay route

## Assets

Game art and branding assets are located under:

- assets/images/
- assets/images/games/

## Current Version

- 0.1.0+1

## License

No license is currently declared in this repository.
