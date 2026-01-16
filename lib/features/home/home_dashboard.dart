import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; 
import '../../core/services/ui_translation_service.dart';
import '../search/universal_search.dart';
import '../topics/topics_screen.dart'; // ✅ Added Import for Navigation

class HomeDashboard extends StatelessWidget {
  final VoidCallback onNavigateToSubjects;

  const HomeDashboard({super.key, required this.onNavigateToSubjects});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ui = UiTranslationService();
    
    // 📏 Responsive Measurements
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟣 RESPONSIVE HEADER
            Container(
              width: double.infinity,
              height: screenHeight * 0.30 > 280 ? screenHeight * 0.30 : 280, 
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea( 
                bottom: false, 
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. TOP ROW: Welcome & Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${ui.translate('welcome_back')} 👋", 
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                              ),
                              SizedBox(
                                width: screenWidth * 0.6, 
                                child: Text(
                                  user?.email?.split('@')[0] ?? "Student", 
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Color(0xFF5E35B1), size: 24),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20), 

                      // 2. SEARCH BAR
                      GestureDetector(
                        onTap: () => showSearch(context: context, delegate: UniversalSearch()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF7E57C2)),
                              const SizedBox(width: 12),
                              Text(
                                ui.translate('find_topic'), 
                                style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                    ],
                  ),
                ),
              ),
            ),
            
            // ... BODY CONTENT ...
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // MOTIVATION CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFF7043)]), 
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF7043).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ui.translate('did_you_know'), 
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                ui.translate('fact_text'), 
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SUBJECTS HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ui.translate('start_learning'),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF323232))
                      ),
                      TextButton(
                        onPressed: onNavigateToSubjects,
                        child: Text(ui.translate('view_all'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF7E57C2))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // SUBJECT LIST (Horizontal)
                  SizedBox(
                    height: 150, 
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('subjects').limit(5).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snapshot.data!.docs;
                        
                        final List<List<Color>> gradients = [
                          [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)], 
                          [const Color(0xFFBA68C8), const Color(0xFFAB47BC)], 
                          [const Color(0xFFFFB74D), const Color(0xFFFFA726)], 
                          [const Color(0xFF4DB6AC), const Color(0xFF26A69A)], 
                        ];

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: docs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == docs.length) return _buildViewAllCard(ui, onNavigateToSubjects);
                            
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final gradient = gradients[index % gradients.length];
                            
                            // 🚀 FIX: Passed OnTap Navigation Logic
                            return _buildSubjectCard(
                              data, 
                              gradient,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TopicsScreen(
                                      subjectId: doc.id,
                                      subjectName: data['name'] ?? 'Subject',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 🚀 FIX: Added onTap parameter and GestureDetector
  Widget _buildSubjectCard(Map<String, dynamic> data, List<Color> gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // ✅ Make it clickable
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Subject',
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "${data['difficulty'] ?? 'General'}",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCard(UiTranslationService ui, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF7E57C2)),
            const SizedBox(height: 8),
            Text(
              ui.translate('view_all'), 
              style: GoogleFonts.poppins(color: const Color(0xFF7E57C2), fontWeight: FontWeight.bold, fontSize: 12)
            ),
          ],
        ),
      ),
    );
  }
}