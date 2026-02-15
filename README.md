# TravelSphere 🌍

A modern travel planning application built with Flutter & Firebase.

## 🚀 Getting Started for the Team

### 1. Prerequisites
- **Flutter SDK:** latest stable version (`flutter doctor` to check)
- **Java JDK:** Ensure `JAVA_HOME` is set (needed for Android build).
- **Android Studio / VS Code** with Flutter extensions.

### 2. Clone the Repository
```bash
git clone <repository_url>
cd travelsphere
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. 🔑 Firebase Setup (CRITICAL)
This project uses Firebase Authentication (Google Sign-In).

1.  **`google-services.json`**:
    - This file is located at `android/app/google-services.json`.
    - If it's not in the repo (gitignored), ask the admin (Akshay) for it.

2.  **Google Sign-In (SHA-1 Keys)**:
    - Google Sign-In **WILL NOT WORK** for you in debug mode unless your computer's `SHA-1` key is added to the Firebase Console.
    - **How to get your SHA-1:**
        - Open terminal in the project folder.
        - Run: `cd android`
        - Run: `./gradlew signingReport` (Mac/Linux) or `gradlew signingReport` (Windows).
        - Look for `Task :app:signingReport` -> `Variant: debug` -> `SHA1`.
    - **Send this SHA-1 key to Akshay** so he can add it to the Firebase Console.

### 5. Run the App
```bash
flutter run
```

## 📂 Project Structure
- `lib/app/`: Routes, Theme, Constants.
- `lib/screens/`: UI Screens (Auth, Dashboard, etc.).
- `lib/services/`: Logic (AuthService, etc.).
- `lib/widgets/`: Reusable components.

## ✨ Features Implemented
- [x] Splash Screen
- [x] Login (Email & Google)
- [x] Signup
- [x] Forgot Password
- [x] User Dashboard
