import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/photo_data.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class ProductivityAnalysisScreen extends StatefulWidget {
  const ProductivityAnalysisScreen({super.key});

  @override
  State<ProductivityAnalysisScreen> createState() => _ProductivityAnalysisScreenState();
}

class _ProductivityAnalysisScreenState extends State<ProductivityAnalysisScreen> {
  final TextEditingController _hoursController = TextEditingController();
  
  String _detectedEmotion = 'neutral';
  double _productivityScore = 0.0;
  bool _isLoading = true;

  // Emotion Score Mapping
  final Map<String, int> _emotionScores = {
    'happy': 100,
    'neutral': 80,
    'surprise': 75,
    'ahegao': 70,
    'sad': 40,
    'angry': 30,
  };

  final Map<String, String> _emotionEmojis = {
    'happy': '😊',
    'neutral': '😐',
    'surprise': '😲',
    'ahegao': '🤪',
    'sad': '😢',
    'angry': '😠',
  };

  @override
  void initState() {
    super.initState();
    _loadRecentEmotion();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentEmotion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoDataStr = prefs.getString('photo_data');
      
      if (photoDataStr != null) {
        final List<PhotoData> photoList = PhotoData.decodeList(photoDataStr);
        if (photoList.isNotEmpty) {
          // Get the most recent valid emotion
          for (int i = photoList.length - 1; i >= 0; i--) {
            String mood = photoList[i].mood.toLowerCase();
            if (_emotionScores.containsKey(mood)) {
              setState(() {
                _detectedEmotion = mood;
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading recent emotion: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _calculateProductivity();
    }
  }

  void _calculateProductivity() {
    double hours = double.tryParse(_hoursController.text) ?? 0.0;
    
    // Clamp hours between 0 and 24
    hours = max(0, min(24, hours));
    
    int emotionScore = _emotionScores[_detectedEmotion] ?? 80; // default to neutral if not found
    
    // Formula: (Emotion Score × 0.4) + ((Productive Hours / 8 × 100) × 0.6)
    double calculatedScore = (emotionScore * 0.4) + ((hours / 8.0 * 100.0) * 0.6);
    
    // Cap score at 100%
    calculatedScore = min(100.0, calculatedScore);
    
    setState(() {
      _productivityScore = calculatedScore;
    });
  }

  String _getProductivityLevel(double score) {
    if (score >= 90) return 'Outstanding';
    if (score >= 75) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    return 'Needs Improvement';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Outstanding':
        return Colors.green.shade600;
      case 'Excellent':
        return Colors.teal.shade500;
      case 'Good':
        return Colors.blue.shade500;
      case 'Average':
        return Colors.orange.shade500;
      default:
        return Colors.red.shade500;
    }
  }

  String _getSuggestion(String level, String emotion) {
    if (level == 'Outstanding' || level == 'Excellent') {
      return "You are highly productive today. Keep up this momentum and consider completing your high-priority tasks!";
    } else if (level == 'Good') {
      return "You're making steady progress. Try setting a clear goal for the next hour to push your productivity up a level.";
    } else if (level == 'Average') {
      if (emotion == 'sad' || emotion == 'angry') {
        return "It seems your mood might be affecting your focus today. Take a quick break to do a breathing exercise before continuing.";
      }
      return "You're doing okay, but there's room to improve. Consider removing distractions or trying the Pomodoro technique.";
    } else {
      if (emotion == 'sad' || emotion == 'angry') {
        return "Don't be too hard on yourself. When your mood is low, it's okay to prioritize self-care over productivity.";
      }
      return "Your productivity is quite low today. Try starting with one small, 5-minute task to build some momentum.";
    }
  }

  @override
  Widget build(BuildContext context) {
    String level = _getProductivityLevel(_productivityScore);
    Color levelColor = _getLevelColor(level);
    String suggestion = _getSuggestion(level, _detectedEmotion);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Productivity Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryMedium,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  const Text(
                    "Track Your Efficiency",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your emotion and productive hours combined to give you a personalized score.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Input Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primaryMedium.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.timer_outlined, color: AppTheme.primaryMedium),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Productive/Study Hours Today",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _hoursController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "E.g., 6.5",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              borderSide: const BorderSide(color: AppTheme.primaryMedium, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixText: "hours",
                          ),
                          onChanged: (val) => _calculateProductivity(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Emotion Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Detected Emotion:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(
                              "${_detectedEmotion[0].toUpperCase()}${_detectedEmotion.substring(1)} ",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryMedium),
                            ),
                            Text(
                              _emotionEmojis[_detectedEmotion] ?? '😐',
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Circular Progress & Level
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _productivityScore / 100,
                            strokeWidth: 14,
                            backgroundColor: Colors.grey.shade200,
                            color: levelColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${_productivityScore.toInt()}%",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: levelColor,
                              ),
                            ),
                            const Text(
                              "Score",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Suggestion Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [levelColor.withValues(alpha: 0.8), levelColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: levelColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Suggestion",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          suggestion,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
