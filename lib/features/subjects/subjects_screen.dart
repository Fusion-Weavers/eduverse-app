import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/database_service.dart';
// 🔴 IMPORT THE TOPICS SCREEN
import '../topics/topics_screen.dart'; 

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Subjects")),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getSubjects(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No subjects added yet.\n(Wait for Web Team)"),
            );
          }

          // 4. Data List
          final subjects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final data = subjects[index].data() as Map<String, dynamic>;
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.menu_book, color: Colors.deepPurple, size: 40),
                  title: Text(
                    data['name'] ?? 'Unnamed Subject', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(data['description'] ?? 'No description'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 🔴 NAVIGATION LOGIC ADDED HERE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicsScreen(
                          // Pass the Document ID (e.g. 'physics') so we can fetch its topics
                          subjectId: subjects[index].id, 
                          subjectName: data['name'] ?? 'Subject',
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