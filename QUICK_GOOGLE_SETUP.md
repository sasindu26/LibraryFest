# Quick Firebase Google Sign-In Setup

## Your SHA-1 Certificate Fingerprint:
```
EB:67:E1:E3:C5:C2:42:3A:53:4F:43:83:4D:1E:6E:4A:1D:E7:29:D1
```

## Steps to Enable Google Sign-In:

### 1. Go to Firebase Console
https://console.firebase.google.com/project/library-management-c5a54

### 2. Enable Google Sign-In
1. Click **Authentication** in left sidebar
2. Click **Sign-in method** tab
3. Click on **Google**
4. Toggle **Enable**
5. Enter your support email
6. Click **Save**

### 3. Add SHA-1 Fingerprint
1. Click the **gear icon** (Settings) → **Project settings**
2. Scroll to "Your apps" section
3. Find your Android app: `com.sasindu.libraryfest`
4. Click **Add fingerprint**
5. Paste this SHA-1:
   ```
   EB:67:E1:E3:C5:C2:42:3A:53:4F:43:83:4D:1E:6E:4A:1D:E7:29:D1
   ```
6. Click **Save**

### 4. Download google-services.json (if needed)
1. Still in Project Settings
2. Under your Android app, click **google-services.json** download icon
3. Replace file at: `android/app/google-services.json`

### 5. Test It!
```bash
# Connect your phone and run
flutter run
```

Then try clicking "Continue with Google" on the login/signup screen!

---

## ✅ What's Already Done in Code:
- Google Sign-In package installed
- Login screen has Google button
- Signup screen has Google button
- Beautiful UI with Google logo
- Full authentication flow implemented

## 🎯 All you need to do is configure Firebase (steps above)!
