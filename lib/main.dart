import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'features/home/home_screen.dart';
import 'core/services/auth_service.dart'; 
import 'features/auth/login_screen.dart';

class EduverseApp extends StatelessWidget {
  const EduverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eduverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // This "AuthWrapper" checks if you are logged in
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // If we are logged in, go to Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Otherwise, show Login
        return const LoginScreen();
      },
    );
  }
}