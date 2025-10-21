import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/features/chat/models/message.dart';
import 'package:daily_habits/features/chat/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    // Add welcome message
    _messages.add(
      Message(
        id: const Uuid().v4(),
        content: 'ai_welcome_message'.tr(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _error = null;

    // Add user message
    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Add loading message
    final loadingMessage = Message(
      id: const Uuid().v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    _messages.add(loadingMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Send message to AI
      final response = await _chatService.sendMessage(content);

      // Remove loading message
      _messages.removeLast();

      // Add AI response
      final aiMessage = Message(
        id: const Uuid().v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } catch (e) {
      // Remove loading message
      _messages.removeLast();

      // Add error message
      final errorMessage = Message(
        id: const Uuid().v4(),
        content: 'Sorry, I encountered an error. Please make sure you have added your Gemini API key to the .env file.'+e.toString(),
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _chatService.resetChat();
    _initializeChat();
    notifyListeners();
  }

  List<String> getSuggestions() {
    return _chatService.getSuggestionPrompts();
  }
}
