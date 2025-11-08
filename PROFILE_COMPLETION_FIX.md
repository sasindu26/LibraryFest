# Profile Completion System - Admin Fix & Navigation Fix (FINAL)

## Issues Fixed

### 1. Admin Profile Requirements ✅
**Problem**: Admins (employees) don't have university index numbers, but the system was requiring it for all users.

**Solution**: 
- Modified profile completion check to differentiate between admin and regular users
- **For Admins** (email contains 'admin'):
  - Only requires: Phone Number + Address
  - University Index Number is **optional**
- **For Regular Users**:
  - Requires: Phone Number + Address + University Index Number

### 2. Black Screen After Profile Completion ✅ **[FINAL FIX]**
**Problem**: After completing profile details and clicking Save, the screen turned black and nothing worked.

**Root Cause**: The FutureBuilder in AuthWrapper wasn't rebuilding after profile data was saved to Firestore.

**Solution**:
- Changed ProfileCompletionScreen from StatelessWidget to StatefulWidget
- After profile save returns `true`, explicitly navigate to HomeScreen using `Navigator.pushReplacement`
- This bypasses the FutureBuilder rebuild issue and directly loads the home screen
- Admin → Admin Home Screen, Regular User → User Home Screen

## Files Modified

### 1. `/lib/auth_wrapper.dart`

#### Profile Completion Check (Lines 11-32)
```dart
Future<bool> _checkProfileComplete(User user) async {
  // ... existing code ...
  
  // Check if user is admin (email contains 'admin')
  final isAdmin = user.email?.toLowerCase().contains('admin') ?? false;
  
  // For admins: only phone and address are required
  // For regular users: phone, address, and studentIndex are required
  if (isAdmin) {
    return phone.isNotEmpty && address.isNotEmpty;
  } else {
    return phone.isNotEmpty && address.isNotEmpty && studentIndex.isNotEmpty;
  }
}
```

#### ProfileCompletionScreen - Changed to StatefulWidget (Lines 89-277)
```dart
class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email?.toLowerCase().contains('admin') ?? false;
    
    // ... UI code ...
    
    // Continue Button onPressed:
    onPressed: () async {
      // Navigate to edit profile and wait for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        ),
      );
      
      // If profile was saved (result == true), navigate to home
      if (result == true && mounted) {
        // Use pushReplacement to replace ProfileCompletionScreen with HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    },
  }
}
```

#### Dynamic Messages Based on Role
- **Admin message**: "To get started, please provide your contact information."
- **Admin info card**: "Contact details are required for administrative access."
- **User message**: "To get started, please provide your contact information and university index number."
- **User info card**: "These details are required for library services. University index cannot be changed later."

### 2. `/lib/screens/edit_profile_screen.dart`

#### Admin Detection in Build Method (Lines 160-163)
```dart
@override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final isAdmin = user?.email?.toLowerCase().contains('admin') ?? false;
  // ... rest of build method
}
```

#### Optional University Index for Admins (Line 552)
```dart
decoration: InputDecoration(
  labelText: isAdmin 
      ? 'University Index Number (Optional)' 
      : 'University Index Number',
  // ...
),
```

#### Conditional Validation (Lines 598-615)
```dart
validator: (value) {
  // For admins, university index is optional
  if (isAdmin) {
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Please enter a valid index number';
    }
    return null; // Optional for admins
  }
  
  // For regular users, university index is required
  if (value == null || value.isEmpty) {
    return 'Please enter your university index number';
  }
  if (value.length < 5) {
    return 'Please enter a valid index number';
  }
  return null;
}
```

#### Save Logic with Admin Check (Lines 50-122)
```dart
// Check if user is admin
final isAdmin = user.email?.toLowerCase().contains('admin') ?? false;

// Skip uniqueness check for admins
if (!isAdmin && studentIndex.isNotEmpty && !_hasExistingIndex) {
  // Check if student index is unique
  final existingIndex = await FirebaseFirestore.instance
      .collection('users')
      .where('studentIndex', isEqualTo: studentIndex)
      .limit(1)
      .get();
  
  if (existingIndex.docs.isNotEmpty) {
    // Show error - index already exists
    return;
  }
}

// Store in Firestore
if (!_hasExistingIndex) {
  if (isAdmin) {
    // Admins: set empty string if not provided
    updateData['studentIndex'] = studentIndex.isNotEmpty ? studentIndex : '';
  } else if (studentIndex.isNotEmpty) {
    // Regular users: must provide student index
    updateData['studentIndex'] = studentIndex;
  }
}

// Save to Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(updateData, SetOptions(merge: true));

// Return true to indicate successful save
Navigator.pop(context, true);
```

#### Dynamic Info Message (Lines 637-645)
```dart
Text(
  _hasExistingIndex 
      ? 'Your university index number cannot be changed. Contact library officers if you need assistance.'
      : isAdmin
          ? 'As an admin, the university index is optional. If you provide one, it can only be set once.'
          : 'Your index number can only be set once and cannot be changed. Each index number can only have one account.',
  // ...
)
```

## User Flow

