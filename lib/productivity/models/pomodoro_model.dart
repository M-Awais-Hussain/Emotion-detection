import 'package:hive/hive.dart';

class PomodoroSession {
  String id;
  int durationMinutes;
  DateTime startTime;
  bool isCompleted;

  PomodoroSession({
    required this.id,
    required this.durationMinutes,
    required this.startTime,
    this.isCompleted = false,
  });
}

class PomodoroSessionAdapter extends TypeAdapter<PomodoroSession> {
  @override
  final int typeId = 4;

  @override
  PomodoroSession read(BinaryReader reader) {
    return PomodoroSession(
      id: reader.readString(),
      durationMinutes: reader.readInt(),
      startTime: reader.read() as DateTime,
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSession obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.durationMinutes);
    writer.write(obj.startTime);
    writer.writeBool(obj.isCompleted);
  }
}
