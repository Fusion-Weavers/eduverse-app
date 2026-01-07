import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../concepts/concepts_screen.dart'; 
import '../../core/widgets/favorite_button.dart'; 

class TopicsScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const TopicsScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subjectName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('topics')
            .where('subjectId', isEqualTo: subjectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No topics found."));
          }

          final topics = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final data = topics[index].data() as Map<String, dynamic>;
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.library_books, color: Colors.deepPurple),
                  title: Text(
                    data['name'] ?? 'Untitled Topic',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${data['difficulty'] ?? 'General'} • ${data['estimatedTime'] ?? '10m'}"),
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FavoriteButton(
                        itemId: topics[index].id,
                        type: 'favoriteTopics', // Saves to 'favoriteTopics' array
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
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