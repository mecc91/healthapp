// services/scoreboard_data_service.dart

import 'dart:convert'; // for jsonDecode
import 'package:flutter/material.dart'; // for DateUtils
import 'package:http/http.dart' as http; // http 패키지
import 'package:intl/intl.dart';

import '../scoreboard_constants.dart';
import '../model/daily_intake_model.dart'; // DailyIntake 모델 import

class ScoreboardDataService {
  DateTime currentWeekStartDate; // 현재 선택된 주의 시작일 (월요일 기준)
  late DateTime oldestWeekStartDate; // 조회 가능한 가장 오래된 주의 시작일
  late DateTime newestWeekStartDate; // 조회 가능한 가장 최신 주의 시작일
  DateTime currentSelectedMonth; // 현재 선택된 월 (해당 월의 1일)

  final String _userId; // API 호출에 필요한 사용자 ID
  List<DailyIntake> _allDailyIntakes = []; // API로부터 받아온 전체 데이터 캐싱
  bool _isFetchingData = false; // 데이터 요청 중복 방지 플래그
  bool _initialDataFetched = false; // 초기 데이터 로드 완료 여부

  ScoreboardDataService({required String userId})
      : _userId = userId,
        currentWeekStartDate = _getInitialWeekStartDate(),
        currentSelectedMonth = DateTime.now() {
    _initializeDateBoundaries();
  }

