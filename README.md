# 📚 LibraryFest - Your Library Management System

<div align="center">
  
  ### Your Complete Library Management Solution
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
  ![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
  ![License](https://img.shields.io/badge/License-MIT-green.svg)
</div>

## 🌟 Features

### 📱 User Features
- **Dashboard** - Beautiful home screen with statistics and quick actions
- **Book Catalog** - Browse all available books in the library
- **My Books** - Track your borrowed books
- **Profile Management** - Personalized user profile with settings
- **Profile Pictures** - Upload and manage your profile picture
- **Multiple Authentication Methods**:
  - Email/Password sign-in
  - Google Sign-In (OAuth)
  
### 👨‍💼 Admin Features
- **Book Management** - Add, edit, and delete books
- **User Management** - View and manage library users
- **Borrowing Control** - Approve and track book borrowings

### 🎨 UI/UX Features
- Modern Material Design 3
- Gradient themes and beautiful cards
- Smooth animations and transitions
- Google Fonts (Poppins)
- Responsive layout
- Bottom navigation with 5 tabs

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/LibraryFest.git
   cd LibraryFest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication (Email/Password and Google)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - See setup guides: `GOOGLE_SIGNIN_SETUP.md` and `PROFILE_PICTURE_SETUP.md`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Key Dependencies

- `firebase_core` & `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `google_sign_in` - Google OAuth
- `image_picker` - Profile pictures
- `provider` - State management
- `google_fonts` - Typography

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── auth_wrapper.dart            # Auth flow
├── models/book.dart             # Data models
├── providers/book_provider.dart # State management
├── screens/                     # All UI screens
└── services/                    # Auth & upload services
```

## 🔑 Admin Access

Create an account with email containing "admin" (e.g., `admin@libraryfest.com`)

## 📱 Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 📄 License

This project is licensed under the MIT License

## 👨‍💻 Author

Created with ❤️ using Flutter

---

⭐ Star this repo if you find it useful!
