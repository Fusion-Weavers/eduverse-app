import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // ✅ Add this import
import 'core/services/ui_translation_service.dart';
import 'core/services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UiTranslationService().init();

  // 🚀 FIX: Force Status Bar to be visible and transparent
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent background
    statusBarIconBrightness: Brightness.dark, // Dark icons by default
    systemNavigationBarColor: Colors.transparent, // Navigation bar transparent
  ));

  runApp(const EduverseApp());
}

class EduverseApp extends StatelessWidget {
  const EduverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    
    return AnimatedBuilder(
      animation: UiTranslationService(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Eduverse',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9575CD),
              primary: const Color(0xFF9575CD),
              secondary: const Color(0xFFD1C4E9),
              background: const Color(0xFFFBFBFF),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFFBFBFF),
            textTheme: baseTextTheme.apply(
              bodyColor: const Color(0xFF424242),
              displayColor: const Color(0xFF311B92),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              // Ensure icons are visible on white headers
              systemOverlayStyle: SystemUiOverlayStyle.dark, 
              titleTextStyle: TextStyle(color: Color(0xFF311B92), fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Color(0xFF311B92)),
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}