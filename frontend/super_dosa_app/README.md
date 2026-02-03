# SuperDosaSearch Frontend

A Flutter app for planning trips with optimal cost vs speed preferences.

## Features
- Search for travel routes between cities
- Balance cost vs speed with a slider preference
- Avoid flights option
- Multiple route options (cheapest, fastest, best balance)

## Project Structure
```
lib/
  ├── main.dart              # App entry point
  ├── screens/               # Screen widgets
  │   ├── home.dart         # Search screen
  │   ├── results.dart      # Results display
  │   └── settings.dart     # User preferences
  ├── widgets/              # Reusable widgets
  │   └── route_card.dart   # Route display card
  └── services/             # API services
      └── api_service.dart  # Backend API client
```

## Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- macOS/iOS/Android development setup

### Installation
```bash
cd frontend/super_dosa_app
flutter pub get
```

### Running
```bash
flutter run -d macos  # macOS
# or
flutter run -d ios    # iOS
# or
flutter run -d android # Android
```

## Building
```bash
flutter build macos
```

## Development
- Hot reload: Press `r` in the terminal while running
- Hot restart: Press `R` in the terminal while running

## Contributing
See ../docs/ for more information
