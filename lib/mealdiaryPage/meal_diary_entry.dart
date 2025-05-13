// lib/mealDiaryPage/meal_diary_entry.dart
class MealDiaryEntry {
  final String imageUrl;
  final String time; // e.g., "13:04"
  final String menuName;
  final String intakeAmount; // e.g., "600g"
  final String notes;
  final DateTime dateTime; // For potential sorting/grouping later

  MealDiaryEntry({
    required this.imageUrl,
    required this.time,
    required this.menuName,
    required this.intakeAmount,
    required this.notes,
    required this.dateTime,
  });
}