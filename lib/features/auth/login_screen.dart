import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggle between Login and Signup
  String? _errorMessage;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        // 🔒 STRICT LOGIN: Only works if account exists & password is correct
        await _authService.signIn(email: email, password: password);
      } else {
        // 📝 SIGN UP: Creates a new account
        await _authService.signUp(email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        // 🔒 Security Update: Handle Firebase's generic 'invalid-credential' error
        // This covers "User Not Found" AND "Wrong Password" safely.
        if (e.code == 'user-not-found' || 
            e.code == 'wrong-password' || 
            e.code == 'invalid-credential' || 
            e.code == 'INVALID_LOGIN_CREDENTIALS') { 
          
          _errorMessage = "Invalid email or password.";
          
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = "This email is already registered.";
        } else if (e.code == 'weak-password') {
          _errorMessage = "Password is too weak (use 6+ chars).";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Please enter a valid email address.";
        } else {
          // If it's some other weird error, show the message from Firebase
          _errorMessage = e.message ?? "An error occurred. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? "Login" : "Create Account")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Icon
              const Icon(Icons.school, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              
              Text(
                _isLoginMode ? "Welcome Back!" : "Join Eduverse",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Email Input
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Input
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Error Message Display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Main Button (Login or Sign Up)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          _isLoginMode ? "Login" : "Sign Up",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // Toggle Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    _errorMessage = null; // Clear errors when switching
                  });
                },
                child: Text(
                  _isLoginMode
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}