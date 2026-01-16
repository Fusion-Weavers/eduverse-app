import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiTranslationService extends ChangeNotifier {
  static final UiTranslationService _instance = UiTranslationService._internal();
  factory UiTranslationService() => _instance;
  UiTranslationService._internal();

  String _currentLanguage = 'English';
  String get currentLanguage => _currentLanguage;

  // Static Dictionary for UI Buttons (Instant Translation)
  static final Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'welcome_back': 'Welcome Back!',
      'join_class': 'Join the Class!',
      'email': 'Email',
      'password': 'Password',
      'login': 'Log In',
      'signup': 'Sign Up',
      'browse_subjects': 'Browse Subjects',
      'view_all': 'View All',
      'my_collection': 'My Collection',
      'settings': 'Settings',
      'log_out': 'Log Out',
      'language': 'Language',
      'joined_on': 'Joined On',
      'favorites': 'Favorites',
      'topics': 'Topics',
      'concepts': 'Concepts',
      'mins_read': 'Mins Read',
      'find_topic': 'Find a topic...',
      'did_you_know': 'Did you know?',
      'fact_text': 'Learning just 10 mins a day boosts retention by 40%!',
      'start_learning': 'Start Learning',
      'saved_topics': 'Saved Topics',
      'saved_concepts': 'Saved Concepts',
      'no_favorites': 'No favorites yet.',
      'no_subjects': 'No subjects yet.',
      'no_topics': 'No topics found.',
      'items_removed': 'Items removed from database.',
      'tap_explore': 'Tap to explore concepts',
      'no_concepts': 'No concepts found.',
      'see_3d': 'See it in 3D!',
      'fast_facts': 'Fast Facts',
      'lets_learn': 'Let\'s Learn!',
      'examples': 'Real Examples',
      'visuals': 'Visuals',
      'magic_loading': 'Magic Happening...',
      'nav_home': 'Home',
      'nav_subjects': 'Subjects',
      'nav_favorites': 'Favorites',
      'nav_profile': 'Profile',
      'app_name': 'Eduverse',
    },
    'Hindi': {
      'welcome_back': 'वापसी पर स्वागत है!',
      'join_class': 'कक्षा में शामिल हों!',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'login': 'लॉग इन करें',
      'signup': 'साइन अप करें',
      'browse_subjects': 'विषय ब्राउज़ करें',
      'view_all': 'सभी देखें',
      'my_collection': 'मेरा संग्रह',
      'settings': 'सेटिंग्स',
      'log_out': 'लॉग आउट',
      'language': 'भाषा',
      'joined_on': 'शामिल हुए',
      'favorites': 'पसंदीदा',
      'topics': 'विषय',
      'concepts': 'अवधारणाएं',
      'mins_read': 'मिनट पढ़े',
      'find_topic': 'एक विषय खोजें...',
      'did_you_know': 'क्या तुम्हें पता था?',
      'fact_text': 'दिन में सिर्फ 10 मिनट सीखने से याददाश्त 40% बढ़ जाती है!',
      'start_learning': 'सीखना शुरू करें',
      'saved_topics': 'सहेजे गए विषय',
      'saved_concepts': 'सहेजी गई अवधारणाएं',
      'no_favorites': 'अभी तक कोई पसंदीदा नहीं।',
      'no_subjects': 'अभी तक कोई विषय नहीं।',
      'no_topics': 'कोई विषय नहीं मिला।',
      'items_removed': 'डेटाबेस से आइटम हटा दिए गए।',
      'tap_explore': 'अवधारणाओं को देखने के लिए टैप करें',
      'no_concepts': 'कोई अवधारणा नहीं मिली।',
      'see_3d': 'इसे 3D में देखें!',
      'fast_facts': 'महत्वपूर्ण तथ्य',
      'lets_learn': 'आइए सीखें!',
      'examples': 'वास्तविक उदाहरण',
      'visuals': 'दृश्य',
      'magic_loading': 'जादू हो रहा है...',
      'nav_home': 'होम',
      'nav_subjects': 'विषय',
      'nav_favorites': 'पसंदीदा',
      'nav_profile': 'प्रोफाइल',
      'app_name': 'एडुवर्स',
    },
    'Bengali': {
      'welcome_back': 'স্বাগতম!',
      'join_class': 'ক্লাসে যোগ দিন!',
      'email': 'ইমেল',
      'password': 'পাসওয়ার্ড',
      'login': 'লগ ইন',
      'signup': 'সাইন আপ',
      'browse_subjects': 'বিষয়গুলি দেখুন',
      'view_all': 'সব দেখুন',
      'my_collection': 'আমার সংগ্রহ',
      'settings': 'সেটিংস',
      'log_out': 'লগ আউট',
      'language': 'ভাষা',
      'joined_on': 'যোগ দিয়েছেন',
      'favorites': 'প্রিয়',
      'topics': 'টপিক',
      'concepts': 'ধারণা',
      'mins_read': 'মিনিট পড়া',
      'find_topic': 'একটি বিষয় খুঁজুন...',
      'did_you_know': 'আপনি কি জানেন?',
      'fact_text': 'দিনে মাত্র ১০ মিনিট শিখলে স্মৃতিশক্তি ৪০% বৃদ্ধি পায়!',
      'start_learning': 'শেখা শুরু করুন',
      'saved_topics': 'সংরক্ষিত বিষয়',
      'saved_concepts': 'সংরক্ষিত ধারণা',
      'no_favorites': 'এখনও কোনো প্রিয় নেই।',
      'no_subjects': 'এখনও কোনো বিষয় নেই।',
      'no_topics': 'কোনো বিষয় পাওয়া যায়নি।',
      'items_removed': 'ডেটাবেস থেকে আইটেম সরানো হয়েছে।',
      'tap_explore': 'ধারণাগুলি দেখতে ট্যাপ করুন',
      'no_concepts': 'কোনো ধারণা পাওয়া যায়নি।',
      'see_3d': 'এটি 3D তে দেখুন!',
      'fast_facts': 'দ্রুত তথ্য',
      'lets_learn': 'আসুন শিখি!',
      'examples': 'বাস্তব উদাহরণ',
      'visuals': 'ভিজ্যুয়াল',
      'magic_loading': 'ম্যাজিক হচ্ছে...',
      'nav_home': 'হোম',
      'nav_subjects': 'বিষয়',
      'nav_favorites': 'প্রিয়',
      'nav_profile': 'প্রোফাইল',
      'app_name': 'এডুভার্স',
    },
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'English';
    notifyListeners();
  }

  Future<void> changeLanguage(String newLang) async {
    _currentLanguage = newLang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLang);
    notifyListeners();
  }

  // 1. Get Static Text (Buttons, Labels)
  String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['English']?[key] ?? key;
  }

  // 2. Just return text as-is (No API calls)
  String translateDynamic(String? text) {
    return text ?? ""; 
  }
}