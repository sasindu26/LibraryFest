import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_wrapper.dart';
import 'providers/book_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    if (kIsWeb) {
      // Web Firebase initialization
      // IMPORTANT: Replace these placeholder values with your actual Firebase web config
      // Get these values from Firebase Console > Project Settings > Your apps > Web app
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'YOUR_API_KEY',
          appId: 'YOUR_APP_ID',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          projectId: 'YOUR_PROJECT_ID',
          authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
          storageBucket: 'YOUR_PROJECT_ID.appspot.com',
        ),
      );
    } else {
      // Mobile/Desktop Firebase initialization
      // For Android: Uses google-services.json
      // For iOS: Uses GoogleService-Info.plist
      // For Desktop: May need manual configuration
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Handle Firebase initialization errors
    debugPrint('Firebase initialization error: $e');
    // For development, you can still run the app, but Firebase features won't work
    // Make sure to configure Firebase properly before production use
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: MaterialApp(
        title: 'Library Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // iOS-inspired color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF), // iOS Blue
            brightness: Brightness.light,
            primary: const Color(0xFF007AFF), // iOS Blue
            secondary: const Color(0xFF5856D6), // iOS Purple
            tertiary: const Color(0xFFFF9500), // iOS Orange
            surface: const Color(0xFFF2F2F7), // iOS Light Gray
            background: const Color(0xFFFFFFFF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS background
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            // iOS uses SF Pro, Inter is closest Google Font
            displayLarge: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.37,
            ),
            displayMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.36,
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.35,
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.41,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.24,
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.37,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF007AFF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD1D1D6),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF007AFF),
              textStyle: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFD1D1D6),
            thickness: 0.5,
            space: 1,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
