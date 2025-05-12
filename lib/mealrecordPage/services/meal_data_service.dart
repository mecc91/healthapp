// lib/mealrecordPage/services/meal_data_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Data class for a meal record.
class MealRecordData {
  final String? imagePath;
  final String menuName;
  final String? serving;
  final String? mealTime;
  final String timestamp;
  final Map<String, double>? nutrients; // Optional: For future nutritional info

  MealRecordData({
    this.imagePath,
    required this.menuName,
    this.serving,
    this.mealTime,
    required this.timestamp,
    this.nutrients,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'menuName': menuName,
      'serving': serving,
      'time': mealTime, // Keep 'time' for consistency with original code's JSON key
      'timestamp': timestamp,
      'nutrients': nutrients, // Will be null if not provided
    };
  }
}

class MealDataService {
  /// Saves the meal record to a local JSON file.
  /// Returns the path of the saved file.
  Future<String> saveMealRecord(MealRecordData mealRecord) async {
    final String jsonData = jsonEncode(mealRecord.toJson());
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      // Using timestamp for unique file name to avoid overwriting
      final fileName = 'meal_data_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('$path/$fileName');
      await file.writeAsString(jsonData);
      print('Meal record saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error saving meal record: $e');
      // Consider re-throwing a custom exception or returning a status object
      throw Exception('Failed to save meal record: $e');
    }
  }

  // Optional: Method to load meal records (not implemented here)
  // Future<List<MealRecordData>> loadMealRecords() async {
  //   // ... logic to find and parse JSON files ...
  //   return [];
  // }

  // Optional: Method to delete a meal record (not implemented here)
  // Future<void> deleteMealRecord(String filePath) async {
  //   try {
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       await file.delete();
  //       print('Meal record deleted: $filePath');
  //     }
  //   } catch (e) {
  //     print('Error deleting meal record: $e');
  //     throw Exception('Failed to delete meal record: $e');
  //   }
  // }
}