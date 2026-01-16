import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ui_translation_service.dart'; // ✅ Import Translation
import '../home/home_screen.dart';

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

  String _selectedRole = 'Student';
  String _selectedLanguage = 'English';
  final List<String> _roles = ['Student', 'Teacher', 'Parent'];
  final List<String> _languages = [
    'English', 'Hindi', 'Bengali', 'Marathi', 'Telugu', 'Tamil', 
    'Gujarati', 'Kannada', 'Malayalam', 'Punjabi', 'Urdu', 'Odia', 'Bhojpuri'
  ];

  Future<void> _submitForm() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() { _errorMessage = "Please enter email and password."; _isLoading = false; });
      return;
    }

    try {
      if (_isLoginMode) {
        await _authService.signIn(email: email, password: password);
      } else {
        await _authService.signUp(
          email: email, password: password, role: _selectedRole, language: _selectedLanguage,
        );
      }
      
      if (mounted && FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()), 
          (route) => false
        );
      }

    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Authentication failed.";
      setState(() => _errorMessage = msg);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = UiTranslationService(); // ✅ Translation Helper

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)], 
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, size: 50, color: Color(0xFF6A1B9A)),
                ),
                const SizedBox(height: 24),
                
                Text(
                  "Eduverse",
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                ),
                Text(
                  "Your Learning Journey Starts Here",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      // 🌍 TRANSLATED TITLE
                      Text(
                        _isLoginMode ? ui.translate('welcome_back') : ui.translate('join_class'),
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C)),
                      ),
                      const SizedBox(height: 20),

                      // 🌍 TRANSLATED INPUTS
                      _buildInput(_emailController, ui.translate('email'), Icons.email_rounded, false),
                      const SizedBox(height: 16),
                      _buildInput(_passwordController, ui.translate('password'), Icons.lock_rounded, true),
                      const SizedBox(height: 16),

                      if (!_isLoginMode) ...[
                        _buildDropdown("I am a...", _selectedRole, _roles, (v) => setState(() => _selectedRole = v!)),
                        const SizedBox(height: 16),
                        _buildDropdown(ui.translate('language'), _selectedLanguage, _languages, (v) => setState(() => _selectedLanguage = v!)),
                        const SizedBox(height: 20),
                      ],

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F00),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : Text(
                                _isLoginMode ? ui.translate('login') : ui.translate('signup'), // 🌍 TRANSLATED BUTTON
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => setState(() { _isLoginMode = !_isLoginMode; _errorMessage = null; }),
                  child: Text(
                    _isLoginMode ? "New Student? Create Account" : "Already have an account? Log In",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF7B1FA2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?) changed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonFormField<String>(
        value: val,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: changed,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF7B1FA2)),
      ),
    );
  }
}