import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
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

  // Function to switch to Subjects tab from Home
  void _goToSubjectsTab() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboard(onNavigateToSubjects: _goToSubjectsTab), // Index 0
      const SubjectsScreen(),                                // Index 1
      const FavoritesScreen(),                               // Index 2
      const ProfileScreen(),                                 // Index 3
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eduverse"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
               // Now this works because we imported universal_search.dart
               showSearch(context: context, delegate: UniversalSearch());
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}