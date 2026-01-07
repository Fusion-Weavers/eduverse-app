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
  bool _isLoginMode = true; 
  String? _errorMessage;

  // Dropdown Values
  String _selectedRole = 'Student';
  String _selectedLanguage = 'English';
  final List<String> _roles = ['Student', 'Teacher', 'Parent'];
  final List<String> _languages = [
    'English', 
    'Hindi', 
    'Bengali', 
    'Marathi', 
    'Telugu', 
    'Tamil', 
    'Gujarati', 
    'Kannada', 
    'Malayalam', 
    'Punjabi', 
    'Urdu', 
    'Odia',
    'Bhojpuri'
  ];

  Future<void> _submitForm() async {
    // 1. Reset Error & Start Loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 2. Basic Validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter email and password.";
        _isLoading = false;
      });
      return;
    }

    try {
      if (_isLoginMode) {
        // LOGIN
        await _authService.signIn(email: email, password: password);
      } else {
        // SIGN UP
        await _authService.signUp(
          email: email, 
          password: password,
          role: _selectedRole,
          language: _selectedLanguage,
        );
      }
      // If successful, the AuthWrapper in main.dart will automatically switch screens.
      
    } on FirebaseAuthException catch (e) {
      // 3. Catch Firebase Errors
      String msg = "An error occurred.";
      if (e.code == 'user-not-found') msg = "No user found with this email.";
      else if (e.code == 'wrong-password') msg = "Wrong password.";
      else if (e.code == 'invalid-credential') msg = "Invalid email or password.";
      else if (e.code == 'email-already-in-use') msg = "Email already in use.";
      else if (e.code == 'weak-password') msg = "Password is too weak.";
      else msg = e.message ?? "Authentication failed.";

      setState(() => _errorMessage = msg);
      
      // Show SnackBar for better visibility
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );

    } catch (e) {
      // 4. Catch Other Errors
      setState(() => _errorMessage = "Error: $e");
      print("Login Error: $e"); // Print to console for debugging
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
            children: [
              const Icon(Icons.school, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(_isLoginMode ? "Welcome Back!" : "Join Eduverse", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Email
              TextField(
                controller: _emailController, 
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))
              ),
              const SizedBox(height: 16),
              
              // Password
              TextField(
                controller: _passwordController, 
                obscureText: true, 
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))
              ),
              const SizedBox(height: 16),

              // Sign Up Extras
              if (!_isLoginMode) ...[
                DropdownButtonFormField(
                  value: _selectedRole,
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                  decoration: const InputDecoration(labelText: "I am a...", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _selectedLanguage,
                  items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                  decoration: const InputDecoration(labelText: "Preferred Language", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
              ],

              // Error Text
              if (_errorMessage != null) 
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              // Button
              SizedBox(
                width: double.infinity, 
                height: 50, 
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : ElevatedButton(
                      onPressed: _submitForm, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white), 
                      child: Text(_isLoginMode ? "Login" : "Sign Up")
                    )
              ),
              
              // Toggle Login/Signup
              TextButton(
                onPressed: () => setState(() {
                  _isLoginMode = !_isLoginMode;
                  _errorMessage = null;
                }), 
                child: Text(_isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login")
              ),
            ],
          ),
        ),
      ),
    );
  }
}