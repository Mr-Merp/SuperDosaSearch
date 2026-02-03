# SuperDosaSearch

A full-stack trip planning application that helps users find optimal travel routes based on cost vs speed preferences.

## Overview
SuperDosaSearch combines a Flutter mobile/desktop app with a Flask backend API to provide intelligent trip planning. Users can balance their preference for cheaper vs faster routes, and the system recommends optimal travel paths.

## Project Structure
```
SuperDosaSearch/
│
├── frontend/
│   └── super_dosa_app/          # Flutter application
│       ├── lib/                 # Dart source code
│       ├── macos/               # macOS platform files
│       ├── assets/              # Images and icons
│       ├── pubspec.yaml         # Flutter dependencies
│       └── README.md            # Frontend docs
│
├── backend/
│   └── server/                  # Flask REST API
│       ├── main.py              # Entry point
│       ├── routes.py            # API endpoints
│       ├── models.py            # Data models
│       ├── services/            # External integrations
│       ├── requirements.txt     # Python dependencies
│       └── README.md            # Backend docs
│
├── docs/
│   ├── proposal.pdf             # Project proposal
│   ├── final_report.pdf         # Final report
│   └── screenshots/             # App screenshots
│
├── .gitignore
└── README.md                    # This file
```

## Features

### Frontend (Flutter)
- 🏠 **Home Screen**: Search for travel routes with origin, destination, and budget
- 📊 **Results Screen**: View multiple route options with costs and times
- ⚙️ **Settings**: Adjust cost vs speed preference with slider
- 🚫 **Filters**: Option to avoid flights

### Backend (Flask)
- 🔍 Route search and optimization
- 💰 Cost calculation
- ⏱️ Duration estimation
- 📍 Integration with flight and maps APIs
- 🎯 Smart ranking based on user preferences

## Getting Started

### Frontend Setup
```bash
cd frontend/super_dosa_app
flutter pub get
flutter run -d macos
```

### Backend Setup
```bash
cd backend/server
pip install -r requirements.txt
python main.py
```

## Technology Stack
- **Frontend**: Flutter, Dart
- **Backend**: Flask, Python
- **APIs**: Google Maps, Flight APIs (Skyscanner/Amadeus)
- **Platforms**: macOS, iOS, Android, Web

## Development Roadmap
- [ ] Integrate with real flight APIs
- [ ] Implement maps integration
- [ ] Add user authentication
- [ ] Create web version
- [ ] Implement machine learning for route optimization
- [ ] Add trip history and bookmarks

## Contributing
1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit changes (`git commit -m 'Add AmazingFeature'`)
3. Push to branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## License
MIT License - see LICENSE file for details

## Contact
For questions or suggestions, please reach out to the development team.

---
**Last Updated**: February 2026
