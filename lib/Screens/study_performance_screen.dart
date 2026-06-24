import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Services/study_tracker_service.dart';
import '../model/study_session.dart';
import '../theme/app_theme.dart';

class StudyPerformanceScreen extends StatefulWidget {
  const StudyPerformanceScreen({super.key});

  @override
  State<StudyPerformanceScreen> createState() => _StudyPerformanceScreenState();
}

class _StudyPerformanceScreenState extends State<StudyPerformanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hoursController = TextEditingController();

  String _selectedMood = 'happy';
  double _productivity = 0;

  StudyTrackerService? _service;
  List<StudySession> _sessions = [];
  bool _isLoading = true;

  // Mood weights for dynamic productivity calculation
  static const Map<String, double> _moodWeights = {
    'happy': 90,
    'surprise': 80,
    'neutral': 70,
    'fear': 50,
    'sad': 50,
    'disgust': 40,
    'angry': 30,
  };

  // Ideal study duration in hours
  static const double _idealStudyHours = 8.0;

  // Computed insights
  late Map<String, _MoodInsight> _insights;
  bool _hasSufficientData = false;

  @override
  void initState() {
    super.initState();
    _insights = {};
    _hoursController.addListener(_onInputChanged);
    _calculateProductivity();
    _initService();
  }

  Future<void> _initService() async {
    final service = await StudyTrackerService.create();
    final sessions = service.loadSessions();

    setState(() {
      _service = service;
      _sessions = sessions;
      _isLoading = false;
    });

    _recalculateInsights();
  }

  @override
  void dispose() {
    _hoursController.removeListener(_onInputChanged);
    _hoursController.dispose();
    super.dispose();
  }

  /// Recalculate productivity whenever study hours or mood changes.
  void _onInputChanged() {
    _calculateProductivity();
  }

  /// Dynamically calculate productivity from study hours and mood.
  ///
  /// Formula:
  ///   hourScore = min((studyHours / idealHours) * 100, 100)
  ///   moodScore = weight from _moodWeights
  ///   productivity = (hourScore * 0.6) + (moodScore * 0.4)
  void _calculateProductivity() {
    final hours = double.tryParse(_hoursController.text.trim()) ?? 0;
    final hourScore = (hours / _idealStudyHours * 100).clamp(0, 100).toDouble();
    final moodScore = _moodWeights[_selectedMood] ?? 70;
    final result = (hourScore * 0.6) + (moodScore * 0.4);
    setState(() {
      _productivity = result.roundToDouble();
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate() || _service == null) return;

    final hours = double.tryParse(_hoursController.text.trim()) ?? 0;
    if (hours <= 0) return;

    final session = StudySession(
      date: DateTime.now(),
      mood: _selectedMood.toLowerCase(),
      studyHours: hours,
      productivity: _productivity.toInt(),
    );

    setState(() {
      _sessions.add(session);
    });

    await _service!.addSession(session);

    if (!mounted) return;

    _hoursController.clear();
    FocusScope.of(context).unfocus();

    _recalculateInsights();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study log saved')),
      );
    }
  }

  void _recalculateInsights() {
    if (_sessions.isEmpty) {
      setState(() {
        _hasSufficientData = false;
        _insights = {};
      });
      return;
    }

    // Require data that spans at least 7 distinct days.
    final uniqueDays = _sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day).toIso8601String())
        .toSet();

    final hasSevenDays = uniqueDays.length >= 7;

    final overallProductivity =
        _sessions.map((s) => s.productivity).fold<double>(0, (a, b) => a + b) /
            _sessions.length;

    final Map<String, List<StudySession>> byMood = {};
    for (final s in _sessions) {
      byMood.putIfAbsent(s.mood, () => []).add(s);
    }

    final Map<String, _MoodInsight> moodInsights = {};
    byMood.forEach((mood, list) {
      final avgHours =
          list.map((e) => e.studyHours).fold<double>(0, (a, b) => a + b) /
              list.length;
      final avgProd =
          list.map((e) => e.productivity).fold<double>(0, (a, b) => a + b) /
              list.length;

      final double deltaPercent = overallProductivity == 0
          ? 0.0
          : ((avgProd - overallProductivity) / overallProductivity) * 100.0;

      moodInsights[mood] = _MoodInsight(
        mood: mood,
        averageHours: avgHours,
        averageProductivity: avgProd,
        productivityDeltaPercent: deltaPercent,
      );
    });

    setState(() {
      _hasSufficientData = hasSevenDays;
      _insights = moodInsights;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Performance'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log today\'s study session',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildInputCard(),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Emotion × Performance insights',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildInsightsCard(),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Recent entries',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  if (_sessions.isEmpty)
                    Text(
                      'No study logs yet. Start by adding today\'s mood and study time.',
                      style: AppTheme.bodyMedium,
                    )
                  else
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        side:
                            const BorderSide(color: AppTheme.borderLight),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sessions.length.clamp(0, 10),
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppTheme.divider,
                        ),
                        itemBuilder: (context, index) {
                          final session =
                              _sessions.reversed.toList()[index];

                          final mood = session.mood;
                          final color = AppTheme.getEmotionColor(mood);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.insights,
                                color: color,
                              ),
                            ),
                            title: Text(
                              '${mood[0].toUpperCase()}${mood.substring(1)} • ${session.studyHours.toStringAsFixed(1)} hrs',
                              style: AppTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              '${formatter.format(session.date)}  •  Productivity ${session.productivity}%',
                              style: AppTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How do you feel?',
                style: AppTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              DropdownButtonFormField<String>(
                initialValue: _selectedMood,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'happy', child: Text('Happy')),
                  DropdownMenuItem(value: 'sad', child: Text('Sad')),
                  DropdownMenuItem(value: 'angry', child: Text('Angry')),
                  DropdownMenuItem(value: 'fear', child: Text('Fear')),
                  DropdownMenuItem(value: 'disgust', child: Text('Disgust')),
                  DropdownMenuItem(value: 'surprise', child: Text('Surprise')),
                  DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedMood = value;
                  });
                  _calculateProductivity();
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Study hours today',
                style: AppTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              TextFormField(
                controller: _hoursController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 3.5',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter study hours';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Productivity level',
                style: AppTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _productivity / 100,
                        minHeight: 12,
                        backgroundColor: AppTheme.borderLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${_productivity.round()}%',
                      textAlign: TextAlign.right,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  child: const Text('Save today\'s log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    if (!_hasSufficientData || _insights.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_clock, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  'After you log at least 7 days of study sessions, you\'ll see insights like:\n\n'
                  '• "When you are Happy → You study 3.5 hrs avg"\n'
                  '• "When you are Sad → Productivity drops 40%"',
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final moods = _insights.values.toList()
      ..sort((a, b) => a.mood.compareTo(b.mood));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ).borderRadius,
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your logs:',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: AppTheme.spacingS),
            ...moods.map((insight) {
              final moodName =
                  '${insight.mood[0].toUpperCase()}${insight.mood.substring(1)}';
              final color = AppTheme.getEmotionColor(insight.mood);

              final hoursText =
                  'When you are $moodName → You study ${insight.averageHours.toStringAsFixed(1)} hrs on average.';

              String productivityText;
              final delta = insight.productivityDeltaPercent;
              if (delta.abs() < 5) {
                productivityText =
                    'Your productivity stays close to your overall average.';
              } else if (delta > 0) {
                productivityText =
                    'Productivity rises by ${delta.round().abs()}% compared to your overall average.';
              } else {
                productivityText =
                    'Productivity drops by ${delta.round().abs()}% compared to your overall average.';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hoursText,
                            style: AppTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            productivityText,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MoodInsight {
  final String mood;
  final double averageHours;
  final double averageProductivity;
  final double productivityDeltaPercent;

  _MoodInsight({
    required this.mood,
    required this.averageHours,
    required this.averageProductivity,
    required this.productivityDeltaPercent,
  });
}

