import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/database_service.dart';
import '../../core/services/ui_translation_service.dart';
import '../topics/topics_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = UiTranslationService(); 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), 
      appBar: AppBar(
        title: Text(
          ui.translate('browse_subjects'), // Static Translate
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A148C)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                ui.translate('no_subjects'),
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16),
              ),
            );
          }

          final subjects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final data = subjects[index].data() as Map<String, dynamic>;
              
              final List<List<Color>> gradients = [
                [const Color(0xFF7E57C2), const Color(0xFF5E35B1)], 
                [const Color(0xFF42A5F5), const Color(0xFF1976D2)], 
                [const Color(0xFFEF5350), const Color(0xFFC62828)], 
                [const Color(0xFF66BB6A), const Color(0xFF2E7D32)], 
              ];
              final gradient = gradients[index % gradients.length];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicsScreen(
                        subjectId: subjects[index].id, 
                        subjectName: data['name'] ?? 'Subject',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Unnamed Subject', 
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['description'] ?? 'Tap to start learning',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}