  static DateTime _getInitialWeekStartDate() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1)); // 월요일 기준
  }

  void _initializeDateBoundaries() {
    final initialWeekStart = _getInitialWeekStartDate();
    oldestWeekStartDate = initialWeekStart.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = initialWeekStart.add(Duration(days: weeksOfDataAfterToday * 7));
  }

  // 사용자 ID를 반환하는 getter (필요시 사용)
  String get userId => _userId;

  // 초기 데이터 로드 확인 getter
  bool get isInitialDataFetched => _initialDataFetched;


  Future<void> fetchAllDataForUser({bool forceRefresh = false}) async {
    if (_isFetchingData && !forceRefresh) return;
    if (_initialDataFetched && !forceRefresh) return; // 이미 초기 로드 완료 시 강제 새로고침 아니면 반환

    _isFetchingData = true;
    final Uri uri = Uri.parse('$apiBaseUrl/users/$_userId/daily-intake');
    print('Fetching data from: $uri for user: $_userId');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        _allDailyIntakes = decodedData
            .map((jsonItem) => DailyIntake.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        _allDailyIntakes.sort((a, b) => a.day.compareTo(b.day)); // 날짜 순 정렬
        _initialDataFetched = true; // 초기 데이터 로드 완료
        print('Fetched ${_allDailyIntakes.length} daily intake records.');
      } else {
        print('Failed to load daily intakes. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _allDailyIntakes = [];
        // throw Exception('Failed to load daily intakes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily intakes: $e');
      _allDailyIntakes = [];
      // throw Exception('Error fetching daily intakes: $e');
    } finally {
      _isFetchingData = false;
    }
  }

  Future<List<Map<String, dynamic>>> getWeekData(DateTime startDate) async {
    if (!_initialDataFetched && !_isFetchingData) {
      await fetchAllDataForUser();
    }

    final weekStartDate = startDate.subtract(Duration(days: startDate.weekday - 1)); // 월요일 기준
    final endDate = weekStartDate.add(const Duration(days: 6)); // 해당 주의 일요일

    List<DailyIntake> weekIntakes = _allDailyIntakes.where((intake) {
      return !intake.day.isBefore(weekStartDate) && !intake.day.isAfter(endDate);
    }).toList();

    List<Map<String, dynamic>> weekDataForChart = List.generate(7, (index) {
      final currentDate = weekStartDate.add(Duration(days: index));
      final intakeForDay = weekIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: -1, day: currentDate, score: 0, energyKcal:0, proteinG:0, fatG:0, carbohydrateG:0, sugarsG:0, celluloseG:0, sodiumMg:0, cholesterolMg:0),
      );
      String dayAbbreviation = dayNames[currentDate.weekday - 1]; // dayNames는 월요일 시작 기준
      return {
        'day': dayAbbreviation,
        'value': intakeForDay.score,
        'date': currentDate,
      };
    });
    return weekDataForChart;
  }

  Future<Map<int, int>> getMonthlyScores(DateTime month) async {
     if (!_initialDataFetched && !_isFetchingData) {
      await fetchAllDataForUser();
    }

    Map<int, int> scores = {};
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    List<DailyIntake> monthIntakes = _allDailyIntakes.where((intake) {
      return intake.day.year == month.year && intake.day.month == month.month;
    }).toList();

    for (int dayNum = 1; dayNum <= daysInMonth; dayNum++) {
      final currentDate = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, dayNum);
      final intakeForDay = monthIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: -1, day: currentDate, score: 0, energyKcal:0, proteinG:0, fatG:0, carbohydrateG:0, sugarsG:0, celluloseG:0, sodiumMg:0, cholesterolMg:0),
      );
      scores[dayNum] = intakeForDay.score; // 점수 없는 날은 0점
    }
    return scores;
  }

  double calculateAverageScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final validScores = data
        .where((d) => d['value'] != null && (d['value'] as int) > 0)
        .map((d) => d['value'] as int)
        .toList();
    if (validScores.isEmpty) return 0;
    final totalScore = validScores.reduce((a, b) => a + b);
    return totalScore / validScores.length;
  }

  double calculateAverageMonthlyScore(Map<int, int> monthlyScores) {
    if (monthlyScores.isEmpty) return 0;
    final validScores = monthlyScores.values.where((score) => score > 0).toList();
    if (validScores.isEmpty) return 0;
    final totalScore = validScores.reduce((a, b) => a + b);
    return totalScore / validScores.length;
  }

  String formatDateRange(DateTime startDate) {
    final weekStartDate = startDate.subtract(Duration(days: startDate.weekday - 1));
    final endDate = weekStartDate.add(const Duration(days: 6));
    // 날짜 포맷은 기존 로직 유지
    /*
    String formatWithSuffix(DateTime date) {
      String day = DateFormat('d').format(date);
      String suffix = 'th';
      if (day.endsWith('1') && !day.endsWith('11')) suffix = 'st';
      else if (day.endsWith('2') && !day.endsWith('12')) suffix = 'nd';
      else if (day.endsWith('3') && !day.endsWith('13')) suffix = 'rd';
      return "${DateFormat('MMMM', 'ko_KR').format(date)} $day$suffix"; // 한국어 월 표시
    }
    */
     // 시작일과 종료일의 월이 다르면 각 월을 표시, 같으면 한 번만 표시
    if (weekStartDate.month == endDate.month) {
      return "${DateFormat('MMMM d', 'ko_KR').format(weekStartDate)} ~ ${DateFormat('d', 'ko_KR').format(endDate)}, ${weekStartDate.year}";
    } else {
      return "${DateFormat('MMMM d', 'ko_KR').format(weekStartDate)} ~ ${DateFormat('MMMM d', 'ko_KR').format(endDate)}, ${weekStartDate.year}";
    }
  }

  String formatMonth(DateTime month) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(month); // 연도와 한국어 월 표시
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

  Map<String, dynamic> changeMonth(int monthsToAdd) {
    DateTime newMonth = DateTime(currentSelectedMonth.year, currentSelectedMonth.month + monthsToAdd, 1);
    // 월간 경계는 ScoreboardDataService 또는 ScoreboardScreen에서 관리
    // 예시: 현재 날짜 기준 과거 2년, 미래 1년
    DateTime oldestMonthBoundary = DateTime(DateTime.now().year - 2, 1, 1);
    DateTime newestMonthBoundary = DateTime(DateTime.now().year + 1, 12, 1);

    String? snackBarMessage;
    bool monthActuallyChanged = false;

    if (newMonth.isBefore(oldestMonthBoundary)) {
      newMonth = oldestMonthBoundary;
      snackBarMessage = '더 이상 이전 데이터가 없습니다.';
    } else if (newMonth.isAfter(newestMonthBoundary)) {
      newMonth = newestMonthBoundary;
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
