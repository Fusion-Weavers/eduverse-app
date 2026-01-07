import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to check if user is logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // LOGIN
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // SIGN UP (Matches your Firestore 'users' schema)
  Future<void> signUp({
    required String email, 
    required String password,
    required String role,      // e.g., 'Student'
    required String language,  // e.g., 'English'
  }) async {
    // 1. Create Auth User
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    // 2. Save to Firestore
    await _db.collection('users').doc(result.user!.uid).set({
      'email': email,
      'role': role,
      'preferredLanguage': language, // Matches your DB field exactly
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}