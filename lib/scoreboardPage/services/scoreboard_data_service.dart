import 'dart:math';
import 'package:intl/intl.dart';
import '../scoreboard_constants.dart'; // 상수 파일 import

class ScoreboardDataService {
  DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;

  ScoreboardDataService() : currentWeekStartDate = _getInitialWeekStartDate() {
    _initializeDateBoundaries();
  }

  static DateTime _getInitialWeekStartDate() {
    final now = DateTime.now();
    // 주의 시작을 월요일로 설정 (weekday: 1=월요일, ..., 7=일요일)
    return now.subtract(Duration(days: now.weekday - 1));
  }

  void _initializeDateBoundaries() {
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: weeksOfDataAfterToday * 7));
  }

  List<Map<String, dynamic>> getSimulatedWeekData(DateTime startDate) {
    // 각 주의 데이터가 고유하도록 시드 값에 startDate.millisecondsSinceEpoch 사용
    final random = Random(startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay);
    List<Map<String, dynamic>> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add({
        'day': dayNames[i],
        'value': random.nextInt(71) + 30, // 30 ~ 100 사이의 점수
      });
    }
    return weekData;
  }

  double calculateAverageScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final totalScore = data.map((d) => d['value'] as int).reduce((a, b) => a + b);
    return totalScore / data.length;
  }

  String formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    // 날짜 포맷 (예: "May 12th ~ May 18th")
    String formatWithSuffix(DateTime date) {
      String day = DateFormat('d').format(date);
      String suffix = 'th';
      if (day.endsWith('1') && !day.endsWith('11')) suffix = 'st';
      else if (day.endsWith('2') && !day.endsWith('12')) suffix = 'nd';
      else if (day.endsWith('3') && !day.endsWith('13')) suffix = 'rd';
      return "${DateFormat('MMMM').format(date)} ${day}${suffix}";
    }
    return "${formatWithSuffix(startDate)} ~ ${formatWithSuffix(endDate)}";
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
        'newDate': currentWeekStartDate, // 변경되었거나, 경계에 걸려 변경되지 않은 현재 날짜
        'snackBarMessage': snackBarMessage,
        'dateChanged': dateActuallyChanged, // 실제로 날짜가 유효하게 변경되었는지
    };
  }
}