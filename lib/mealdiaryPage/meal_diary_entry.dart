import 'package:intl/intl.dart';

class MealDiaryEntry {
  final String imagePath;
  final String time;
  final String menuName;
  final int intakeAmount;
  var notes;

  MealDiaryEntry({
    required this.imagePath,
    required this.time,
    required this.menuName,
    required this.intakeAmount,
    required this.notes,
  });

  factory MealDiaryEntry.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt']);
    final timeFormatted = DateFormat('a h:mm', 'ko_KR').format(createdAt);

    return MealDiaryEntry(
      imagePath: 'http://152.67.196.3:4912/uploads/${json['imgPath']}',
      time: timeFormatted,
      menuName: '메뉴 ID: ${json['id']}',
      intakeAmount: json['intakeAmount'] ?? 0,
      notes: json['diary'] ?? '',
    );
  }
}