### For New Admin (email contains 'admin'):
1. Sign up or login with Gmail
2. See ProfileCompletionScreen: "Complete Your Profile"
3. Message: "To get started, please provide your contact information."
4. Info: "Contact details are required for administrative access."
5. Click "Continue"
6. Fill in:
   - Display Name ✓
   - Phone Number ✓
   - Address ✓
   - University Index Number (Optional) - can skip
7. Click "Save Profile"
8. ✅ **Automatically redirected to Admin Home Screen**

### For New Regular User:
1. Sign up or login with Gmail
2. See ProfileCompletionScreen: "Complete Your Profile"
3. Message: "To get started, please provide your contact information and university index number."
4. Info: "These details are required for library services. University index cannot be changed later."
5. Click "Continue"
6. Fill in:
   - Display Name ✓
   - Phone Number ✓
   - Address ✓
   - University Index Number ✓ (Required - shows error if empty)
7. Click "Save Profile"
8. ✅ **Automatically redirected to User Home Screen**

### For Existing Users:
- No changes! They go directly to their respective home screens
- Profile completion check only affects NEW users

## Technical Implementation Details

### Navigation Flow (FINAL FIX)
**Old broken flow:**
```
ProfileCompletionScreen (pushReplacement)
  → EditProfileScreen
  → Navigator.pop() after save
  → Returns to ProfileCompletionScreen (but it's been replaced)
  → BLACK SCREEN (no screen in navigation stack)
```

**New working flow:**
```
ProfileCompletionScreen (StatefulWidget)
  → Navigator.push → EditProfileScreen
  → Navigator.pop(true) after save
  → Returns to ProfileCompletionScreen with result=true
  → Navigator.pushReplacement → HomeScreen
  → ✅ WORKING! User sees their home screen
```

### Why This Works
1. **StatefulWidget**: Allows ProfileCompletionScreen to react to the return value
2. **Navigator.push**: Keeps ProfileCompletionScreen in the stack to receive the result
3. **Explicit Navigation**: After receiving `true`, manually navigate to HomeScreen
4. **No Rebuild Dependency**: Doesn't rely on FutureBuilder rebuild which was failing

### How Admin Detection Works
- **Simple check**: `user.email?.toLowerCase().contains('admin')`
- Examples:
  - `admin@library.com` → Admin ✓
  - `library.admin@gmail.com` → Admin ✓
  - `administrator@uni.ac.lk` → Admin ✓
  - `sasinilupuladmin@library.com` → Admin ✓
  - `student@gmail.com` → Regular User
  - `john.doe@university.edu` → Regular User

## Testing Steps

### ✅ Test Admin Profile Completion:
1. Create/use admin account (e.g., `sasinilupuladmin@library.com`)
2. Logout if already logged in
3. Login again
4. Verify ProfileCompletionScreen appears
5. Verify message: "provide your contact information" (no mention of index)
6. Click Continue
7. Fill Phone and Address (leave University Index empty)
8. Click Save Profile
9. **Verify: Immediately redirected to Admin Home Screen**
10. **Verify: No black screen**

### ✅ Test Regular User Profile Completion:
1. Create new account with regular email (e.g., `newstudent@gmail.com`)
2. Verify ProfileCompletionScreen appears
3. Verify message mentions "university index number"
4. Click Continue
5. Try to save WITHOUT university index → should show error
6. Fill all fields INCLUDING university index
7. Click Save Profile
8. **Verify: Immediately redirected to User Home Screen**
9. **Verify: No black screen**

### ✅ Test Gmail Sign-in:
1. Sign in with NEW Gmail account (contains 'admin')
2. Complete profile → verify redirects to Admin Home
3. Sign in with NEW Gmail account (regular)
4. Complete profile → verify redirects to User Home

## Backward Compatibility
- ✅ Existing users with complete profiles: Direct to home screen
- ✅ Existing admins without index: Works fine  
- ✅ Existing users with index: Works fine
- ✅ All changes only affect NEW user signup/login flow

## Summary of All Changes
✅ **Admin Requirements**: Admins only need phone + address (no university index)
✅ **User Requirements**: Regular users need phone + address + university index
✅ **Dynamic UI**: Messages and validation change based on user role
✅ **Navigation Fix**: Profile completion now properly redirects to home screen
✅ **No Black Screen**: Fixed by using StatefulWidget and explicit navigation
✅ **Role-Based Routing**: Admin → Admin Screen, User → User Screen
✅ **Backward Compatible**: Existing users unaffected

## Files Modified

### 1. `/lib/auth_wrapper.dart`

#### Profile Completion Check
```dart
Future<bool> _checkProfileComplete(User user) async {
  // ... existing code ...
  
  // Check if user is admin (email contains 'admin')
  final isAdmin = user.email?.toLowerCase().contains('admin') ?? false;
  
  // For admins: only phone and address are required
  // For regular users: phone, address, and studentIndex are required
  if (isAdmin) {
    return phone.isNotEmpty && address.isNotEmpty;
  } else {
    return phone.isNotEmpty && address.isNotEmpty && studentIndex.isNotEmpty;
  }
}
```

