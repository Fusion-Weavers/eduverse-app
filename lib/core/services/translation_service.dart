import 'package:google_generative_ai/google_generative_ai.dart';

class TranslationService {
  static const String _apiKey = "AIzaSyB8sFQfN9chcscDciwo6ajaFgnrrESO5Jw";

  Future<Map<String, String>> translateContent({
    required String title,
    required String body,
    required String summary,
    required String targetLanguage,
  }) async {
    if (targetLanguage == 'English') {
      return {'title': title, 'body': body, 'summary': summary};
    }

    // 🛡️ 2026 MODEL LIST
    // 1. Gemini 2.5 Flash (Primary - Rizwan's Choice)
    // 2. Gemini 2.0 Flash (Backup)
    // 3. Gemini Pro (Auto-resolves to latest stable)
    final modelsToTry = [
      'gemini-2.5-flash', 
      'gemini-2.0-flash', 
      'gemini-pro'
    ];

    for (final modelName in modelsToTry) {
      try {
        print("Attempting translation with model: $modelName...");
        
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);

        final prompt = '''
          Translate this JSON content to $targetLanguage.
          Return ONLY valid JSON.
          
          {
            "title": "$title",
            "summary": "$summary",
            "body": "$body"
          }
        ''';

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        
        final responseText = response.text;
        if (responseText == null) throw "No response from AI";

        // ✅ Success!
        print("✅ Success with $modelName");

        String cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();

        final titleMatch = RegExp(r'"title":\s*"(.*?)"', dotAll: true).firstMatch(cleanJson);
        final summaryMatch = RegExp(r'"summary":\s*"(.*?)"', dotAll: true).firstMatch(cleanJson);
        final bodyMatch = RegExp(r'"body":\s*"(.*?)"', dotAll: true).firstMatch(cleanJson);

        return {
          'title': titleMatch?.group(1) ?? title,
          'summary': summaryMatch?.group(1) ?? summary,
          'body': bodyMatch?.group(1) ?? body,
        };

      } catch (e) {
        print("❌ Failed with $modelName: $e");
        // Continue to next model...
      }
    }

    // 🚨 Fallback if all fail
    print("All models failed. Showing English.");
    return {
      'title': title,
      'summary': summary,
      'body': body
    };
  }
}