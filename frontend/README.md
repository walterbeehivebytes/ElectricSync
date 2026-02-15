# ElectricSync Frontend

Flutter mobile application for electricians, journeymen, and foremen.

## Features

- Splash screen with animated lightning logo
- Home screen with navigation bar
- Quick stats dashboard
- Recent activity feed
- Navigation tabs: Home, Projects, Tasks, Profile

## Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (included with Flutter)

## Setup

1. Install Flutter if you haven't already:
   ```bash
   https://flutter.dev/docs/get-started/install
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/
│   ├── splash_screen.dart # Animated splash screen
│   └── home_screen.dart   # Main home screen with tabs
└── widgets/               # Reusable widgets (future)

assets/
└── images/
    └── lightning_logo.png # App logo
```

## Available Screens

### Splash Screen
- Animated fade-in effect
- Lightning bolt logo
- Auto-navigates to home after 3 seconds

### Home Screen
- **Home Tab**: Welcome card, quick stats, recent activity
- **Projects Tab**: Coming soon
- **Tasks Tab**: Coming soon
- **Profile Tab**: Coming soon

## Theme

- Primary Color: Amber (electrical theme)
- Secondary Color: Blue
- Using Material 3 design

## Next Steps

- Connect to backend API
- Implement projects list
- Implement tasks management
- Add user authentication
- Create profile screen
- Add notifications

## Running Tests

```bash
flutter test
```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Notes

- Currently uses mock data in the UI
- Backend API endpoints available at `http://localhost:8000/api`
- Lightning logo attribution: FreeIconsPNG
