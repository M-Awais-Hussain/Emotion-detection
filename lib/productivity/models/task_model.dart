import 'package:hive/hive.dart';

class ProductivityTask {
  String id;
  String title;
  String description;
  DateTime? dueDate;
  String priority; // 'High', 'Medium', 'Low'
  bool isCompleted;
  DateTime createdAt;

  ProductivityTask({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ProductivityTaskAdapter extends TypeAdapter<ProductivityTask> {
  @override
  final int typeId = 1;

  @override
  ProductivityTask read(BinaryReader reader) {
    return ProductivityTask(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      dueDate: reader.read() as DateTime?,
      priority: reader.readString(),
      isCompleted: reader.readBool(),
      createdAt: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductivityTask obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.write(obj.dueDate);
    writer.writeString(obj.priority);
    writer.writeBool(obj.isCompleted);
    writer.write(obj.createdAt);
  }
}
