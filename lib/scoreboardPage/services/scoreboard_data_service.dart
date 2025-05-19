import 'dart:math';
import 'package:intl/intl.dart';
import '../scoreboard_constants.dart'; // 상수 파일 import
import 'package:flutter/material.dart';

class ScoreboardDataService {
  DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  DateTime currentSelectedMonth; // Keep track of the selected month

  ScoreboardDataService() : currentWeekStartDate = _getInitialWeekStartDate(), currentSelectedMonth = DateTime.now() {
    _initializeDateBoundaries();
  }

  static DateTime _getInitialWeekStartDate() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  void _initializeDateBoundaries() {
    // For weekly view
    final now = DateTime.now();
    oldestWeekStartDate = _getInitialWeekStartDate().subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = _getInitialWeekStartDate().add(Duration(days: weeksOfDataAfterToday * 7));

    // You might want different boundaries for monthly view or reuse weekly boundaries
  }

  List<Map<String, dynamic>> getSimulatedWeekData(DateTime startDate) {
    final random = Random(startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay);
    List<Map<String, dynamic>> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add({
        'day': dayNames[i],
        'value': random.nextInt(71) + 30,
      });
    }
    return weekData;
  }

  // New method for monthly scores
  Map<int, int> getScoresForMonth(DateTime month) {
    final random = Random(month.year * 100 + month.month); // Seed per month
    Map<int, int> scores = {};
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    for (int day = 1; day <= daysInMonth; day++) {
      // Simulate some days having scores and some not
      if (random.nextDouble() > 0.3) { // 70% chance of having a score
        scores[day] = random.nextInt(71) + 30; // 30 - 100
      }
    }
    return scores;
  }

  // New method to calculate average monthly score
  double calculateAverageMonthlyScore(Map<int, int> monthlyScores) {
    if (monthlyScores.isEmpty) return 0;
    final totalScore = monthlyScores.values.reduce((a, b) => a + b);
    return totalScore / monthlyScores.values.length;
  }


  double calculateAverageScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final totalScore = data.map((d) => d['value'] as int).reduce((a, b) => a + b);
    return totalScore / data.length;
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

  // New method to format month name
  String formatMonth(DateTime month) {
    return DateFormat('MMMM yyyy').format(month);
  }

  Map<String, dynamic> changeWeek(int weeksToAdd) {
    final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));
    String? snackBarMessage;
    bool dateActuallyChanged = false;

    if (targetStartDate.isBefore(oldestWeekStartDate)) {
      snackBarMessage = '더 이상 이전 데이터가 없습니다.';
    } else if (targetStartDate.isAfter(newestWeekStartDate)) {
      snackBarMessage = '더 이상 다음 데이터가 없습니다.';
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

  // New method to change month
  Map<String, dynamic> changeMonth(int monthsToAdd) {
    DateTime newMonth = DateTime(currentSelectedMonth.year, currentSelectedMonth.month + monthsToAdd, 1);
    // Define boundaries for months if needed, similar to weeks
    // For simplicity, let's allow navigation for a few years back and forth
    DateTime oldestMonth = DateTime(DateTime.now().year - 2, 1, 1); // 2 years back
    DateTime newestMonth = DateTime(DateTime.now().year + 1, 12, 1); // 1 year forward

    String? snackBarMessage;
    bool monthActuallyChanged = false;

    if (newMonth.isBefore(oldestMonth)) {
      newMonth = oldestMonth;
      snackBarMessage = '더 이상 이전 데이터가 없습니다.';
    } else if (newMonth.isAfter(newestMonth)) {
      newMonth = newestMonth; // Corrected: should be newestMonth
      snackBarMessage = '더 이상 다음 데이터가 없습니다.';
    } else {
      monthActuallyChanged = true;
    }
    currentSelectedMonth = newMonth;
    return {
      'newDate': currentSelectedMonth,
      'snackBarMessage': snackBarMessage,
      'dateChanged': monthActuallyChanged,
    };
  }
}