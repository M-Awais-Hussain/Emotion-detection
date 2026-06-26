import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../models/productivity_models.dart';
import '../services/productivity_service.dart';
import 'package:uuid/uuid.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final ProductivityService _service = ProductivityService();
  
  static const int workDuration = 25 * 60; // 25 minutes
  static const int breakDuration = 5 * 60; // 5 minutes
  
  int _secondsRemaining = workDuration;
  bool _isRunning = false;
  bool _isWorkSession = true;
  Timer? _timer;
  DateTime? _sessionStartTime;

  void _startTimer() {
    if (_timer != null) return;
    
    _sessionStartTime ??= DateTime.now();
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _timer = null;
        _handleSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _secondsRemaining = _isWorkSession ? workDuration : breakDuration;
      _sessionStartTime = null;
    });
  }

  void _handleSessionComplete() async {
    setState(() {
      _isRunning = false;
    });

    if (_isWorkSession) {
      // Save pomodoro session
      final session = PomodoroSession(
        id: const Uuid().v4(),
        durationMinutes: 25,
        startTime: _sessionStartTime ?? DateTime.now(),
        isCompleted: true,
      );
      await _service.addPomodoroSession(session);
      
      // Switch to break
      _isWorkSession = false;
      _secondsRemaining = breakDuration;
    } else {
      // Switch to work
      _isWorkSession = true;
      _secondsRemaining = workDuration;
    }
    _sessionStartTime = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isWorkSession ? 'Focus Time' : 'Break Time',
              style: AppTheme.headingMedium.copyWith(
                color: _isWorkSession ? AppTheme.warning : AppTheme.success,
              ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _isWorkSession 
                        ? _secondsRemaining / workDuration
                        : _secondsRemaining / breakDuration,
                    strokeWidth: 12,
                    backgroundColor: AppTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isWorkSession ? AppTheme.warning : AppTheme.success,
                    ),
                  ),
                ),
                Text(
                  _timerText,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isRunning ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.primaryMedium,
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
                const SizedBox(width: AppTheme.spacingL),
                _buildControlButton(
                  icon: Icons.refresh,
                  color: AppTheme.textSecondary,
                  onPressed: _resetTimer,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Total Focus Today: ${_service.getTotalFocusMinutes()} mins',
              style: AppTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: AppTheme.buttonShadow,
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
