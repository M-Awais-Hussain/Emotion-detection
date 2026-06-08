import 'dart:convert';

class PhotoData {
  final String path;
  final String mood;
  final String time;

  PhotoData({
    required this.path,
    required this.mood,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'mood': mood,
    'time': time,
  };

  factory PhotoData.fromJson(Map<String, dynamic> json) => PhotoData(
    path: json['path'],
    mood: json['mood'],
    time: json['time'],
  );

  static List<PhotoData> decodeList(String jsonStr) =>
      (json.decode(jsonStr) as List)
          .map((item) => PhotoData.fromJson(item))
          .toList();

  static String encodeList(List<PhotoData> list) =>
      json.encode(list.map((e) => e.toJson()).toList());
}
