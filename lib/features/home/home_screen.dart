import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ui_translation_service.dart'; // ✅ Import Translation
import '../auth/login_screen.dart';
import '../subjects/subjects_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import 'home_dashboard.dart'; 
import '../search/universal_search.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _goToSubjectsTab() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final ui = UiTranslationService(); // ✅ Helper

    final List<Widget> pages = [
      HomeDashboard(onNavigateToSubjects: _goToSubjectsTab), 
      const SubjectsScreen(),                                
      const FavoritesScreen(),                               
      const ProfileScreen(),                                 
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Eduverse", // Brand names usually stay in English, but you can use ui.translate('app_name') if you want.
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: UniversalSearch());
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          // 🚀 TRANSLATED LABELS
          NavigationDestination(
            icon: const Icon(Icons.home), 
            label: ui.translate('nav_home'), // 'Home' -> 'होम'
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book), 
            label: ui.translate('nav_subjects'), // 'Subjects' -> 'विषय'
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite), 
            label: ui.translate('nav_favorites'), // 'Favorites' -> 'पसंदीदा'
          ),
          NavigationDestination(
            icon: const Icon(Icons.person), 
            label: ui.translate('nav_profile'), // 'Profile' -> 'प्रोफाइल'
          ),
        ],
      ),
    );
  }
}