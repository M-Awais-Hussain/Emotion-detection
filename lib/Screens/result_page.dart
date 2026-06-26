import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'package:share_plus/share_plus.dart';
import '../../Services/emotion_api_service.dart';
import 'mood_improvement_dashboard.dart';
import 'main_camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/photo_data.dart';

class ResultPage extends StatefulWidget {
  final XFile imageFile;
  final int cameraIndex;

  const ResultPage({super.key, required this.imageFile, this.cameraIndex = 0});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String mood = 'detecting...';
  bool isLoading = true;

  // Enhanced emotion data with mood-appropriate colors
  final Map<String, Map<String, dynamic>> emotionData = {
    'happy': {
      'emoji': '😄',
      'color': Colors.amber.shade400, // Warm, bright golden yellow
      'message': 'Share your joy - it multiplies happiness!'
    },
    'sad': {
      'emoji': '😢',
      'color': Colors.blue.shade400, // Deeper blue for melancholy
      'message': 'Be gentle with yourself. Take a walk or call someone.'
    },
    'angry': {
      'emoji': '😠',
      'color': Colors.red.shade500, // Intense red for anger
      'message': 'Try 4-7-8 breathing: inhale 4, hold 7, exhale 8.'
    },
    'neutral': {
      'emoji': '😐',
      'color': Colors.blueGrey.shade300, // Calm, balanced grey-blue
      'message': 'Perfect balance. Great time for reflection.'
    },
    // Legacy emotions (kept for compatibility)
    'surprise': {
      'emoji': '😲',
      'color': Colors.orange.shade400, // Bright orange for surprise/shock
      'message': 'Your brain is learning! Embrace new experiences.'
    },
    'ahegao': {
      'emoji': '🤪',
      'color': Colors.pink.shade400, // Pink for ahegao
      'message': 'Having fun! Share your goofy side.'
    },
    'detecting...': {
      'emoji': '🔍',
      'color': Colors.grey.shade200,
      'message': 'Analyzing your expression...'
    },
    'none': {
      'emoji': '🙃',
      'color': Colors.white,
      'message': 'No face detected. Try another angle.'
    },
    'error': {
      'emoji': '❌',
      'color': Colors.grey.shade400,
      'message': 'Technical hiccup. Practice patience and try again.'
    },
  };

  @override
  void initState() {
    super.initState();
    _analyzeAndSave();
  }

  Future<void> _analyzeAndSave() async {
    try {
      debugPrint("----- [ResultPage] ----- Sending API request -----");
      final label = await EmotionApiService.getEmotion(widget.imageFile);
      debugPrint("----- [ResultPage] ----- Label received: $label -----");

      final detectedMood = label.toLowerCase().isEmpty ? "none" : label.toLowerCase();

      if (detectedMood != "none") {
        await _savePhotoData(detectedMood);
      }

      setState(() {
        mood = detectedMood;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('----- [ResultPage]  Error while analyzing mood: $e');
      setState(() {
        mood = 'error';
        isLoading = false;
      });
    }
  }

  Future<void> _savePhotoData(String detectedMood) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoData = PhotoData(
        path: widget.imageFile.path,
        mood: detectedMood,
        time: DateTime.now().toIso8601String(),
      );

      final existingData = prefs.getString('photo_data');
      List<PhotoData> photoList = existingData != null
          ? PhotoData.decodeList(existingData)
          : [];

      photoList.add(photoData);

      await prefs.setString('photo_data', PhotoData.encodeList(photoList));
      debugPrint('----- [ResultPage] Photo data saved successfully.');
    } catch (e) {
      debugPrint('----- [ResultPage] Error saving photo data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionInfo = emotionData[mood] ?? emotionData['none']!;

    return Scaffold(
      backgroundColor: emotionInfo['color'],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: emotionInfo['color'],
        title: const Text(
          'Your Mood Result',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: isLoading ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: buildImageFromXFile(
                            widget.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (isLoading)
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black38,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            SizedBox(height: 15),
                            Text(
                              'Analyzing your expression...',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Result container
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emotionInfo['emoji'],
                          style: TextStyle(fontSize: 50),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Mood',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                isLoading
                                    ? 'Detecting...'
                                    : (mood == "none" ? "Nice Try you Smarty" : mood[0].toUpperCase() + mood.substring(1)),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      emotionInfo['message'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => MainCamera(photoClicked: false, initialCameraIndex: widget.cameraIndex)),
                                  );
                                },
                                icon: Icon(Icons.camera_alt, size: 25,),
                                label: Text("Try Another Photo"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if(mood.toLowerCase() != "surprise")
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => MoodImprovementDashboard(initialMood: mood)),
                                      );
                                    },
                                    icon: Icon(Icons.emoji_emotions, size: 25,),
                                    label: Text("Boost Your Mood"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      disabledBackgroundColor: Colors.grey,
                                    ),
                                  ),
                                ),
                                ],
                              ),
                            ],
                          )
                      ],
                    ),

                  ],
                ),
              ),

              SizedBox(height: 20),

              // Tips or suggestions based on mood
              if (!isLoading)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Mood Tips 💡",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _getMoodTip(mood),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodTip(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return "Your joy is valuable! Savor this moment through mindful appreciation. Consider keeping a gratitude journal or engaging in activities that amplify positive emotions like creative expression, physical movement, or connecting with loved ones. Positive emotions broaden your awareness and build psychological resources.";

      case 'sad':
        return "Sadness is a natural human emotion that deserves acknowledgment. Practice self-compassion by treating yourself with the same kindness you'd show a good friend. Gentle movement, reaching out to supportive people, or engaging in meaningful activities can help. Remember: this feeling is temporary and valid.";

      case 'angry':
        return "Anger often signals unmet needs or boundaries. Use the STOP technique: Stop, Take a breath, Observe your thoughts and feelings, Proceed mindfully. Try the 4-7-8 breathing pattern or progressive muscle relaxation. Consider what this anger is telling you about your values or needs.";

      case 'surprise':
        return "Surprise activates your brain's learning centers! This emotional state enhances memory formation and cognitive flexibility. Take a moment to process this new information mindfully. Consider how this unexpected experience might offer opportunities for growth or new perspectives.";

      case 'neutral':
        return "Emotional neutrality can be a sign of psychological balance and present-moment awareness. This is an excellent time for reflection, planning, or engaging in mindfulness practices. Neutral states often provide clarity for decision-making and self-assessment.";

      case 'ahegao':
        return "You're showing a very expressive and fun side! Embrace your playful energy, maybe take some fun selfies, watch some anime, or listen to a fun playlist. Letting loose is a great way to relieve tension!";


      case 'error':
        return "Technical hiccups happen! This moment of uncertainty is actually an opportunity to practice patience and adaptability - key skills for emotional resilience. Take a deep breath and try again when you're ready.";

      default:
        return "Every emotion carries important information about your inner world. Take a moment to notice what you're feeling without judgment. Remember: all emotions are temporary and serve a purpose in your human experience. Practice self-compassion as you navigate your emotional landscape.";
    }
  }
}
