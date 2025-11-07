# Google Sign-In Setup Guide for LibraryFest

## ✅ What's Already Done

The following has been implemented in your app:
- ✅ Google Sign-In package installed
- ✅ Google Auth Service created
- ✅ Login screen updated with "Continue with Google" button
- ✅ Signup screen updated with "Continue with Google" button
- ✅ Beautiful UI with Google logo

## 🔧 Firebase Console Configuration Required

To enable Google Sign-In, you need to configure Firebase:

### Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **library-management-c5a54**
3. In the left sidebar, click **Authentication**
4. Click on the **Sign-in method** tab
5. Find **Google** in the list of providers
6. Click on **Google**
7. Click the **Enable** toggle
8. Enter your **Project support email** (your email)
9. Click **Save**

### Step 2: Get SHA-1 Certificate Fingerprint (For Android)

For Google Sign-In to work on Android, you need to add your SHA-1 certificate:

#### On Linux/Mac:
```bash
cd android
./gradlew signingReport
```

#### Look for the SHA-1 under "Variant: debug":
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### Step 3: Add SHA-1 to Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Click **Add fingerprint**
5. Paste your SHA-1 certificate
6. Click **Save**

### Step 4: Download Updated google-services.json

1. In the same **Project Settings** page
2. Under your Android app, click **Download google-services.json**
3. Replace the file at: `android/app/google-services.json`

### Step 5: Test the App

1. Reconnect your Redmi Note 8
2. Run the app:
   ```bash
   flutter run -d 14b2b4b3
   ```
3. On the Login or Signup screen, click **Continue with Google**
4. Select your Google account
5. You should be signed in!

## 🎉 Features Added

### Login Screen
- Email/Password login (existing)
- **NEW:** Google Sign-In button
- Modern UI with divider and "OR" text

### Signup Screen
- Email/Password signup (existing)
- **NEW:** Google Sign-In button
- Same modern UI design

### How It Works
1. User clicks "Continue with Google"
2. Google Sign-In popup appears
3. User selects/logs into their Google account
4. User is automatically signed into LibraryFest
5. Firebase creates the user account automatically
6. User is redirected to the app home screen

## 🔍 Troubleshooting

### "Sign in failed" error
- Make sure Google Sign-In is enabled in Firebase Console
- Verify SHA-1 certificate is added to Firebase
- Check that google-services.json is updated

### "PlatformException" error
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the app

### Google popup doesn't appear
- Check internet connection
- Ensure Firebase Authentication is properly configured
- Verify google-services.json is in the correct location

## 📝 Important Notes

- The app will work with email/password login even without Google Sign-In configured
- Google Sign-In requires internet connection
- Users can sign in with either email/password OR Google (both work independently)
- First-time Google users will be automatically registered

## 🚀 Quick Command to Run

```bash
# Get SHA-1 fingerprint
cd android && ./gradlew signingReport

# After Firebase setup, run app
flutter run
```
