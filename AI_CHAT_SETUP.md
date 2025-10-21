# AI Chat Feature Setup Guide

## Overview
This document explains how to set up and use the AI chat feature powered by Google Gemini API in the Daily Habits app.

## Features
- **WhatsApp-style Chat UI**: Modern, intuitive chat interface
- **Google Gemini Integration**: Powered by Google's advanced AI model
- **Daily Habits Focus**: AI assistant specialized in habit formation and personal development
- **Contextual Responses**: Every message is automatically contextualized around daily habits
- **Suggestion Prompts**: Quick access to common habit-related questions
- **Floating Action Button**: Easy access from all main screens (Dashboard, Habits, Notifications, Profile)
- **Multilingual Support**: Available in English and Arabic

## Setup Instructions

### 1. Get Your Google Gemini API Key
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### 2. Configure the API Key and Model
1. Open the `.env` file in the root directory of the project
2. Replace `your_api_key_here` with your actual API key:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```
3. (Optional) Change the AI model if needed:
   ```
   GEMINI_MODEL=gemini-pro
   ```
   Available models: `gemini-pro`, `gemini-1.5-pro`, `gemini-1.5-flash`, `gemini-2.0-flash-exp`, etc.
4. Save the file

**Important**: Never commit your `.env` file to version control. It's already added to `.gitignore`.

### 3. Install Dependencies
Run the following command to install the required packages:
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

## Usage

### Accessing the Chat
- Look for the **robot icon** floating action button on any main screen
- Tap the button to open the AI chat interface

### Chat Features
1. **Send Messages**: Type your question about habits and tap the send button
2. **Suggestion Chips**: Tap on suggested prompts for quick questions
3. **Clear Chat**: Use the menu (three dots) to clear chat history
4. **Auto-scroll**: Chat automatically scrolls to the latest message

### Example Questions
- "How can I build a morning routine?"
- "Tips for staying consistent with habits"
- "How to track my daily habits effectively?"
- "What are some good habits to start?"
- "How to overcome procrastination?"

## Technical Details

### Architecture
```
lib/features/chat/
├── models/
│   └── message.dart          # Message data model
├── providers/
│   └── chat_provider.dart    # State management
├── services/
│   └── chat_service.dart     # Gemini API integration
├── screens/
│   └── chat_screen.dart      # Main chat UI
└── widgets/
    ├── message_bubble.dart   # Message display widget
    ├── chat_input.dart       # Input field widget
    └── suggestion_chips.dart # Suggestion prompts widget
```

### Key Components

#### ChatService
- Manages communication with Google Gemini API
- Implements system prompt for habit-focused responses
- Handles error cases and API failures

#### ChatProvider
- Manages chat state using Provider pattern
- Handles message history
- Coordinates between UI and service layer

#### Message Model
- Stores message content, timestamp, and sender info
- Supports loading states for AI responses

### Customization

#### Modify System Prompt
Edit `lib/features/chat/services/chat_service.dart`:
```dart
static const String _systemPrompt = '''
Your custom prompt here...
''';
```

#### Add More Suggestions
Edit the `getSuggestionPrompts()` method in `ChatService`:
```dart
List<String> getSuggestionPrompts() {
  return [
    'Your custom suggestion 1',
    'Your custom suggestion 2',
    // Add more...
  ];
}
```

#### Change AI Model
Simply update the `GEMINI_MODEL` value in your `.env` file:
```
GEMINI_MODEL=gemini-1.5-pro
```
Available options:
- `gemini-pro` - Standard model (default)
- `gemini-1.5-pro` - Enhanced capabilities
- `gemini-1.5-flash` - Faster responses
- `gemini-2.0-flash-exp` - Experimental latest model

No code changes required - the model is loaded from the environment variable.

## Troubleshooting

### "GEMINI_API_KEY not found" Error
- Make sure you've added your API key to the `.env` file
- Verify the `.env` file is in the root directory
- Restart the app after adding the API key

### API Rate Limits / Overloaded Errors
- Free tier has usage limits
- The service includes automatic retry logic with exponential backoff
- If you see "overloaded" errors frequently, try:
  - Using a different model (e.g., `gemini-1.5-flash` is faster)
  - Waiting a few moments between messages
  - Upgrading to a paid API plan for higher limits
- Monitor your usage in Google AI Studio

### Network Issues
- Ensure device has internet connection
- Check firewall settings
- Verify API key is valid and active

## Security Best Practices

1. **Never hardcode API keys** in source code
2. **Use environment variables** for sensitive data
3. **Add `.env` to `.gitignore`** to prevent accidental commits
4. **Rotate API keys** periodically
5. **Monitor API usage** to detect unauthorized access

## Future Enhancements

Potential improvements:
- [ ] Chat history persistence (save to local database)
- [ ] Voice input support
- [ ] Image sharing for habit progress
- [ ] Personalized recommendations based on user's habits
- [ ] Export chat conversations
- [ ] Multi-turn conversation context

## Support

For issues or questions:
1. Check the [Google Gemini API Documentation](https://ai.google.dev/docs)
2. Review Flutter integration guides
3. Contact the development team

## License

This feature is part of the Daily Habits app. All rights reserved.
