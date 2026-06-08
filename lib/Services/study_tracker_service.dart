import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/study_session.dart';

/// Manages saving and loading study sessions locally using SharedPreferences.
class StudyTrackerService {
  static const String _storageKey = 'study_sessions_v1';

  final SharedPreferences _prefs;

  StudyTrackerService._(this._prefs);

  static Future<StudyTrackerService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StudyTrackerService._(prefs);
  }

  List<StudySession> loadSessions() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => StudySession.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If anything goes wrong with parsing, reset storage gracefully.
      return [];
    }
  }

  Future<void> _saveSessions(List<StudySession> sessions) async {
    final list = sessions.map((e) => e.toMap()).toList();
    await _prefs.setString(_storageKey, json.encode(list));
  }

  Future<void> addSession(StudySession session) async {
    final sessions = loadSessions();
    sessions.add(session);
    await _saveSessions(sessions);
  }
}

