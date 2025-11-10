# BookSwap

**One-liner:** BookSwap — a Flutter + Firebase mobile app for students to list, browse and swap textbooks with real-time sync.

---

## Project Overview

BookSwap is a mobile marketplace built with **Flutter** and **Firebase**. Students can sign up (email/password), verify email addresses, create and manage book listings (CRUD), initiate swap offers with real-time status updates, and optionally chat after swap initiation.

This repository contains the Flutter app code, architecture notes, and instructions to run locally.

---

## Features 

- Firebase Authentication (email/password) with *email verification*
- Book listings (Create, Read, Update, Delete) with cover images (Firebase Storage)
- Swap offers with statuses (Pending / Accepted / Rejected) stored in Firestore
- Real-time UI updates using Provider (or chosen state management)
- Bottom navigation: Browse Listings / My Listings / Chats / Settings
- Settings with notification toggle and profile view
- (Bonus) Chat between two users after a swap

---

## Getting Started: Clone and Run Locally

Follow these steps to run BookSwap on your machine:

### 1. Clone the repository
```bash
git clone https://github.com/your-username/bookswap.git
cd bookswap

### 2. Install dependencies
flutter pub get

### 3. Set up Firebase

Go to Firebase Console
 and create a new project.

Add an Android app and/or iOS app to the Firebase project.

Download the Firebase config files:

Android: google-services.json → place in android/app/

iOS: GoogleService-Info.plist → place in ios/Runner/

Enable Email/Password Authentication in Firebase Authentication.

Create a Firestore database (choose test mode or set up rules as needed).

(Optional) Enable Firebase Storage for book images.

4. Run the app
flutter run


Make sure you have a simulator/emulator or physical device connected.

Notes

This app uses Flutter 3.x+ and Dart 3.x+.

Ensure your Flutter SDK is properly installed and configured: flutter doctor.

For production builds, set up Firebase rules properly to secure user data.