import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';

class FavoriteButton extends StatelessWidget {
  final String itemId;
  final String type; // 'favoriteTopics' or 'favoriteConcepts'
  final Color activeColor;

  const FavoriteButton({
    super.key, 
    required this.itemId, 
    required this.type,
    this.activeColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: UserService().getUserStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.favorite_border, color: Colors.grey);

        // Check if this Item ID exists in the User's array
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final List<dynamic> favorites = userData?[type] ?? [];
        final bool isFav = favorites.contains(itemId);

        return IconButton(
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? activeColor : Colors.grey,
          ),
          onPressed: () {
            // This updates the array in Firestore
            UserService().toggleFavorite(itemId, type);
          },
        );
      },
    );
  }
}