// lib/nutrientintakePage/services/nutrient_intake_data_service.dart
import 'dart:math';
import 'package:intl/intl.dart';
import '../nutrient_intake_constants.dart'; // Import constants

class NutrientIntakeDataService {
  late DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  int selectedNutrientIndex = 0;

  NutrientIntakeDataService() {
    _initializeDatesAndNutrient(); // 생성자에서 초기화
  }

  // 내부 초기화 메소드 (날짜 및 영양소 인덱스)
  void _initializeDatesAndNutrient() {
    final now = DateTime.now();
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: kWeeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: kWeeksOfDataAfterToday * 7));
    selectedNutrientIndex = 0; // 첫 번째 영양소로 초기화
  }

  // Public 메소드: 날짜를 현재 주로, 영양소를 첫 번째로 리셋
  void resetToCurrentWeekAndDefaultNutrient() {
    _initializeDatesAndNutrient();
  }

  List<Map<String, dynamic>> getCurrentNutrientWeekData() {
    String selectedNutrient = kNutrientKeys[selectedNutrientIndex];
    return _generateSimulatedNutrientData(selectedNutrient, currentWeekStartDate);
  }

  List<Map<String, dynamic>> _generateSimulatedNutrientData(String nutrient, DateTime startDate) {
    final seed = nutrient.hashCode ^ startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final random = Random(seed);
    List<Map<String, dynamic>> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add({
        'day': kDayNames[i], // kDayNames 사용
        'value': random.nextInt(71) + 30, // 30 ~ 100
      });
    }
    return weekData;
  }

  String formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    String formatWithSuffix(DateTime date) {
      String day = DateFormat('d').format(date);
      String suffix = 'th';
      if (day.endsWith('1') && !day.endsWith('11')) {
        suffix = 'st';
      } else if (day.endsWith('2') && !day.endsWith('12')) {
        suffix = 'nd';
      } else if (day.endsWith('3') && !day.endsWith('13')) {
        suffix = 'rd';
      }
      return "${DateFormat('MMMM').format(date)} $day$suffix";
    }
    return "${formatWithSuffix(startDate)} ~ ${formatWithSuffix(endDate)}";
  }

  Map<String, dynamic> changeWeek(int weeksToAdd) {
    final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));
    String? snackBarMessage;
    bool dateActuallyChanged = false;

    if (targetStartDate.isBefore(oldestWeekStartDate)) {
      snackBarMessage = kErrorPreviousData;
    } else if (targetStartDate.isAfter(newestWeekStartDate)) {
      snackBarMessage = kErrorNextData;
    } else {
      currentWeekStartDate = targetStartDate;
      dateActuallyChanged = true;
    }
    return {
      'newDate': currentWeekStartDate,
      'snackBarMessage': snackBarMessage,
      'dateChanged': dateActuallyChanged,
    };
  }

  String getCurrentNutrientName() {
    return kNutrientKeys[selectedNutrientIndex];
  }

  void changeNutrient(int indexOffset) {
    selectedNutrientIndex = (selectedNutrientIndex + indexOffset + kNutrientKeys.length) % kNutrientKeys.length;
  }

  bool get canGoBack => currentWeekStartDate.isAfter(oldestWeekStartDate);
  bool get canGoForward => currentWeekStartDate.isBefore(newestWeekStartDate);

  static double calculateBarHeight(int value, double maxVisualBarHeight, int maxValueInPeriod) {
    if (value <= 0 || maxValueInPeriod <= 0 || maxVisualBarHeight <= 0) {
      return 0;
    }
    double calculatedHeight = (value / maxValueInPeriod.toDouble()) * maxVisualBarHeight;
    return max(0, calculatedHeight); // Prevent negative height
  }
}