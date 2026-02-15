# ElectricSync - Quick Start Guide

## What's Been Built

Your ElectricSync app now has:

1. **Flutter Frontend** with:
   - Animated splash screen with lightning logo
   - Home screen with bottom navigation
   - 4 navigation tabs (Home, Projects, Tasks, Profile)
   - Material 3 design with amber/electrical theme

2. **Python Backend** with:
   - FastAPI RESTful API
   - Mock data for users, projects, and tasks
   - Ready-to-use endpoints

## Next Steps to Run the App

### 1. Install Flutter (if not already installed)

Visit: https://flutter.dev/docs/get-started/install/macos

Or use Homebrew:
```bash
brew install --cask flutter
```

Verify installation:
```bash
flutter doctor
```

### 2. Run the Flutter App

```bash
cd ~/repos/ElectricSync/frontend
flutter pub get
flutter run
```

Choose your target device (iOS Simulator, Android Emulator, or Chrome).

### 3. Run the Backend (Optional)

In a separate terminal:
```bash
cd ~/repos/ElectricSync/backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

Backend will run at: http://localhost:8000
API Docs at: http://localhost:8000/docs

## What You'll See

1. **Splash Screen** - 3 seconds with lightning logo animation
2. **Home Screen** with:
   - Welcome card
   - Quick stats (Active Projects: 3, Pending Tasks: 7)
   - Recent activity feed
   - Bottom navigation bar

## Current Features

- ✅ Splash screen with fade animation
- ✅ Home dashboard with stats
- ✅ Bottom navigation (4 tabs)
- ✅ Mock data in UI
- ⏳ Projects tab (placeholder)
- ⏳ Tasks tab (placeholder)
- ⏳ Profile tab (placeholder)

## File Structure

```
ElectricSync/
├── frontend/
│   ├── lib/
│   │   ├── main.dart              # App entry point
│   │   └── screens/
│   │       ├── splash_screen.dart # Splash screen
│   │       └── home_screen.dart   # Home + navigation
│   ├── assets/images/
│   │   └── lightning_logo.png     # App logo
│   └── pubspec.yaml               # Dependencies
│
└── backend/
    ├── main.py                    # API server
    ├── api/                       # Endpoints
    ├── models/                    # Data models
    └── mock_data/                 # Sample data
```

## Troubleshooting

**Flutter not found?**
- Make sure Flutter is in your PATH
- Run `flutter doctor` to check setup

**App won't run?**
- Run `flutter pub get` first
- Make sure you have a device/emulator running
- Try `flutter devices` to see available devices

## What's Next?

Now you can start building:
1. Projects list screen
2. Tasks management screen
3. User profile screen
4. Connect to backend API
5. Add authentication

Happy coding!
