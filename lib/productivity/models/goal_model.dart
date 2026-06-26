import 'package:hive/hive.dart';

class ProductivityGoal {
  String id;
  String title;
  String description;
  String type; // 'Short-Term', 'Long-Term'
  double progressPercentage; // 0.0 to 1.0
  DateTime? targetDate;
  bool isCompleted;
  DateTime createdAt;

  ProductivityGoal({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    this.progressPercentage = 0.0,
    this.targetDate,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ProductivityGoalAdapter extends TypeAdapter<ProductivityGoal> {
  @override
  final int typeId = 2;

  @override
  ProductivityGoal read(BinaryReader reader) {
    return ProductivityGoal(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      type: reader.readString(),
      progressPercentage: reader.readDouble(),
      targetDate: reader.read() as DateTime?,
      isCompleted: reader.readBool(),
      createdAt: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductivityGoal obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.type);
    writer.writeDouble(obj.progressPercentage);
    writer.write(obj.targetDate);
    writer.writeBool(obj.isCompleted);
    writer.write(obj.createdAt);
  }
}
