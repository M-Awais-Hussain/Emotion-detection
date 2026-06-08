import 'dart:convert';

/// Represents one study log entry combining mood and academic performance.
class StudySession {
  final DateTime date;
  final String mood;
  final double studyHours;
  final int productivity; // 0–100

  StudySession({
    required this.date,
    required this.mood,
    required this.studyHours,
    required this.productivity,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'studyHours': studyHours,
      'productivity': productivity,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      date: DateTime.parse(map['date'] as String),
      mood: (map['mood'] as String?) ?? 'neutral',
      studyHours: (map['studyHours'] as num).toDouble(),
      productivity: (map['productivity'] as num).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory StudySession.fromJson(String source) =>
      StudySession.fromMap(json.decode(source) as Map<String, dynamic>);
}

