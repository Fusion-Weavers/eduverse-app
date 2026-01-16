import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/ui_translation_service.dart';
import '../../core/widgets/favorite_button.dart';
import '../concepts/concepts_screen.dart'; 

class TopicsScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const TopicsScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final ui = UiTranslationService();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          subjectName, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: const Color(0xFF6A1B9A), 
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('topics')
            .where('subjectId', isEqualTo: subjectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                ui.translate('no_topics'), // Static Translate
                style: GoogleFonts.poppins(color: Colors.grey)
              ),
            );
          }

          final topics = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final data = topics[index].data() as Map<String, dynamic>;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE7F6), 
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF5E35B1)),
                      ),
                    ),
                  ),
                  
                  title: Text(
                    data['name'] ?? 'Untitled Topic',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded( 
                          child: Text(
                            data['description'] ?? ui.translate('tap_explore'),
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteButton(
                        itemId: topics[index].id,
                        type: 'favoriteTopics', 
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConceptsScreen(
                          topicId: topics[index].id,
                          topicName: data['name'] ?? 'Topic',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}