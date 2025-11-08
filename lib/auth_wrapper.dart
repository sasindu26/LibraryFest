import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/edit_profile_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastUserUid;
  bool? _lastProfileComplete; // Cache the profile status

  Future<bool> _checkProfileComplete(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) {
        return false;
      }
      
      final data = doc.data();
      final phone = data?['phone'] ?? '';
      final address = data?['address'] ?? '';
      final studentIndex = data?['studentIndex'] ?? '';
      
      final isAdmin = user.email?.toLowerCase().contains('admin') ?? false;
      
      if (isAdmin) {
        return phone.isNotEmpty && address.isNotEmpty;
      } else {
        return phone.isNotEmpty && address.isNotEmpty && studentIndex.isNotEmpty;
      }
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        // User logged out - reset all state
        if (user == null) {
          _lastUserUid = null;
          _lastProfileComplete = null;
          return const LoginScreen();
        }

        // Check if this is a different user or first login
        final isDifferentUser = _lastUserUid != user.uid;
        
        if (isDifferentUser) {
          // Update the last user UID and reset profile status
          _lastUserUid = user.uid;
          _lastProfileComplete = null; // Reset for new user
          print('New/different user logged in: ${user.uid}');
          
          // Build fresh widget for this user
          return FutureBuilder<bool>(
            key: ValueKey('profile_check_${user.uid}'), // Unique key per user
            future: _checkProfileComplete(user),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final isProfileComplete = profileSnapshot.data ?? false;
              _lastProfileComplete = isProfileComplete; // Cache the result
              
              if (!isProfileComplete) {
                return const ProfileCompletionScreen();
              }
              
              return const HomeScreen();
            },
          );
        }
        
        // Same user - use cached profile status to show the correct screen
        // This prevents infinite rebuilds from token refreshes while maintaining proper UI
        print('Same user, using cached status: ${user.uid}, complete: $_lastProfileComplete');
        
        if (_lastProfileComplete == true) {
          return const HomeScreen();
        } else if (_lastProfileComplete == false) {
          return const ProfileCompletionScreen();
        } else {
          // Profile status unknown - shouldn't happen, but check just in case
          return FutureBuilder<bool>(
            key: ValueKey('profile_check_fallback_${user.uid}'),
            future: _checkProfileComplete(user),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final isProfileComplete = profileSnapshot.data ?? false;
              _lastProfileComplete = isProfileComplete; // Cache the result
              
              if (!isProfileComplete) {
                return const ProfileCompletionScreen();
              }
              
              return const HomeScreen();
            },
          );
        }
      },
    );
  }
}

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
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.36,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description - Dynamic based on user role
                Text(
                  isAdmin
                      ? 'To get started, please provide your contact information.'
                      : 'To get started, please provide your contact information and university index number.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFF007AFF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isAdmin
                              ? 'Contact details are required for administrative access.'
                              : 'These details are required for library services. University index cannot be changed later.',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF007AFF),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Continue Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout option
                TextButton(
                  onPressed: () async {
                    try {
                      // Sign out from Google Sign-In (clears cache)
                      await GoogleSignIn().signOut();
                      
                      // Sign out from Firebase (works for all auth methods)
                      await FirebaseAuth.instance.signOut();
                      
                      print('Logout successful');
                    } catch (e) {
                      print('Error logging out: $e');
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
