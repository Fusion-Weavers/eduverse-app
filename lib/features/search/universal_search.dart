import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../topics/topics_screen.dart';
import '../concepts/concepts_screen.dart';
import '../concepts/concept_detail_screen.dart';

class UniversalSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Search for subjects, topics, or concepts..."));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    // 🧠 SMART SEARCH: Fetch everything and filter LOCALLY for Case-Insensitivity
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('subjects').get(),
        FirebaseFirestore.instance.collection('topics').get(),
        FirebaseFirestore.instance.collection('concepts').get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) return const Center(child: Text("No results found."));

        // 1. Combine All Documents
        final subjects = snapshot.data![0].docs;
        final topics = snapshot.data![1].docs;
        final concepts = snapshot.data![2].docs;
        final allDocs = [...subjects, ...topics, ...concepts];

        // 2. FILTER LOCALLY (Case Insensitive Logic)
        final searchLower = query.toLowerCase();
        
        final results = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          // Check Name/Title based on what fields exist
          String name = (data['name'] ?? data['title'] ?? '').toString().toLowerCase();
          
          // Also check description/summary if you want smarter search
          // String desc = (data['description'] ?? '').toString().toLowerCase();

          return name.contains(searchLower);
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text("No matching results found."));
        }

        // 3. Show Results
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Determine Type
            String type = "Unknown";
            String title = "Untitled";
            
            if (doc.reference.parent.id == 'subjects') {
              type = "Subject";
              title = data['name'] ?? 'Subject';
            } else if (doc.reference.parent.id == 'topics') {
              type = "Topic";
              title = data['name'] ?? 'Topic';
            } else {
              type = "Concept";
              title = data['title'] ?? 'Concept';
            }

            return ListTile(
              leading: Icon(_getIconForType(type), color: Colors.deepPurple),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(type),
              onTap: () {
                // Navigate based on Type
                if (type == 'Subject') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TopicsScreen(subjectId: doc.id, subjectName: title)
                  ));
                } else if (type == 'Topic') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ConceptsScreen(topicId: doc.id, topicName: title)
                  ));
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ConceptDetailScreen(data: data)
                  ));
                }
              },
            );
          },
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    if (type == 'Subject') return Icons.menu_book;
    if (type == 'Topic') return Icons.library_books;
    return Icons.lightbulb;
  }
}