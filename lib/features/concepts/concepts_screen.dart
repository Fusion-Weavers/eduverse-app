import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'concept_detail_screen.dart';
import '../../core/widgets/favorite_button.dart';

class ConceptsScreen extends StatelessWidget {
  final String topicId;
  final String topicName;

  const ConceptsScreen({super.key, required this.topicId, required this.topicName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topicName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('concepts')
            .where('topicId', isEqualTo: topicId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No concepts found."));
          }

          final concepts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: concepts.length,
            itemBuilder: (context, index) {
              final data = concepts[index].data() as Map<String, dynamic>;
              
              // Safe Data Extraction
              final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
              final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};
              final title = (data['title'] ?? content['title'] ?? en['title'] ?? 'Concept').toString();
              final summary = (en['summary'] ?? content['summary'] ?? 'Tap to read more...').toString();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.auto_stories, color: Colors.deepPurple),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteButton(
                        itemId: concepts[index].id,
                        type: 'favoriteConcepts', // Saves to 'favoriteConcepts' array
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConceptDetailScreen(data: data),
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