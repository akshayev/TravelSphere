# 🚀 TravelSphere Developer Setup Guide

This guide is for new team members who want to run the TravelSphere app locally.

## ✅ Prerequisites

1.  **Flutter SDK:** Make sure you have the latest stable version installed.
    - Run `flutter doctor` to check.
    - If not installed, download from [flutter.dev](https://flutter.dev/docs/get-started/install).
2.  **Git:** Installed and configured.
3.  **IDE:** VS Code or Android Studio with Flutter/Dart extensions.

---

## 🛠️ Step-by-Step Setup

### 1. Clone the Repository
Open your terminal and run:
```bash
git clone https://github.com/akshayev/TravelSphere.git
cd travelsphere
```

### 2. Install Dependencies
Get all the required packages:
```bash
flutter pub get
```

### 3. Setup Firebase (Crucial Step!) 🔥
Since we use Google Sign-In, you need to configure Firebase correctly.

#### A. Add `google-services.json`
- Ask **Akshay** for the `google-services.json` file.
- Place it in **`android/app/`**.
- **Important:** Do NOT change the filename.

#### B. Register Your SHA-1 Key (For Google Sign-In)
Google Sign-In will **FAIL** with an error (Exception: 10) if your computer's SHA-1 key is not added to the Firebase Console.

1.  Open your terminal in the project folder.
2.  Navigate to the android folder:
    ```bash
    cd android
    ```
3.  Run the signing report:
    - **Windows:** `gradlew signingReport`
    - **Mac/Linux:** `./gradlew signingReport`
4.  Find the `Task :app:signingReport` output. Look for the **`debug`** variant and copy the **`SHA1`** fingerprint (e.g., `5E:8F:16:06:2E:A3:CD:2C:4A:0D:54:78:76:BA:A6:F3:8C:AB:CD:EF`).
5.  **Send this SHA-1 key to Akshay**.
6.  Wait for confirmation that it has been added to the Firebase Console.

---

## ▶️ Running the App

Once setup is complete:

1.  Connect your Android device or start an emulator.
2.  Run the app:
    ```bash
    flutter run
    ```

## 🐛 Common Issues

*   **"Google Sign In Failed (Status{statusCode=DEVELOPER_ERROR...})":**
    - This usually means your SHA-1 key is missing or incorrect. Double-check step 3B.
*   **"google-services.json is missing":**
    - Ensure you placed the file in `android/app/`.

HAPPY CODING! 🚀
