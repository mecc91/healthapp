// lib/nutrientintakePage/services/nutrient_intake_data_service.dart
import 'dart:math';
import 'package:flutter/material.dart'; // Required for DateUtils
import 'package:intl/intl.dart';
import '../nutrient_intake_constants.dart'; // Import constants

class NutrientIntakeDataService {
  late DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  int selectedNutrientIndex = 0;

  // --- Monthly View State ---
  late DateTime currentSelectedMonth;
  late DateTime oldestMonth;
  late DateTime newestMonth;
  // --- End Monthly View State ---

  NutrientIntakeDataService() {
    _initializeDatesAndNutrient(); // 생성자에서 초기화
  }

  // 내부 초기화 메소드 (날짜 및 영양소 인덱스)
  void _initializeDatesAndNutrient() {
    final now = DateTime.now();

    // Weekly
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: kWeeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: kWeeksOfDataAfterToday * 7));

    // Monthly
    currentSelectedMonth = DateTime(now.year, now.month, 1);
    _initializeMonthBoundaries();

    selectedNutrientIndex = 0; // 첫 번째 영양소로 초기화
  }

  void _initializeMonthBoundaries() {
    final now = DateTime.now();
    // 월간 보기: 현재 달로부터 과거 2년, 미래 1년까지의 데이터를 시뮬레이션한다고 가정
    oldestMonth = DateTime(now.year - 2, 1, 1);
    newestMonth = DateTime(now.year + 1, 12, 1);
  }

  // Public 메소드: 날짜를 현재 주로, 영양소를 첫 번째로 리셋
  void resetToCurrentWeekAndDefaultNutrient() {
    _initializeDatesAndNutrient();
  }

  List<Map<String, dynamic>> getCurrentNutrientWeekData() {
    String selectedNutrient = kNutrientKeys[selectedNutrientIndex];
    return _generateSimulatedNutrientDataForWeek(selectedNutrient, currentWeekStartDate);
  }

  List<Map<String, dynamic>> _generateSimulatedNutrientDataForWeek(String nutrient, DateTime startDate) {
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

  // --- Monthly Data Methods ---
  Map<int, int> getNutrientDataForMonth(DateTime month, String nutrientKey) {
    final random = Random(month.year * 100 + month.month + nutrientKey.hashCode);
    Map<int, int> nutrientValues = {};
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    for (int day = 1; day <= daysInMonth; day++) {
      // Simulate some days having data and some not
      if (random.nextDouble() > 0.3) { // 70% chance of having data
        // Simulate nutrient values (e.g., grams or mg depending on nutrient)
        // For this example, let's assume a general range like 50-150 for visualization
        nutrientValues[day] = random.nextInt(101) + 50; // 50 - 150
      }
    }
    return nutrientValues;
  }

  double calculateAverageMonthlyNutrientIntake(Map<int, int> monthlyData) {
    if (monthlyData.isEmpty) return 0.0;
    final totalIntake = monthlyData.values.reduce((a, b) => a + b);
    return totalIntake / monthlyData.values.length;
  }

  String formatMonth(DateTime month) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(month); // 한국어 월 표시
  }

  Map<String, dynamic> changeMonth(int monthsToAdd) {
    DateTime newMonthTarget = DateTime(currentSelectedMonth.year, currentSelectedMonth.month + monthsToAdd, 1);
    String? snackBarMessage;
    bool dateActuallyChanged = false;

    if (newMonthTarget.isBefore(oldestMonth) && !newMonthTarget.isAtSameMomentAs(oldestMonth)) {
      // newMonthTarget = oldestMonth; // Prevent going beyond the boundary
      snackBarMessage = kErrorPreviousData; // '더 이상 이전 데이터가 없습니다.'
    } else if (newMonthTarget.isAfter(newestMonth) && !newMonthTarget.isAtSameMomentAs(newestMonth)) {
      // newMonthTarget = newestMonth; // Prevent going beyond the boundary
      snackBarMessage = kErrorNextData; // '더 이상 다음 데이터가 없습니다.'
    } else {
      // Only update if the target month is different from the current one
      if (currentSelectedMonth.year != newMonthTarget.year || currentSelectedMonth.month != newMonthTarget.month) {
           currentSelectedMonth = newMonthTarget;
           dateActuallyChanged = true;
      } else if ( (monthsToAdd < 0 && currentSelectedMonth.isAtSameMomentAs(oldestMonth)) || (monthsToAdd > 0 && currentSelectedMonth.isAtSameMomentAs(newestMonth)) ){
        // This case handles when we are already at the boundary and try to move further
        // No actual change in date, but we might still want to show a message if it wasn't shown by boundary checks
        // This logic might need refinement based on exact UX desired at boundaries.
        // For now, if it's at the boundary and tries to move out, the above checks will set snackbar message.
      }
    }
    return {
      'newDate': currentSelectedMonth, // Return the (potentially unchanged) currentSelectedMonth
      'snackBarMessage': snackBarMessage,
      'dateChanged': dateActuallyChanged,
    };
  }
  // --- End Monthly Data Methods ---

  String formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    // Using a simpler format for the weekly range, as the original suffix logic can be complex.
    // Example: "May 5th ~ May 11th"
    // Using 'ko_KR' for Korean month names if desired, or remove for default locale.
    final DateFormat formatter = DateFormat('MMMM d일', 'ko_KR');
    return "${formatter.format(startDate)} ~ ${formatter.format(endDate)}";
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

  // Weekly navigation getters
  bool get canGoBackWeek => currentWeekStartDate.isAfter(oldestWeekStartDate);
  bool get canGoForwardWeek => currentWeekStartDate.isBefore(newestWeekStartDate);

  // Monthly navigation getters
  bool get canGoBackMonth {
      if (currentSelectedMonth.year == oldestMonth.year && currentSelectedMonth.month == oldestMonth.month) {
          return false;
      }
      return currentSelectedMonth.isAfter(oldestMonth);
  }

  bool get canGoForwardMonth {
      if (currentSelectedMonth.year == newestMonth.year && currentSelectedMonth.month == newestMonth.month) {
          return false;
      }
      return currentSelectedMonth.isBefore(newestMonth);
  }


  static double calculateBarHeight(int value, double maxVisualBarHeight, int maxValueInPeriod) {
    if (value <= 0 || maxValueInPeriod <= 0 || maxVisualBarHeight <= 0) {
      return 0;
    }
    double calculatedHeight = (value / maxValueInPeriod.toDouble()) * maxVisualBarHeight;
    return max(0, calculatedHeight); // Prevent negative height
  }
}
