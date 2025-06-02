import 'package:intl/intl.dart'; // 날짜 및 시간 포맷팅을 위해

class MealDiaryEntry {
  final String imagePath;
  final String time;
  final String menuName;
  final double intakeAmount; // ✅ int → double
  final DateTime createdAt;
  String notes;

  MealDiaryEntry({
    required this.imagePath,
    required this.time,
    required this.menuName,
    required this.intakeAmount,
    required this.notes,
    required this.createdAt,
  });

  factory MealDiaryEntry.fromJson(Map<String, dynamic> json) {
    final DateTime createdAt = DateTime.parse(json['createdAt'] as String);
    final String timeFormatted =
        DateFormat('a h:mm', 'ko_KR').format(createdAt);
    final String imageBaseUrl = 'http://152.67.196.3:4912/uploads/';
    final String fullImagePath =
        imageBaseUrl + (json['imgPath'] as String? ?? '');

    return MealDiaryEntry(
      imagePath: fullImagePath,
      time: timeFormatted,
      menuName: '메뉴 ID: ${json['id']?.toString() ?? '알 수 없음'}',
      intakeAmount: (json['intakeAmount'] as num?)?.toDouble() ?? 0.0, // ✅ 수정
      notes: json['diary'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
