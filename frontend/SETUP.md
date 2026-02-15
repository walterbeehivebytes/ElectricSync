# Frontend Setup Instructions

Since Flutter is not currently installed on your system, follow these steps to set up the frontend:

## Install Flutter

1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/macos
2. Extract the downloaded file
3. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
4. Run `flutter doctor` to verify installation

## Initialize the Flutter Project

Once Flutter is installed, run this command from the `frontend` directory:

```bash
cd ~/repos/ElectricSync/frontend
flutter create --org com.beehivebytes.electricsync --project-name electric_sync .
```

## Recommended VS Code Extensions

- Flutter
- Dart
- Flutter Widget Snippets

## Next Steps

After initialization, you can:
1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app on an emulator/device
3. Start building your UI components for electricians, journeymen, and foremen

## Mock Data

The backend will provide mock data endpoints until the database is integrated. Check the `backend/mock_data` directory for sample data structures.
