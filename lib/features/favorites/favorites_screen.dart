import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/user_service.dart';
import '../../core/widgets/favorite_button.dart';
import '../concepts/concept_detail_screen.dart';
import '../concepts/concepts_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Favorites"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Topics"),
              Tab(text: "Concepts"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Favorite Topics
            _FavoritesList(collection: 'topics', userField: 'favoriteTopics'),
            // Tab 2: Favorite Concepts
            _FavoritesList(collection: 'concepts', userField: 'favoriteConcepts'),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final String collection;
  final String userField;

  const _FavoritesList({required this.collection, required this.userField});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: UserService().getUserStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 1. Get List of IDs from User Profile
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final List<dynamic> favoriteIds = userData?[userField] ?? [];

        if (favoriteIds.isEmpty) {
          return Center(child: Text("No favorites in $collection yet."));
        }

        // 2. Fetch the actual items from the collection
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).snapshots(),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());

            // 3. Filter the list to show only favorites
            final docs = itemSnapshot.data!.docs.where((doc) {
              return favoriteIds.contains(doc.id);
            }).toList();

            if (docs.isEmpty) return const Center(child: Text("Items removed from database."));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                
                // Handle different field names
                final name = data['name'] ?? data['title'] ?? 'Untitled';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      collection == 'topics' ? Icons.library_books : Icons.lightbulb,
                      color: Colors.deepPurple,
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: FavoriteButton(
                      itemId: docs[index].id, 
                      type: userField, // Keeps the heart red/grey
                    ),
                    onTap: () {
                      // Navigate correctly based on what it is
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