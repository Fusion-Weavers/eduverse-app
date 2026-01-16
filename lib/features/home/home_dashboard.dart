import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../search/universal_search.dart';

class HomeDashboard extends StatelessWidget {
  final VoidCallback onNavigateToSubjects;

  const HomeDashboard({super.key, required this.onNavigateToSubjects});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Very light cool grey background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟣 VIBRANT HEADER SECTION
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)], // Deep Purple Gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back, 👋", 
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                          ),
                          Text(
                            user?.email?.split('@')[0] ?? "Student", 
                            style: GoogleFonts.poppins(
                              color: Colors.white, 
                              fontSize: 26, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white24, 
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Color(0xFF5E35B1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 🔍 SEARCH BAR (Floating inside Header)
                  GestureDetector(
                    onTap: () => showSearch(context: context, delegate: UniversalSearch()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF7E57C2)),
                          const SizedBox(width: 12),
                          Text(
                            "Find a topic...", 
                            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  // 🚀 DAILY MOTIVATION CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFF7043)]), // Orange Gradient
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF7043).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Did you know?", 
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                "Learning just 10 mins a day boosts retention by 40%!", 
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 📚 SUBJECTS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Start Learning", 
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF323232))
                      ),
                      TextButton(
                        onPressed: onNavigateToSubjects,
                        child: Text("View All", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF7E57C2))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // 🎨 COLORFUL HORIZONTAL LIST
                  SizedBox(
                    height: 160,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('subjects').limit(5).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snapshot.data!.docs;
                        
                        // Define a list of fun gradients to cycle through
                        final List<List<Color>> gradients = [
                          [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)], // Blue
                          [const Color(0xFFBA68C8), const Color(0xFFAB47BC)], // Purple
                          [const Color(0xFFFFB74D), const Color(0xFFFFA726)], // Orange
                          [const Color(0xFF4DB6AC), const Color(0xFF26A69A)], // Teal
                        ];

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: docs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == docs.length) return _buildViewAllCard();
                            
                            // Pick a gradient based on index
                            final gradient = gradients[index % gradients.length];
                            return _buildSubjectCard(docs[index].data() as Map<String, dynamic>, gradient);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> data, List<Color> gradient) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? 'Subject',
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "${data['difficulty'] ?? 'General'}",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllCard() {
    return GestureDetector(
      onTap: onNavigateToSubjects,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF7E57C2)),
            const SizedBox(height: 8),
            Text(
              "See All", 
              style: GoogleFonts.poppins(color: const Color(0xFF7E57C2), fontWeight: FontWeight.bold, fontSize: 13)
            ),
          ],
        ),
      ),
    );
  }
}