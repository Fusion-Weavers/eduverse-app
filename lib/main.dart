import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this package
import 'core/services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart'; // Ensure this points to your Tab controller

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EduverseApp());
}

class EduverseApp extends StatelessWidget {
  const EduverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 DEFINING THE CALM LAVENDER THEME
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduverse',
      theme: ThemeData(
        useMaterial3: true,
        // Soft Purple Palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9575CD), // Soft Deep Purple
          primary: const Color(0xFF9575CD),
          secondary: const Color(0xFFD1C4E9), // Light Lavender
          background: const Color(0xFFFBFBFF), // Ghost White
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
          titleTextStyle: TextStyle(color: Color(0xFF311B92), fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Color(0xFF311B92)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9575CD),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFF9575CD).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
      home: const AuthWrapper(),
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