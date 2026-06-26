import 'package:hive/hive.dart';

class ProductivityHabit {
  String id;
  String title;
  List<DateTime> completedDates; // To track daily completions and calculate streak
  DateTime createdAt;

  ProductivityHabit({
    required this.id,
    required this.title,
    List<DateTime>? completedDates,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();
        
  // Helper to check if completed today
  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((d) => 
      d.year == now.year && d.month == now.month && d.day == now.day);
  }
}

class ProductivityHabitAdapter extends TypeAdapter<ProductivityHabit> {
  @override
  final int typeId = 3;

  @override
  ProductivityHabit read(BinaryReader reader) {
    return ProductivityHabit(
      id: reader.readString(),
      title: reader.readString(),
      completedDates: (reader.readList()).cast<DateTime>(),
      createdAt: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductivityHabit obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeList(obj.completedDates);
    writer.write(obj.createdAt);
  }
}
