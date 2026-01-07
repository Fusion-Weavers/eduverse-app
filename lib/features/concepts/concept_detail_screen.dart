import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/translation_service.dart';
import 'ar_viewer_screen.dart';

class ConceptDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ConceptDetailScreen({super.key, required this.data});

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen> {
  // State Variables
  String _selectedLanguage = 'English';
  bool _isTranslating = false;
  
  late String _displayTitle;
  late String _displaySummary;
  late String _displayBody;

  // Store original English values
  late String _originalTitle;
  late String _originalSummary;
  late String _originalBody;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Auto-load the user's preferred language
    _loadUserLanguagePreference();
  }

  void _initializeData() {
    final data = widget.data;
    final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
    final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};

    _originalTitle = (data['title'] ?? content['title'] ?? en['title'] ?? 'Concept Detail').toString();
    _originalSummary = (en['summary'] ?? content['summary'] ?? 'No summary available.').toString();
    _originalBody = (en['body'] ?? content['body'] ?? data['body'] ?? 'No explanation available.').toString();

    // Initially show English
    _displayTitle = _originalTitle;
    _displaySummary = _originalSummary;
    _displayBody = _originalBody;
  }

  // FETCH USER PREFERENCE AUTOMATICALLY
  Future<void> _loadUserLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final data = doc.data();
          final String preferred = data?['preferredLanguage'] ?? 'English';
          
          // If the user prefers something other than English, translate immediately
          if (preferred != 'English' && preferred != _selectedLanguage) {
             _handleLanguageChange(preferred);
          }
        }
      } catch (e) {
        print("Error loading language preference: $e");
      }
    }
  }

  Future<void> _handleLanguageChange(String? newLang) async {
    if (newLang == null) return;

    setState(() {
      _selectedLanguage = newLang;
      _isTranslating = true;
    });

    if (newLang == 'English') {
      // Restore Original
      if (mounted) {
        setState(() {
          _displayTitle = _originalTitle;
          _displaySummary = _originalSummary;
          _displayBody = _originalBody;
          _isTranslating = false;
        });
      }
    } else {
      // Call Gemini AI
      final result = await TranslationService().translateContent(
        title: _originalTitle,
        summary: _originalSummary,
        body: _originalBody,
        targetLanguage: newLang,
      );

      if (mounted) {
        setState(() {
          _displayTitle = result['title']!;
          _displaySummary = result['summary']!;
          _displayBody = result['body']!;
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    
    // Metadata
    final String difficulty = (data['difficulty'] ?? 'General').toString();
    final String time = (data['estimatedReadTime'] ?? '5m').toString();
    final String? modelUrl = data['modelUrl'];
    final bool hasArModel = modelUrl != null && modelUrl.isNotEmpty;

    // Arrays
    final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
    final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};
    final List<dynamic> examples = (content['examples'] ?? en['examples'] ?? data['examples'] ?? []) as List<dynamic>;
    final List<dynamic> images = (content['images'] ?? en['images'] ?? data['images'] ?? []) as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_displayTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isTranslating 
        ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Translating to $_selectedLanguage...", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 TOP ROW: Tags + Language Dropdown
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTag(Icons.speed, difficulty, Colors.orange),
                      const SizedBox(width: 8),
                      _buildTag(Icons.access_time, time, Colors.blue),
                      const SizedBox(width: 8),
                      // 🌍 LANGUAGE DROPDOWN
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            icon: const Icon(Icons.translate, size: 16, color: Colors.green),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                            // 🚀 ADDED BHOJPURI HERE
                            items: [
                              'English', 
                              'Hindi', 
                              'Bengali', 
                              'Marathi', 
                              'Telugu', 
                              'Tamil', 
                              'Gujarati', 
                              'Kannada', 
                              'Malayalam', 
                              'Punjabi', 
                              'Urdu', 
                              'Odia',
                              'Bhojpuri' 
                            ].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                            onChanged: _handleLanguageChange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 👓 AR / 3D BUTTON
                if (hasArModel) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.purple.shade700]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArViewerScreen(
                                modelUrl: modelUrl!, 
                                title: _originalTitle,
                              ),
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
                              Text("View in 3D / AR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // 📝 SUMMARY CARD
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
                        _displaySummary,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 📖 DETAILED EXPLANATION
                const Text("Detailed Explanation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 10),
                Text(
                  _displayBody,
                  style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
                ),
                const SizedBox(height: 30),

                // 💡 EXAMPLES SECTION
                if (examples.isNotEmpty) ...[
                  const Text("Examples", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                ],
                
                // 🖼️ IMAGES SECTION
                if (images.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text("Visuals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                        height: 200, 
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                                final imgData = images[index];
                                String imgUrl = (imgData is Map) ? (imgData['url'] ?? '') : imgData.toString();
                                return Container(
                                    width: 300,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12), 
                                      child: Image.network(
                                        imgUrl, 
                                        fit: BoxFit.cover, 
                                        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey)
                                      ),
                                    ),
                                );
                            }
                        )
                    )
                ]
              ],
            ),
          ),
    );
  }

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