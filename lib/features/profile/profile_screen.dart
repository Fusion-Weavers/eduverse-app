import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper to format Timestamp to String
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}"; 
  }

  // Update Language in Database
  void _updateLanguage(String? newValue) {
    if (newValue == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'preferredLanguage': newValue,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login first."));
    }

    // 🔴 FIXED: Defined the list here so the code can see it
    final List<String> languages = [
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

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile"), elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          // 1. EXTRACT DATA
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String role = data['role'] ?? 'Student';
          final String email = data['email'] ?? user.email ?? 'No Email';
          final Timestamp? joinedAt = data['createdAt'] as Timestamp?;
          
          // 🔴 SAFETY CHECK FOR LANGUAGE
          String currentLang = data['preferredLanguage'] ?? 'English';
          if (!languages.contains(currentLang)) {
            currentLang = 'English'; // Fallback if DB has weird value like 'en' or 'Spanish'
          }
          
          // Stats Calculations
          final List favTopics = data['favoriteTopics'] ?? [];
          final List favConcepts = data['favoriteConcepts'] ?? [];
          final int totalFavs = favTopics.length + favConcepts.length;
          final int topicsViewed = data['topicsViewed'] ?? 0;
          final int conceptsRead = data['conceptsRead'] ?? 0;
          final int minutesRead = data['minutesRead'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 👤 PROFILE HEADER
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  email,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(role.toUpperCase()),
                  backgroundColor: Colors.deepPurple.shade50,
                  labelStyle: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                ),
                const SizedBox(height: 24),

                // 📊 LEARNING STATISTICS (Grid)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Learning Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard("Topics Viewed", "$topicsViewed", Icons.visibility, Colors.blue),
                    _buildStatCard("Concepts Read", "$conceptsRead", Icons.auto_stories, Colors.orange),
                    _buildStatCard("Mins Read", "$minutesRead", Icons.timer, Colors.green),
                    _buildStatCard("Favorites", "$totalFavs", Icons.favorite, Colors.red),
                  ],
                ),
                const SizedBox(height: 30),

                // ⚙️ ACCOUNT DETAILS
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Account Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                        title: const Text("Joining Date"),
                        trailing: Text(_formatDate(joinedAt), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      // 🌍 LANGUAGE DROPDOWN
                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.deepPurple),
                        title: const Text("Preferred Language"),
                        trailing: DropdownButton<String>(
                          value: currentLang,
                          underline: const SizedBox(),
                          items: languages
                              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                              .toList(),
                          onChanged: _updateLanguage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🚪 LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("Log Out"),
                    onPressed: () {
                      AuthService().signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🎨 Helper Widget for Stat Cards
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}