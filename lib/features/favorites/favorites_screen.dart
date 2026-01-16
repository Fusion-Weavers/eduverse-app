import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/user_service.dart';
import '../../core/services/ui_translation_service.dart'; // ✅ Import
import '../../core/widgets/favorite_button.dart';
import '../concepts/concept_detail_screen.dart';
import '../concepts/concepts_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = UiTranslationService(); // ✅ Helper

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          title: Text(
            ui.translate('my_collection'), // 🌍 TRANSLATED
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
          ),
          backgroundColor: const Color(0xFF6A1B9A),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: const Color(0xFF6A1B9A),
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                indicatorColor: const Color(0xFF6A1B9A),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: ui.translate('saved_topics')),   // 🌍 TRANSLATED
                  Tab(text: ui.translate('saved_concepts')), // 🌍 TRANSLATED
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _FavoritesList(collection: 'topics', userField: 'favoriteTopics', emptyMsg: ui.translate('no_favorites')),
            _FavoritesList(collection: 'concepts', userField: 'favoriteConcepts', emptyMsg: ui.translate('no_favorites')),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final String collection;
  final String userField;
  final String emptyMsg;

  const _FavoritesList({required this.collection, required this.userField, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: UserService().getUserStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final List<dynamic> favoriteIds = userData?[userField] ?? [];

        if (favoriteIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(emptyMsg, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).snapshots(),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = itemSnapshot.data!.docs.where((doc) {
              return favoriteIds.contains(doc.id);
            }).toList();

            if (docs.isEmpty) return Center(child: Text(UiTranslationService().translate('items_removed'), style: GoogleFonts.poppins()));

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final name = data['name'] ?? data['title'] ?? 'Untitled';
                final isTopic = collection == 'topics';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isTopic ? Colors.blue.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTopic ? Icons.library_books_rounded : Icons.lightbulb_rounded,
                        color: isTopic ? Colors.blue : Colors.amber,
                        size: 24,
                      ),
                    ),
                    title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                    trailing: FavoriteButton(itemId: docs[index].id, type: userField),
                    onTap: () {
                      if (collection == 'topics') {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ConceptsScreen(topicId: docs[index].id, topicName: name)
                        ));
                      } else {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ConceptDetailScreen(data: data)
                        ));
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}