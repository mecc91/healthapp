// lib/mealDiaryPage/meal_diary_entry.dart
class MealDiaryEntry {
  final String imagePath;
  final String time;
  final String menuName;
  final int intakeAmount;
  final String notes;

  MealDiaryEntry({
    required this.imagePath,
    required this.time,
    required this.menuName,
    required this.intakeAmount,
    required this.notes,
  });

  factory MealDiaryEntry.fromJson(Map<String, dynamic> json) {
    return MealDiaryEntry(
      imagePath: json['imgPath'],
      time: json['time'] ?? '시간 정보 없음',
      menuName: json['menuName'] ?? '메뉴 없음',
      intakeAmount: json['intakeAmount'] ?? 0,
      notes: json['diary'] ?? '',
    );
  }
}
