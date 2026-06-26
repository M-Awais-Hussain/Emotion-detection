import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/MoodBoosterWidgets/neutral/to_do_list.dart';
import '../widgets/MoodBoosterWidgets/sad/letter_yourself_widget.dart';
import '../Services/native_camera_launcher.dart';
import '../widgets/MoodBoosterWidgets/sad/happy_music_playlist.dart';
import '../Widgets/MoodBoosterWidgets/sad/happy_youtube_playlist.dart';
import '../widgets/MoodBoosterWidgets/angry/anger_journal_widget.dart';
import '../widgets/MoodBoosterWidgets/angry/breathing_exercise_widget.dart';
import '../widgets/MoodBoosterWidgets/angry/physical_activities_screen.dart';
import '../widgets/MoodBoosterWidgets/neutral/what_went_well.dart';
import '../widgets/MoodBoosterWidgets/sad/gratitude_journal_widget.dart';

import '../widgets/MoodBoosterWidgets/mood_response_widget.dart';

/// Main dashboard
class MoodImprovementDashboard extends StatefulWidget {
  final String initialMood;

  const MoodImprovementDashboard({
    super.key,
    required this.initialMood,
  });

  @override
  MoodImprovementDashboardState createState() => MoodImprovementDashboardState();
}

class MoodImprovementDashboardState extends State<MoodImprovementDashboard> with SingleTickerProviderStateMixin {
  late String _currentMood;
  late TabController _tabController;
  final int _tabCount = 3;
  int _currentTabIndex = 0;

