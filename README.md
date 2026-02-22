# MindCare AI

A comprehensive mental health companion app built with Flutter and Node.js.

## Project Structure

- **frontend**: The Flutter application (root directory).
- **backend**: The Node.js server (`mental-health-backend` directory).

## Getting Started

### 1. Backend Setup

The backend handles authentication, AI chat, mood tracking, and data persistence using Supabase.

```bash
cd mental-health-backend
npm install
npm start
```
The server will run on `http://localhost:5000`.

### 2. Frontend Setup

Ensure the backend is running first.

```bash
# Return to root directory
flutter pub get
flutter run
```

### Connectivity Note

- **Android Emulator**: The app automatically uses `10.0.2.2:5000` to connect to your local backend.
- **iOS Simulator / Web**: Uses `localhost:5000`.
- **Physical Device**: You must update `lib/config/app_config.dart` with your computer's IP address.

## Features

- **Authentication**: Login, Signup, Profile Management.
- **AI Companion**: Chat with an AI assistant.
- **Mood Tracking**: Log daily moods and view history.
- **Journaling**: Secure personal journal.
- **Meditation**: Guided sessions (placeholder).

