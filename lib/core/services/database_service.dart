import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all Subjects (Physics, Chemistry, etc.)
  Stream<QuerySnapshot> getSubjects() {
    return _db.collection('subjects').orderBy('order').snapshots();
  }

  // Fetch Topics for a specific Subject (We will use this later)
  Stream<QuerySnapshot> getTopics(String subjectId) {
    return _db
        .collection('topics')
        .where('subjectId', isEqualTo: subjectId)
        .snapshots();
  }
}