  final Map<String, ColorScheme> moodColorSchemes = {
    'sad': ColorScheme(
      primary: Color(0xFF5DADE2),
      secondary: Color(0xFFF7DC6F),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'angry': ColorScheme(
      primary: Color(0xFFE74C3C),
      secondary: Color(0xFF58D68D),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'ahegao': ColorScheme(
      primary: Color(0xFFE91E63), // Pink
      secondary: Color(0xFFF8BBD0),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'surprise': ColorScheme(
      primary: Color(0xFFEC407A), // Pink
      secondary: Color(0xFFF8BBD0),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'happy': ColorScheme(
      primary: Color(0xFF2ECC71),
      secondary: Color(0xFFF39C12),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'neutral': ColorScheme(
      primary: Color(0xFF78909C),
      secondary: Color(0xFFB0BEC5),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  };

  @override
  void initState() {
    super.initState();
    _currentMood = widget.initialMood.toLowerCase();
    _tabController = TabController(length: _tabCount, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeMood(String newMood) {
    setState(() {
      _currentMood = newMood.toLowerCase();
      _tabController.index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = moodColorSchemes[_currentMood] ?? moodColorSchemes['happy']!;
    final List<Widget> tabContents = [
      _buildActivitiesTab(colorScheme),
      _buildActivity1Tab(colorScheme),
      _buildActivity2Tab(colorScheme),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Improvement Dashboard"),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [

                    // Filter Chips
                    Text(
                      'Current Mood:',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 12),
                    _MoodChip(mood: 'sad', currentMood: _currentMood, onChanged: _changeMood),
                    _MoodChip(mood: 'neutral', currentMood: _currentMood, onChanged: _changeMood),
                    _MoodChip(mood: 'happy', currentMood: _currentMood, onChanged: _changeMood),
                    _MoodChip(mood: 'angry', currentMood: _currentMood, onChanged: _changeMood),
                    _MoodChip(mood: 'ahegao', currentMood: _currentMood, onChanged: _changeMood),
                    _MoodChip(mood: 'surprise', currentMood: _currentMood, onChanged: _changeMood),
                  ],
                ),
              ),
            ),

            //Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MoodResponseWidget(
                        detectedMood: _currentMood,
                      ),
                      SizedBox(height: 24),

                      //Tab Option
                      if(_currentMood!='happy')
                        TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: EdgeInsets.symmetric(horizontal: 20),
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
                          tabs: const [
                            Tab(text: 'Activities'),
                            Tab(text: 'Activity 1'),
                            Tab(text: 'Activity 2'),
                          ],
                        ),
                      SizedBox(
                        // height: _currentMood=="neutral"? 500 : null,
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: tabContents[_currentTabIndex],
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

  Widget _buildActivitiesTab(ColorScheme colorScheme) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16),
      children: [
        if (_currentMood == 'sad') ...[
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.newspaper_outlined,
            title: 'Control Yourself',
            description: 'Write down Letter for you expressing Kindness.',
            onTap: () => _tabController.animateTo(1),
          ),
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.import_contacts,
            title: 'Gratitude Journal',
            description: 'Write down things you appreciate.',
            onTap: () => _tabController.animateTo(2),
          ),
          _ActivityCard(
              colorScheme: colorScheme,
              icon: Icons.music_note,
              title: 'Uplifting Music',
              description: 'Listen to motivating songs.',
              onTap: () => showHappyMusicPlaylistPopup(context)
          ),
          _ActivityCard(
              colorScheme: colorScheme,
              icon: Icons.play_circle_outline,
              title: 'Comedy Videos',
              description: 'Watch some comedy videos to boost your mood.',
              onTap: () => showHappyYoutubePlaylistPopup(context)
          ),
        ]
        else if (_currentMood == 'angry') ...[
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.air,
            title: 'Breathing Exercise',
            description: 'Regulate emotions through breathing.',
            onTap: () => _tabController.animateTo(1),
          ),
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.calculate,
            title: 'Anger Tracker',
            description: 'Regulate your Anger & find the cause.',
            onTap: () => _tabController.animateTo(2),
          ),
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.directions_run,
            title: 'Physical Activity',
            description: 'Release energy through movement.',
            onTap: () => showAngerExercisesDialog(context)
          ),
        ]
        else if (_currentMood == 'ahegao') ...[
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.camera_alt,
            title: 'Take a Selfie',
            description: 'Capture your fun goofy moment!',
            onTap: () {
              NativeCameraLauncher.openNativeCamera();
            },
          ),
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.music_note,
            title: 'Fun Playlist',
            description: 'Listen to upbeat and fun songs.',
            onTap: () => showHappyMusicPlaylistPopup(context)
          ),
        ]
        else if (_currentMood == 'surprise') ...[
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.self_improvement,
            title: 'Centering Pose',
            description: 'Find equilibrium after unexpected events.',
            onTap: () => _tabController.animateTo(1),
          ),
        ]
        else if (_currentMood == 'neutral')...[
              _ActivityCard(
                colorScheme: colorScheme,
                icon: Icons.view_list,
                title: 'List your TodDo\'s',
                description: 'Best time to do this is when you are Rational',
                onTap: () => _tabController.animateTo(1),
              ),
              _ActivityCard(
                colorScheme: colorScheme,
                icon: Icons.flag,
                title: 'Set Small Goals',
                description: 'Neutral moods are great for rational decision-making.',
                onTap: () => _tabController.animateTo(2),
              ),
        ]
        else...[
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.emoji_emotions,
            title: 'Positive Reinforcement',
            description: 'Record joyful experiences.',
            onTap: () {
              NativeCameraLauncher.openNativeCamera();
            },
            // onTap: () => _tabController.animateTo(2),
          ),
          _ActivityCard(
            colorScheme: colorScheme,
            icon: Icons.share,
            title: 'Share Your Joy',
            description: 'Spread your happiness around.',
            onTap: () async {
              await Share.shareWithResult("I'm feeling really Happy😃😄 today!, let's meet up");
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActivity1Tab(ColorScheme colorScheme) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16),
      children: [
        if (_currentMood == 'sad')
          LetterYourself()
        else if (_currentMood == 'angry')
          BreathingExerciseWidget(colorScheme: colorScheme,)
        else if (_currentMood == 'neutral')
          ToDoList()
        else if (_currentMood == 'happy')
          LetterYourself()
        else if (_currentMood == 'ahegao')
          ToDoList()
        else if (_currentMood == 'surprise')
          ToDoList(),
      ],
    );
  }

  Widget _buildActivity2Tab(ColorScheme colorScheme) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16),
      children: [
        if (_currentMood == 'sad')
          GratitudeJournalWidget(colorScheme: colorScheme)
        else if (_currentMood == 'angry')
          AngerJournalWidget()
        else if (_currentMood == 'neutral')
            WhatWentWellActivity()
        else if (_currentMood == 'happy')
          LetterYourself()
        else if (_currentMood == 'ahegao')
          WhatWentWellActivity()
        else if (_currentMood == 'surprise')
          WhatWentWellActivity(),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String mood;
  final String currentMood;
  final ValueChanged<String> onChanged;

  const _MoodChip({
    required this.mood,
    required this.currentMood,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMood == mood;
    final color = _getMoodColor(mood);

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          mood[0].toUpperCase() + mood.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.white : color,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onChanged(mood),
        backgroundColor: color.withValues(alpha: 0.1),
        selectedColor: color,
        shape: StadiumBorder(side: BorderSide(color: color)),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'sad': return Colors.blue;
      case 'angry': return Colors.red;
      case 'ahegao': return Colors.pink;
      case 'surprise': return Colors.pink;
      case 'happy': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

class _ActivityCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _ActivityCard({
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary)),
                    SizedBox(height: 4),
                    Text(description,
                        style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