#### ProfileCompletionScreen Navigation
```dart
// Changed from:
Navigator.pushReplacement(context, ...)

// To:
final result = await Navigator.push(context, ...)
// This allows AuthWrapper to rebuild and check profile again
```

#### Dynamic Messages
- **Admin message**: "To get started, please provide your contact information."
- **User message**: "To get started, please provide your contact information and university index number."

### 2. `/lib/screens/edit_profile_screen.dart`

#### Admin Detection
```dart
@override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final isAdmin = user?.email?.toLowerCase().contains('admin') ?? false;
  // ... rest of build method
}
```

#### Optional University Index for Admins
```dart
decoration: InputDecoration(
  labelText: isAdmin 
      ? 'University Index Number (Optional)' 
      : 'University Index Number',
  // ...
),
```

#### Conditional Validation
```dart
validator: (value) {
  // For admins, university index is optional
  if (isAdmin) {
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Please enter a valid index number';
    }
    return null; // Optional for admins
  }
  
  // For regular users, university index is required
  if (value == null || value.isEmpty) {
    return 'Please enter your university index number';
  }
  if (value.length < 5) {
    return 'Please enter a valid index number';
  }
  return null;
}
```

#### Save Logic
```dart
// Skip uniqueness check for admins
if (!isAdmin && studentIndex.isNotEmpty && !_hasExistingIndex) {
  // Check if student index is unique
}

// Store in Firestore
if (!_hasExistingIndex) {
  if (isAdmin) {
    // Admins: set empty string if not provided
    updateData['studentIndex'] = studentIndex.isNotEmpty ? studentIndex : '';
  } else if (studentIndex.isNotEmpty) {
    // Regular users: must provide student index
    updateData['studentIndex'] = studentIndex;
  }
}

// Return true to indicate successful save
Navigator.pop(context, true);
```

## User Flow

### For New Admin (email contains 'admin'):
1. Sign up or login with Gmail
2. See ProfileCompletionScreen: "Complete Your Profile"
3. Message: "To get started, please provide your contact information."
4. Click "Continue"
5. Fill in:
   - Display Name ✓
   - Phone Number ✓
   - Address ✓
   - University Index Number (Optional) - can skip
6. Click "Save Profile"
7. Success! → Automatically redirected to Admin Screen

### For New Regular User:
1. Sign up or login with Gmail
2. See ProfileCompletionScreen: "Complete Your Profile"
3. Message: "To get started, please provide your contact information and university index number."
4. Click "Continue"
5. Fill in:
   - Display Name ✓
   - Phone Number ✓
   - Address ✓
   - University Index Number ✓ (Required)
6. Click "Save Profile"
7. Success! → Automatically redirected to User Home Screen

### For Existing Users:
- No changes! They go directly to their respective home screens
- Profile completion check only affects NEW users

## Testing Steps

### Test Admin Profile Completion:
1. Create new account with admin email (e.g., `admin@library.com`)
2. Verify ProfileCompletionScreen appears
3. Verify message mentions only "contact information" (not index)
4. Complete profile WITHOUT university index
5. Verify Save works
6. Verify redirected to Admin Screen (not black screen)

### Test Regular User Profile Completion:
1. Create new account with regular email (e.g., `student@gmail.com`)
2. Verify ProfileCompletionScreen appears
3. Verify message mentions "university index number"
4. Try to save WITHOUT university index → should show error
5. Complete profile WITH university index
6. Verify Save works
7. Verify redirected to User Home Screen (not black screen)

### Test Gmail Sign-in:
1. Sign in with NEW Gmail account (contains 'admin')
2. Verify profile completion flow works
3. Sign in with NEW Gmail account (doesn't contain 'admin')
4. Verify profile completion flow works

## Technical Notes

### How Admin Detection Works
- **Simple check**: `user.email?.toLowerCase().contains('admin')`
- Examples:
  - `admin@library.com` → Admin ✓
  - `library.admin@gmail.com` → Admin ✓
  - `administrator@uni.ac.lk` → Admin ✓
  - `student@gmail.com` → Regular User
  - `john.doe@university.edu` → Regular User

### Why Navigation Fix Works
1. **Old way** (causing black screen):
   ```dart
   Navigator.pushReplacement() // Replaces current screen
   Navigator.pop()             // Pops to nothing → black screen
   ```

2. **New way** (working):
   ```dart
   Navigator.push()            // Pushes EditProfile on top
   Navigator.pop(true)         // Returns to ProfileCompletionScreen
   // AuthWrapper rebuilds automatically
   // _checkProfileComplete() runs again
   // If complete → navigates to HomeScreen
   ```

### Backward Compatibility
- Existing users with profile already complete: **No changes**
- Existing admins without index: **Works fine**
- Existing users with index: **Works fine**
- All changes only affect NEW user signup/login flow

## Summary
✅ Admins no longer need university index number
✅ Profile completion properly redirects after save
✅ No more black screen issue
✅ Backward compatible with existing users
✅ Clear messages for admin vs regular users
✅ Works for both email signup and Gmail login
