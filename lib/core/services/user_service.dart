import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current User ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream: Watch User Data (To know which hearts are red)
  Stream<DocumentSnapshot> getUserStream() {
    if (currentUserId == null) return const Stream.empty();
    return _db.collection('users').doc(currentUserId).snapshots();
  }

  // Action: Add or Remove Favorite
  Future<void> toggleFavorite(String itemId, String type) async {
    // type is either 'favoriteTopics' or 'favoriteConcepts'
    if (currentUserId == null) return;

    final userRef = _db.collection('users').doc(currentUserId);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?[type] ?? [];
      
      if (favorites.contains(itemId)) {
        // Remove it
        await userRef.update({
          type: FieldValue.arrayRemove([itemId])
        });
      } else {
        // Add it
        await userRef.update({
          type: FieldValue.arrayUnion([itemId])
        });
      }
    }
  }
}