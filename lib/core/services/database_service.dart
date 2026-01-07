import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // FIX: Removed .orderBy('order') because your database doesn't have that field!
  Stream<QuerySnapshot> getSubjects() {
    return _db.collection('subjects').snapshots();
  }

  // Fetch Topics (This was already correct)
  Stream<QuerySnapshot> getTopics(String subjectId) {
    return _db
        .collection('topics')
        .where('subjectId', isEqualTo: subjectId)
        .snapshots();
  }
}