# Firebase Setup Instructions

This library management app requires Firebase for authentication and data storage. Follow these steps to set up Firebase:

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" sign-in provider

4. Enable Firestore Database:
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (or production mode with proper security rules)
   - Choose a location for your database

## 2. Add Firebase to Android

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click the Android icon
3. Register your app with package name: `com.example.library_app`
4. Download the `google-services.json` file
5. Place it in: `android/app/google-services.json`

## 3. Add Firebase to iOS (if developing for iOS)

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click the iOS icon
3. Register your app with bundle ID: `com.example.libraryApp`
4. Download the `GoogleService-Info.plist` file
5. Place it in: `ios/Runner/GoogleService-Info.plist`

## 3.5. Add Firebase to Web

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click the Web icon (</>) 
3. Register your app with a nickname (e.g., "Library Management Web")
4. Copy the Firebase configuration object that looks like this:
   ```javascript
   const firebaseConfig = {
     apiKey: "YOUR_API_KEY",
     authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
     projectId: "YOUR_PROJECT_ID",
     storageBucket: "YOUR_PROJECT_ID.appspot.com",
     messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
     appId: "YOUR_APP_ID"
   };
   ```
5. Update `lib/main.dart` and replace the placeholder values in the `FirebaseOptions` with your actual web config values:
   - Replace `YOUR_API_KEY` with your `apiKey`
   - Replace `YOUR_APP_ID` with your `appId`
   - Replace `YOUR_MESSAGING_SENDER_ID` with your `messagingSenderId`
   - Replace `YOUR_PROJECT_ID` with your `projectId`

## 4. Install Flutter Dependencies

Run the following command in the project root:

```bash
flutter pub get
```

## 5. Firestore Security Rules

Update your Firestore security rules in Firebase Console:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Books collection - readable by all, writable by admins only
    match /books/{bookId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Borrowed books collection
    match /borrowedBooks/{borrowId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 6. Create User Collection (Optional)

To enable admin functionality, create a users collection in Firestore and set the role field:

1. Go to Firestore Database in Firebase Console
2. Create a collection named `users`
3. Create a document with the user's UID
4. Add a field: `role: "admin"` (for admin users) or `role: "user"` (for regular users)

Alternatively, you can modify the admin check in `lib/screens/home_screen.dart` and `lib/providers/book_provider.dart` to check user email or another criteria.

## 7. Run the App

### Run on Linux Desktop:
```bash
flutter run -d linux
```

### Run on Web (Chrome):
```bash
flutter run -d chrome
```

### Run on Android/iOS:
```bash
flutter run
```

## Platform-Specific Notes

### Desktop (Linux/Windows/macOS):
- Desktop platforms can use the same Firebase configuration as mobile
- You may need to configure Firebase for desktop platforms separately in Firebase Console
- For Linux/Windows, Firebase initialization will use default options if no config files are present

### Web:
- Make sure to update the Firebase config in `lib/main.dart` with your web app credentials
- Web builds require proper CORS configuration in Firebase
- Test your web app in Chrome first, then other browsers

## Note

- Make sure you have Flutter SDK installed
- Make sure you have Android Studio (for Android) or Xcode (for iOS) set up
- For Linux desktop, you may need additional dependencies (see Flutter Linux setup docs)
- The app requires an internet connection to work with Firebase

