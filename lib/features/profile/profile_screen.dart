import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ui_translation_service.dart'; // ✅ Import
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}"; 
  }

  void _updateLanguage(String? newValue) {
    if (newValue == null) return;
    
    // 🚀 1. UPDATE GLOBAL UI INSTANTLY
    UiTranslationService().changeLanguage(newValue);

    // 2. Sync with Firebase for next login
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({'preferredLanguage': newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ui = UiTranslationService(); // ✅ Helper

    if (user == null) return const Center(child: Text("Please login first."));

    final List<String> languages = [
      'English', 'Hindi', 'Bengali', 'Marathi', 'Telugu', 'Tamil', 
      'Gujarati', 'Kannada', 'Malayalam', 'Punjabi', 'Urdu', 'Odia', 'Bhojpuri'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String role = data['role'] ?? 'Student';
          final String email = data['email'] ?? user.email ?? 'No Email';
          final Timestamp? joinedAt = data['createdAt'] as Timestamp?;
          
          final int topicsViewed = data['topicsViewed'] ?? 0;
          final int conceptsRead = data['conceptsRead'] ?? 0;
          final int minutesRead = data['minutesRead'] ?? 0;
          
          final List favTopics = data['favoriteTopics'] ?? [];
          final List favConcepts = data['favoriteConcepts'] ?? [];
          final int totalFavs = favTopics.length + favConcepts.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🟣 CURVED HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person_rounded, size: 60, color: Color(0xFF512DA8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        email.split('@')[0],
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📊 STATS GRID
                      Text("Your Progress", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(ui.translate('topics'), "$topicsViewed", Icons.library_books_rounded, Colors.blue)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard(ui.translate('concepts'), "$conceptsRead", Icons.lightbulb_rounded, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(ui.translate('mins_read'), "$minutesRead", Icons.timer_rounded, Colors.green)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard(ui.translate('favorites'), "$totalFavs", Icons.favorite_rounded, Colors.red)),
                        ],
                      ),
                      
                      const SizedBox(height: 30),

                      // ⚙️ SETTINGS CARD
                      Text(ui.translate('settings'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.calendar_today_rounded, color: Colors.purple),
                              title: Text(ui.translate('joined_on'), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              trailing: Text(_formatDate(joinedAt), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.translate_rounded, color: Colors.purple),
                              title: Text(ui.translate('language'), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              trailing: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  // 🔴 THIS IS CRITICAL: Bind to UI Service, NOT Firebase data for instant update
                                  value: ui.currentLanguage, 
                                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.purple),
                                  style: GoogleFonts.poppins(color: Colors.purple, fontWeight: FontWeight.bold),
                                  items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                                  onChanged: _updateLanguage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🚪 LOGOUT
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBEE),
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(ui.translate('log_out'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            AuthService().signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(count, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}