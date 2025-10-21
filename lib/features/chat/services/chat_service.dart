import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatService() {
    _initializeChat();
  }

  void _initializeChat() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final modelName = dotenv.env['GEMINI_MODEL'] ?? 'gemini-pro';
    
    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('GEMINI_API_KEY not found in .env file. Please add your API key.');
    }

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    int retryCount = 0;
    const maxRetries = 2;
    
    // Add instruction to keep responses short
    final messageWithInstruction = '''$message

[Important: Please provide a brief, concise response in 2-3 lines maximum. Focus on the most important actionable advice.]''';
    
    while (retryCount <= maxRetries) {
      try {
        // Send the user message with instruction
        final response = await _chat.sendMessage(Content.text(messageWithInstruction));
        return response.text ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
      } catch (e) {
        retryCount++;
        
        // Check if it's an overload error
        if (e.toString().contains('overloaded') || e.toString().contains('503')) {
          if (retryCount <= maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
          throw Exception('The AI service is currently overloaded. Please try again in a moment.');
        }
        
        // For other errors, throw immediately
        throw Exception('Failed to send message: $e');
      }
    }
    
    throw Exception('Failed to send message after multiple attempts.');
  }

  void resetChat() {
    _initializeChat();
  }

  List<String> getSuggestionPrompts() {
    return [
      'suggestion_morning_routine'.tr(),
      'suggestion_consistency'.tr(),
      'suggestion_track_habits'.tr(),
      'suggestion_good_habits'.tr(),
      'suggestion_procrastination'.tr(),
      'suggestion_exercise_time'.tr(),
      'suggestion_reading_habit'.tr(),
      'suggestion_sleep_habits'.tr(),
    ];
  }
}
