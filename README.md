# TravelSphere 🌍

A modern, full-stack travel planning application built with Flutter & Firebase. TravelSphere empowers users to discover curated travel packages, generate itineraries, and book premium experiences smoothly with an elegant, glassmorphism-inspired user interface.

## ✨ Key Features
*   **Authentication & Security**: Secure Email/Password and Google Sign-In powered by Firebase Authentication.
*   **Role-Based Access Control (RBAC)**: Secure separation between standard users and administrators. Admin accounts have exclusive access to a robust dashboard to manage content.
*   **Admin Dashboard**: Real-time management of travel packages with the capability to easily create new destinations, setting details like geolocation, duration, and pricing directly to Firestore.
*   **Interactive Maps**: Native map integration using `flutter_map` and OpenStreetMap to beautifully showcase geographical data (`GeoPoint`) for each travel package.
*   **Smart Trip Planning**: Generate and organize itineraries effectively.
*   **Booking System**: Intuitive "Book Now" flow that creates and records confirmed transactions on the database.
*   **Glassmorphic Design System**: Custom `GlassContainer` widgets leveraging backdrop filters for a premium frosted-glass aesthetic.
*   **Real-time Data Sync**: Built with reactive streams connecting the frontend directly to Cloud Firestore.

## 🛠️ Tech Stack & Technologies Used
### Core Development
*   **Flutter & Dart**: Cross-platform application framework for building high-performance natively compiled apps.
### Backend & Cloud Services
*   **Firebase Authentication**: Secure user identity management.
*   **Cloud Firestore**: NoSQL cloud database for real-time data syncing (Users, Packages, Bookings).
*   **Firebase Cloud Storage**: Robust object storage for high-quality images and user profile pictures.
### Key Flutter Packages
*   `flutter_map` & `latlong2`: Powerful mapping solution using OpenStreetMap tiles.
*   `google_sign_in`: Secure 1-tap OAuth integration.
*   `image_picker`: Native gallery & camera access for avatar uploads.
*   `cached_network_image`: Performant image loading and caching strategies.
*   `google_fonts`: Elegant typography styling out-of-the-box.
*   `intl`: Internationalization and date formatting.
### Testing & QA
*   `flutter_driver` & `flutter_test`: Configured for automated UI verification and Integration testing.

## 📂 Project Architecture
The project adheres to a clean, highly modular architecture to ensure scalability and maintainability.
```text
lib/
├── app/          # App-wide routing, thematic constants, and environment configurations.
├── models/       # Data models strictly typed for Firestore serialization (e.g., Package, Booking, User).
├── screens/      # Feature-based UI components categorized logically (Admin, Auth, User, Splash).
│   ├── admin/    # Admin Dashboard & Package Management Forms.
│   ├── auth/     # Login, Signup, Forgot Password screens.
│   └── user/     # End-user features: Explorer, Profile, Itinerary Planner, Package Details.
├── services/     # Core business logic isolating Firebase transactions from UI code.
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── itinerary_generator.dart
│   ├── travel_package_service.dart
│   └── user_service.dart
└── widgets/      # Reusable UI widgets like the signature `GlassContainer` and standardized cards.
```

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.10.7 <4.0.0`)
*   Android Studio / VS Code
*   Java JDK

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/akshayev/TravelSphere.git
    cd travelsphere
    ```

2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration (Important):**
    *   This project relies on Firebase integration. The `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) files are required.
    *   **Google Sign-In Note**: Your local SHA-1 fingerprint needs to be registered with the Firebase Console. You can generate it using `./gradlew signingReport` inside the `android` folder.

4.  **Run the application:**
    ```bash
    flutter run
    ```

## 👨‍💻 Developer
Developed with ❤️ by **Akshay EV**
*(A showcase of innovative mobile software development and architecture.)*

