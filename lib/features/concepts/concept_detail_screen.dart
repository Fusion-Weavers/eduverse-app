import 'package:flutter/material.dart';

class ConceptDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConceptDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 🕵️ DATA EXTRACTION
    final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
    // Currently defaulting to 'en', but you can change this logic later for other languages
    final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};

    final String title = (data['title'] ?? content['title'] ?? en['title'] ?? 'Concept Detail').toString();
    final String summary = (en['summary'] ?? content['summary'] ?? 'No summary available.').toString();
    final String body = (en['body'] ?? content['body'] ?? data['body'] ?? 'No explanation available.').toString();
    
    // Metadata
    final String difficulty = (data['difficulty'] ?? 'General').toString();
    final String time = (data['estimatedReadTime'] ?? '5m').toString();
    final bool isArEnabled = data['arEnabled'] == true; // Check if AR is true

    // Arrays
    final List<dynamic> examples = (content['examples'] ?? en['examples'] ?? data['examples'] ?? []) as List<dynamic>;
    final List<dynamic> images = (content['images'] ?? en['images'] ?? data['images'] ?? []) as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for better contrast
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TOP ROW: Tags (Difficulty, Time, Language)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTag(Icons.speed, difficulty, Colors.orange),
                  const SizedBox(width: 8),
                  _buildTag(Icons.access_time, time, Colors.blue),
                  const SizedBox(width: 8),
                  _buildTag(Icons.language, "English", Colors.green), // Language Option
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 👓 AR ENHANCED OPTION (Only if True)
            if (isArEnabled) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.deepPurple]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // 🚀 PHASE 2 POPUP
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("🚀 AR Experience is coming in Phase 2!"),
                          backgroundColor: Colors.deepPurple.shade900,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.view_in_ar, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "View in Augmented Reality",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // 📝 SUMMARY CARD (Neat & Organized)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star_border, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text("Quick Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    summary,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📖 DETAILED EXPLANATION
            const Text(
              "Detailed Explanation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // 💡 EXAMPLES SECTION
            if (examples.isNotEmpty) ...[
              const Text("Real-World Examples", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...examples.map((ex) {
                String exText = ex is Map ? (ex['text'] ?? ex.toString()) : ex.toString();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Text(exText, style: const TextStyle(fontSize: 15, height: 1.4))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // 🖼️ IMAGES SECTION
            if (images.isNotEmpty) ...[
              const Text("Visual Aids", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imgData = images[index];
                    String imgUrl = (imgData is Map) ? (imgData['url'] ?? '').toString() : imgData.toString();
                    String imgTitle = (imgData is Map) ? (imgData['title'] ?? '').toString() : '';

                    return Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: imgUrl.startsWith('http')
                                  ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported))
                                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                          ),
                          if (imgTitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(imgTitle, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // Helper Widget for Tags
  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}