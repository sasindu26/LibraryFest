# Firebase Storage Setup for Profile Pictures

## Problem
Profile picture upload is buffering forever and not saving.

## Solution

### Step 1: Enable Firebase Storage

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **library-management-c5a54**
3. Click on **Storage** in the left sidebar (Build section)
4. Click **Get Started**
5. In the security rules dialog:
   - Select **Start in test mode** (for development)
   - Click **Next**
   - Select a Cloud Storage location (choose closest to your users)
   - Click **Done**

### Step 2: Configure Storage Rules (Optional - for production)

Once enabled, update your Storage Rules for better security:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images - only authenticated users can upload their own
    match /profile_images/{userId} {
      allow read: if true;  // Anyone can view profile pictures
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Book covers - only admins can upload
    match /book_covers/{bookId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   request.auth.token.email.matches('.*admin.*');
    }
  }
}
```

### Step 3: Test Profile Picture Upload

1. Run the app
2. Go to **Profile** tab
3. Tap on the profile picture (camera icon)
4. Choose "Gallery" or "Camera"
5. Select an image
6. Wait for upload (should show green success message)

## Troubleshooting

### Upload still buffering?
- Check internet connection
- Make sure Firebase Storage is enabled in console
- Check if Storage rules allow writes
- Look for errors in debug console

### Permission denied?
- Update Storage rules to allow authenticated users
- Make sure user is logged in

### Image too large?
- Images are automatically resized to 512x512 pixels
- Quality is compressed to 75%
- If still issues, check your internet speed

## What's Being Uploaded

- **Location**: `gs://library-management-c5a54.appspot.com/profile_images/{userId}.jpg`
- **Format**: JPEG
- **Size**: Max 512x512 pixels
- **Quality**: 75%
- **Naming**: `{userId}.jpg` (e.g., `5wMGY8bIJXbkmLmdJmoEptTetjB3.jpg`)

## Verification

After upload, you can verify in Firebase Console:
1. Go to **Storage** → **Files**
2. Navigate to `profile_images/` folder
3. You should see your uploaded image with filename = your user ID
