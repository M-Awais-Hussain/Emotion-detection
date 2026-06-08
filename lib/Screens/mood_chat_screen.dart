import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class MoodChatScreen extends StatefulWidget {
  const MoodChatScreen({super.key});

  @override
  MoodChatScreenState createState() => MoodChatScreenState();
}

class MoodChatScreenState extends State<MoodChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // App theme colors
  static const Color primaryColor = Color.fromARGB(255, 0, 31, 84);
  static const Color accentColor = Color(0xFF00BCD4);

  // Gemini API Configuration
  // Chat requests should go through the backend so the API key
  // is never exposed in the client.
  final String geminiApiKey = "";
  
  // Use backend API for all chat requests
  final bool useBackendApi = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load chat history from SharedPreferences
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? messagesString = prefs.getString('chat_history');
      if (messagesString != null && messagesString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(messagesString);
        setState(() {
          _messages.clear();
          _messages.addAll(jsonList.map((e) => Map<String, String>.from(e)));
        });
        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_history', jsonEncode(_messages));
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  void clearChatHistory() {
    setState(() {
      _messages.clear();
    });
    _saveMessages();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Send message to AI
  Future<void> _sendMessage({String detectedEmotion = "neutral"}) async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    debugPrint('=== Sending message: "$userMessage" with emotion: $detectedEmotion ===');

    // Add user message to UI
    setState(() {
      _messages.add({
        'role': 'user',
        'text': userMessage,
        'time': DateTime.now().toIso8601String()
      });
      _isLoading = true;
      _controller.clear();
    });
    await _saveMessages();
    _scrollToBottom();

    try {
      // Detect emotion from message
      String emotion = _detectEmotionFromMessage(userMessage, detectedEmotion);
      debugPrint('Detected emotion: $emotion');
      
      String aiReply = await _getAIResponse(userMessage, emotion);
      debugPrint('Got AI reply: ${aiReply.substring(0, aiReply.length > 100 ? 100 : aiReply.length)}...');
      
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': aiReply,
          'time': DateTime.now().toIso8601String()
        });
      });
      await _saveMessages();
    } catch (e) {
      debugPrint('Error in _sendMessage: $e');
      String errorMessage = _getErrorMessage(e);
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': errorMessage,
          'time': DateTime.now().toIso8601String()
        });
      });
      await _saveMessages();
    } finally {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  // Get AI response using Gemini API
  Future<String> _getAIResponse(String message, String emotion) async {
    // Try backend first if enabled
    if (useBackendApi) {
      try {
        debugPrint('Attempting to reach backend at: ${ApiConfig.chatUrl}');
        final response = await http.post(
          Uri.parse(ApiConfig.chatUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "message": message,
            "conversation_history": _getFilteredHistory(),
            "detected_emotion": emotion,
          }),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          debugPrint('Backend API response received successfully');
          return data["response"] ?? _getFallbackResponse(emotion);
        } else {
          debugPrint('Backend chat error: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        debugPrint('⚠️ Backend API failed: $e');
        debugPrint('Backend URL: ${ApiConfig.chatUrl}');
       debugPrint('💡 Make sure the backend server is running. Start it with: cd backend && ./start_server.bat');
      }
    }

    // If backend is disabled or failed, return a safe fallback
    return _getFallbackResponse(emotion);
  }

  
  // Detect emotion from user message - supports all emotions in the project
  String _detectEmotionFromMessage(String message, String currentEmotion) {
    final lowerMessage = message.toLowerCase();
    
    // Happy emotions
    if (lowerMessage.contains('happy') || 
        lowerMessage.contains('joy') || 
        lowerMessage.contains('glad') ||
        lowerMessage.contains('cheerful') ||
        lowerMessage.contains('excited') ||
        lowerMessage.contains('elated') ||
        lowerMessage.contains('delighted')) {
      return 'happy';
    }
    
    // Surprise emotions
    if (lowerMessage.contains('surprise') ||
        lowerMessage.contains('surprised') ||
        lowerMessage.contains('shock') ||
        lowerMessage.contains('amazed')) {
      return 'surprise';
    }
    
    // Sad emotions
    if (lowerMessage.contains('sad') || 
        lowerMessage.contains('depressed') || 
        lowerMessage.contains('down') ||
        lowerMessage.contains('unhappy') ||
        lowerMessage.contains('melancholy') ||
        lowerMessage.contains('blue') ||
        lowerMessage.contains('upset')) {
      return 'sad';
    }
    
    // Angry emotions
    if (lowerMessage.contains('angry') || 
        lowerMessage.contains('mad') || 
        lowerMessage.contains('furious') ||
        lowerMessage.contains('rage') ||
        lowerMessage.contains('annoyed') ||
        lowerMessage.contains('irritated') ||
        lowerMessage.contains('frustrated') ||
        lowerMessage.contains('hate')) {
      return 'angry';
    }

    // Disgust emotions
    if (lowerMessage.contains('disgust') ||
        lowerMessage.contains('disgusted') ||
        lowerMessage.contains('contempt') ||
        lowerMessage.contains('repulsed') ||
        lowerMessage.contains('gross')) {
      return 'disgust';
    }
    
    // Fear emotions
    if (lowerMessage.contains('anxious') || 
        lowerMessage.contains('worried') || 
        lowerMessage.contains('nervous') ||
        lowerMessage.contains('anxiety') ||
        lowerMessage.contains('fear') ||
        lowerMessage.contains('afraid') ||
        lowerMessage.contains('scared') ||
        lowerMessage.contains('panic') ||
        lowerMessage.contains('stressed') ||
        lowerMessage.contains('stress') ||
        lowerMessage.contains('overwhelmed') ||
        lowerMessage.contains('tense')) {
      return 'fear';
    }
    
    // Neutral
    if (lowerMessage.contains('neutral') || 
        lowerMessage.contains('calm') || 
        lowerMessage.contains('fine') ||
        lowerMessage.contains('okay') ||
        lowerMessage.contains('ok') ||
        lowerMessage.contains('alright')) {
      return 'neutral';
    }
    
    return currentEmotion;
  }


  // Get filtered conversation history
  List<Map<String, String>> _getFilteredHistory() {
    return _messages
        .where((m) =>
            m['text'] != null &&
            m['text']!.isNotEmpty &&
            !m['text']!.startsWith('Error:') &&
            !m['text']!.contains('trouble connecting') &&
            !m['text']!.contains('having trouble'))
        .map((m) => {
              'role': m['role']!,
              'text': m['text']!,
            })
        .toList();
  }

  // Get fallback response based on emotion - supports all emotions in the project
  String _getFallbackResponse(String emotion) {
    final emotionLower = emotion.toLowerCase();
    
    // Map related emotions to main categories
    String mappedEmotion = _mapEmotionToCategory(emotionLower);
    
    final responses = {
      "happy": "Great to hear you're feeling good! 😄 Keep up the positive energy. Is there anything specific you'd like to talk about or work on? I'm here to support you. 💙",
      
      "sad": "I understand you're feeling down. 😢 Remember, it's okay to feel this way. Would you like to try some mood-boosting activities? I'm here to support you through this. 💙",
      
      "angry": "I can see you're feeling frustrated or angry. 😠 That's completely valid. Let's work through this together. Taking deep breaths can help - try breathing in for 4 counts, holding for 4, and breathing out for 4. Would you like to try a breathing exercise or talk about what's making you feel this way? 💙",
      
      "neutral": "I'm here to listen and support you. 😐 How can I help you today? Feel free to share what's on your mind. This is a great time for reflection and self-care. 💙",
      
      // Additional emotions
      "surprise": "Surprise! 😲 Your brain is learning and adapting. This unexpected moment can be an opportunity for growth. Embrace new experiences and see where they lead you. 💙",
      
      "fear": "I understand you're feeling afraid or scared. 😨 Fear is a natural response that keeps us safe. Try grounding techniques: name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste. I'm here to help you feel more secure. 💙",
      
      "disgust": "I sense you're feeling disgusted or repulsed. 🤢 This feeling often signals something doesn't align with your values. Focus on what matters to you and shift your attention to something positive. I'm here to help. 💙",
      
      "contempt": "I notice you might be feeling contempt or disdain. 😏 This can create distance in relationships. Try practicing empathy - consider the other person's perspective. Everyone has their struggles. Let's work on understanding together. 💙",
      
      "stressed": "You're feeling stressed or overwhelmed. 😵 That's completely understandable. Let's prioritize what matters most right now. Take intentional breaks, practice deep breathing, and remember to be kind to yourself. I'm here to support you. 💙",
    };
    
    // Return emotion-specific response or neutral
    String response = responses[mappedEmotion] ?? responses["neutral"]!;
    
    // Debug logging
    debugPrint('Using fallback response for emotion: $emotion (mapped to: $mappedEmotion)');
    
    return response;
  }
  
  // Map all emotions to main categories (matching project's emotion mapping)
  String _mapEmotionToCategory(String emotion) {
    final emotionLower = emotion.toLowerCase();
    
    // Direct matches
    if (['happy', 'sad', 'angry', 'fear', 'disgust', 'surprise', 'neutral'].contains(emotionLower)) {
      return emotionLower;
    }
    
    // Map related emotions
    if (emotionLower == 'contempt') {
      return 'disgust';
    }
    if (emotionLower == 'anxious' || emotionLower == 'stressed') {
      return 'fear';
    }
    
    // Default to neutral for unknown emotions
    return 'neutral';
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('api key') || 
        errorStr.contains('401') || 
        errorStr.contains('403')) {
      return "There's an issue with the API configuration. The chat feature needs a valid API key. Please contact support. 💙";
    } else if (errorStr.contains('rate limit') || errorStr.contains('429')) {
      return "I'm receiving too many requests right now. Please wait a moment and try again. 💙";
    } else if (errorStr.contains('timeout') || 
               errorStr.contains('connection') ||
               errorStr.contains('internet')) {
      return "I'm having trouble connecting to the internet. Please check your connection and try again. 💙";
    } else {
      return "I'm sorry, I'm having trouble connecting right now. Please try again in a moment. 💙";
    }
  }

  // Format timestamp for chat bubble
  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}, ${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Area - Chat Bubbles
            Positioned.fill(
              bottom: isKeyboardOpen ? 75 : 150,
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildMessageBubble(msg, isUser, index);
                      },
                    ),
            ),

            // Typing indicator
            if (_isLoading)
              Positioned(
                left: 16,
                right: 16,
                bottom: isKeyboardOpen ? 75 : 150,
                child: _buildTypingIndicator(),
              ),

            // Chat TextField
            Positioned(
              left: 16,
              right: 16,
              bottom: isKeyboardOpen ? 5 : 83,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: "Tell me how you feel...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.mood_outlined,
                                color: Colors.grey.shade400,
                                size: 22,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: _isLoading ? null : () => _sendMessage(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _isLoading
                                    ? Icons.hourglass_empty
                                    : Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to your Mood Booster!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'I\'m here to listen, support, and help boost your mood. Share what\'s on your mind and let\'s chat!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg, bool isUser, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? primaryColor.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border:
                        isUser ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(left: 8, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 40,
              right: isUser ? 40 : 0,
              top: 4,
            ),
            child: Text(
              _formatTime(msg['time']!),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animationValue = ((value + delay) % 1.0);
        final opacity = animationValue < 0.5 
            ? animationValue * 2 
            : 2 - (animationValue * 2);
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade400.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted && _isLoading) {
          setState(() {});
        }
      },
    );
  }
}
