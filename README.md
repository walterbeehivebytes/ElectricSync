# ElectricSync

A mobile application for electricians, journeymen, and foremen to manage their work efficiently.

## Project Structure

```
ElectricSync/
├── frontend/          # Flutter mobile application
├── backend/           # Python backend API
│   ├── api/          # API endpoints
│   ├── models/       # Data models
│   ├── services/     # Business logic
│   └── mock_data/    # Mock data for development
└── docs/             # Documentation
```

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Python (FastAPI/Flask)
- **Database**: TBD (Currently using mock data)

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Python (3.9+)
- Git

### Frontend Setup

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
3. Initialize Flutter project:
   ```bash
   flutter create .
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the development server:
   ```bash
   python main.py
   ```

## Features (Planned)

- User management (Electricians, Journeymen, Foremen)
- Project tracking
- Task assignment
- Time tracking
- Material inventory
- Safety checklists
- Reports and analytics

## Development Status

Currently in initial setup phase. Using mock data for frontend development until database integration is complete.

## License

TBD
