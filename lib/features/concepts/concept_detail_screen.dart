import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure this is imported
import '../../core/services/translation_service.dart';
import 'ar_viewer_screen.dart';

class ConceptDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ConceptDetailScreen({super.key, required this.data});

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen> {
  String _selectedLanguage = 'English';
  bool _isTranslating = false;
  
  late String _displayTitle, _displaySummary, _displayBody;
  late String _originalTitle, _originalSummary, _originalBody;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadUserLanguagePreference();
  }

  void _initializeData() {
    final data = widget.data;
    final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
    final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};

    _originalTitle = (data['title'] ?? content['title'] ?? en['title'] ?? 'Concept Detail').toString();
    _originalSummary = (en['summary'] ?? content['summary'] ?? 'No summary available.').toString();
    _originalBody = (en['body'] ?? content['body'] ?? data['body'] ?? 'No explanation available.').toString();

    _displayTitle = _originalTitle;
    _displaySummary = _originalSummary;
    _displayBody = _originalBody;
  }

  Future<void> _loadUserLanguagePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          final preferred = doc.data()?['preferredLanguage'] ?? 'English';
          if (preferred != 'English' && preferred != _selectedLanguage) {
             _handleLanguageChange(preferred);
          }
        }
      } catch (e) { print(e); }
    }
  }

  Future<void> _handleLanguageChange(String? newLang) async {
    if (newLang == null) return;
    setState(() { _selectedLanguage = newLang; _isTranslating = true; });

    if (newLang == 'English') {
      if (mounted) setState(() { _displayTitle = _originalTitle; _displaySummary = _originalSummary; _displayBody = _originalBody; _isTranslating = false; });
    } else {
      final result = await TranslationService().translateContent(
        title: _originalTitle, summary: _originalSummary, body: _originalBody, targetLanguage: newLang,
      );
      if (mounted) setState(() { _displayTitle = result['title']!; _displaySummary = result['summary']!; _displayBody = result['body']!; _isTranslating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final modelUrl = data['modelUrl'];
    final bool hasArModel = modelUrl != null && modelUrl.isNotEmpty;
    
    // Arrays
    final content = data['content'] is Map ? data['content'] as Map<String, dynamic> : {};
    final en = content['en'] is Map ? content['en'] as Map<String, dynamic> : {};
    final examples = (content['examples'] ?? en['examples'] ?? data['examples'] ?? []) as List<dynamic>;
    final images = (content['images'] ?? en['images'] ?? data['images'] ?? []) as List<dynamic>;

    // 🟢 SAFE STRINGS
    final String difficultyStr = (data['difficulty'] ?? 'General').toString();
    final String timeStr = (data['estimatedReadTime'] ?? '5m').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isTranslating 
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(color: Colors.orange), const SizedBox(height: 16),
            Text("Magic Happening...", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple))
          ]))
        : CustomScrollView( // Using Slivers for a fancy scrolling header
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🟣 FANCY APP BAR
              SliverAppBar(
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6A1B9A),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _displayTitle, 
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        dropdownColor: const Color(0xFF4A148C),
                        icon: const Icon(Icons.translate_rounded, color: Colors.white, size: 20),
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        items: ['English', 'Hindi', 'Bengali', 'Marathi', 'Telugu', 'Tamil', 'Gujarati', 'Kannada', 'Malayalam', 'Punjabi', 'Urdu', 'Odia', 'Bhojpuri']
                            .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: _handleLanguageChange,
                      ),
                    ),
                  ),
                ],
              ),

              // 📄 CONTENT BODY
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏷️ BUBBLE TAGS
                      Row(children: [
                        _buildBubbleTag(Icons.speed_rounded, difficultyStr, Colors.orange),
                        const SizedBox(width: 10),
                        _buildBubbleTag(Icons.timer_rounded, timeStr, Colors.blue),
                      ]),
                      const SizedBox(height: 24),

                      // 👓 AR BUTTON (Super Button)
                      if (hasArModel) ...[
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArViewerScreen(modelUrl: modelUrl!, title: _originalTitle))),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]), // Bright Green
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Text("See it in 3D!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // 📝 SUMMARY CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0), // Light Orange Bg
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.bolt_rounded, color: Colors.orange, size: 28), 
                              const SizedBox(width: 8),
                              Text("Fast Facts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800]))
                            ]),
                            const SizedBox(height: 12),
                            Text(_displaySummary, style: GoogleFonts.poppins(fontSize: 16, height: 1.6, color: Colors.brown[800])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 📖 BODY
                      Text("Let's Learn!", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text(_displayBody, style: GoogleFonts.poppins(fontSize: 17, height: 1.8, color: Colors.grey[800])),
                      const SizedBox(height: 30),

                      // 💡 EXAMPLES
                      if (examples.isNotEmpty) ...[
                        Text("Real Examples", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        ...examples.map((ex) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD), // Light Blue
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_circle, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(child: Text(ex is Map ? (ex['text'] ?? '') : ex.toString(), style: GoogleFonts.poppins(fontSize: 15, height: 1.5, color: Colors.blue[900]))),
                            ],
                          ),
                        )),
                      ],

                      // 🖼️ VISUALS
                      if (images.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text("Visuals", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220, 
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final imgData = images[index];
                              String imgUrl = (imgData is Map) ? (imgData['url'] ?? '') : imgData.toString();
                              return Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20), 
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20), 
                                  child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                                ),
                              );
                            }
                          )
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBubbleTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color), const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}