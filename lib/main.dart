import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EduverseApp());
}

class EduverseApp extends StatelessWidget {
  const EduverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduverse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // This "Wrapper" decides which screen to show first
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listens to the User Login State
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 1. Loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. User is Logged In -> Show Home (Subjects)
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 3. User is Logged Out -> Show Login/Signup
        return const LoginScreen();
      },
    );
  }
}