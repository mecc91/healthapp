// lib/nutrientintakePage/services/nutrient_intake_data_service.dart
import 'dart:convert'; // for json.decode
import 'dart:math'; // for max function
import 'package:flutter/material.dart'; // Required for DateUtils
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 패키지
import '../nutrient_intake_constants.dart'; // 상수 (API URL, UI 텍스트 등)
import '../model/daily_intake_model.dart'; // DailyIntake 모델 클래스

class NutrientIntakeDataService {
  late DateTime currentWeekStartDate; // 현재 선택된 주의 시작일
  late DateTime oldestWeekStartDateForDisplay; // UI상 표시할 가장 오래된 주의 시작일
  late DateTime newestWeekStartDateForDisplay; // UI상 표시할 가장 최신의 주의 시작일
  int selectedNutrientIndex = 0; // 현재 선택된 영양소 인덱스 (코멘트 및 차트 데이터용)

  late DateTime currentSelectedMonth; // 현재 선택된 월의 첫째 날
  late DateTime oldestMonthForDisplay; // UI상 표시할 가장 오래된 월
  late DateTime newestMonthForDisplay; // UI상 표시할 가장 최신의 월

  final String userId; // API 호출에 사용될 사용자 ID
  List<DailyIntake> _allFetchedIntakes = []; // API로부터 가져온 모든 DailyIntake 데이터 캐시
  bool _isFetching = false; // 데이터 요청 중복 방지 플래그
  bool _hasFetchedInitialData = false; // 초기 데이터 로드 완료 여부

  NutrientIntakeDataService({required this.userId}) {
    _initializeDatesAndNutrient();
  }

  void _initializeDatesAndNutrient() {
    final now = DateTime.now();
    currentWeekStartDate = _getStartOfWeek(now);
    oldestWeekStartDateForDisplay = currentWeekStartDate.subtract(const Duration(days: 365 * 1));
    newestWeekStartDateForDisplay = currentWeekStartDate.add(const Duration(days: 90));
    currentSelectedMonth = DateTime(now.year, now.month, 1);
    oldestMonthForDisplay = DateTime(now.year - 1, 1, 1);
    newestMonthForDisplay = DateTime(now.year, now.month + 3, 1);
    if (newestMonthForDisplay.isAfter(DateTime(now.year, now.month + 3, 0))) {
      newestMonthForDisplay = DateTime(now.year, now.month + 3, 0);
    }
    selectedNutrientIndex = 0;
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void setCurrentWeekFromDate(DateTime date) {
    currentWeekStartDate = _getStartOfWeek(date);
  }

  Future<void> fetchAllDailyIntakes({bool forceRefresh = false}) async {
    if (_isFetching && !forceRefresh) return;
    if (_hasFetchedInitialData && !forceRefresh) return;
    _isFetching = true;
    debugPrint('Attempting to fetch all daily intakes for user: $userId');
    try {
      final response = await http.get(
        Uri.parse('$kApiBaseUrl/users/$userId/daily-intake'),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        _allFetchedIntakes = decodedData.map((jsonItem) => DailyIntake.fromJson(jsonItem)).toList();
        _allFetchedIntakes.sort((a, b) => a.day.compareTo(b.day));
        _hasFetchedInitialData = true;
        debugPrint('Successfully fetched ${_allFetchedIntakes.length} daily intake records.');
      } else {
        debugPrint('Failed to load daily intakes. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        _allFetchedIntakes = [];
        throw Exception('$kErrorLoadingData (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching daily intakes: $e');
      _allFetchedIntakes = [];
      throw Exception('$kErrorLoadingData ($e)');
    } finally {
      _isFetching = false;
    }
  }

  List<Map<String, dynamic>> getNutrientIntakeForWeek(DateTime weekStartDate, String nutrientKey) {
    if (!_hasFetchedInitialData) {
      debugPrint("Warning: Trying to get week nutrient intakes before initial data fetch.");
      return List.generate(7, (i) => {'day': kDayNames[i], 'value': 0.0, 'date': weekStartDate.add(Duration(days: i))});
    }
    List<Map<String, dynamic>> weekNutrientData = [];
    for (int i = 0; i < 7; i++) {
      final currentDate = weekStartDate.add(Duration(days: i));
      final intakeForDay = _allFetchedIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0),
      );
      final nutrientValue = intakeForDay.getNutrientValue(nutrientKey);
      weekNutrientData.add({
        'day': kDayNames[i],
        'value': nutrientValue ?? 0.0,
        'date': currentDate,
      });
    }
    return weekNutrientData;
  }

  // 특정 월의 일별 영양소 섭취량 데이터를 반환 (새로 추가된 메소드)
  Map<int, double> getNutrientIntakeForMonth(DateTime monthDate, String nutrientKey) {
    if (!_hasFetchedInitialData) {
      debugPrint("Warning: Trying to get month nutrient intakes before initial data fetch.");
      return {};
    }
    Map<int, double> monthNutrientData = {}; // Key: day of month, Value: nutrient intake (double)
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final intakeForDay = _allFetchedIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0), // 점수는 여기서 사용되지 않음
      );
      // DailyIntake 모델의 getNutrientValue 메소드를 사용하여 특정 영양소 값 가져오기
      final nutrientValue = intakeForDay.getNutrientValue(nutrientKey); // double? 반환
      monthNutrientData[day] = nutrientValue ?? 0.0; // null이면 0.0으로 처리
    }
    return monthNutrientData;
  }
  
  double getAverageMonthlyIntakeForSelectedNutrient(DateTime monthDate) {
    if (!_hasFetchedInitialData) return 0.0;
    final String nutrientKey = getCurrentNutrientName();
    List<double> intakesThisMonth = [];
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final dailyIntakeData = _allFetchedIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0),
      );
      final value = dailyIntakeData.getNutrientValue(nutrientKey);
      if (value != null && value > 0) {
        intakesThisMonth.add(value);
      }
    }
    if (intakesThisMonth.isEmpty) return 0.0;
    return intakesThisMonth.reduce((a, b) => a + b) / intakesThisMonth.length;
  }

  void resetToCurrentWeekAndDefaultNutrient() {
    _initializeDatesAndNutrient();
  }

  String formatMonth(DateTime month) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(month);
  }

  Map<String, dynamic> changeMonth(int monthsToAdd) {
    DateTime newMonthTarget = DateTime(currentSelectedMonth.year, currentSelectedMonth.month + monthsToAdd, 1);
    String? snackBarMessage;
    bool dateActuallyChanged = false;
    if (newMonthTarget.isBefore(oldestMonthForDisplay) && !DateUtils.isSameDay(newMonthTarget, oldestMonthForDisplay)) {
      snackBarMessage = kErrorPreviousData;
    } else if (newMonthTarget.isAfter(newestMonthForDisplay) && !DateUtils.isSameDay(newMonthTarget, newestMonthForDisplay)) {
      snackBarMessage = kErrorNextData;
    } else {
      if (currentSelectedMonth.year != newMonthTarget.year || currentSelectedMonth.month != newMonthTarget.month) {
           currentSelectedMonth = newMonthTarget;
           dateActuallyChanged = true;
      }
    }
    return {
      'newDate': currentSelectedMonth,
      'snackBarMessage': snackBarMessage,
      'dateChanged': dateActuallyChanged,
    };
  }

  String formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    if (startDate.month == endDate.month) {
      return "${DateFormat('yyyy년 MMMM d일', 'ko_KR').format(startDate)} ~ ${DateFormat('d일', 'ko_KR').format(endDate)}";
    } else {
      return "${DateFormat('yyyy년 MMMM d일', 'ko_KR').format(startDate)} ~ ${DateFormat('MMMM d일', 'ko_KR').format(endDate)}";
    }
  }

  Map<String, dynamic> changeWeek(int weeksToAdd) {
    final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));
    String? snackBarMessage;
    bool dateActuallyChanged = false;
    if (targetStartDate.isBefore(oldestWeekStartDateForDisplay)) {
      snackBarMessage = kErrorPreviousData;
    } else if (targetStartDate.isAfter(newestWeekStartDateForDisplay)) {
      snackBarMessage = kErrorNextData;
    } else {
      if (!DateUtils.isSameDay(currentWeekStartDate, targetStartDate)) {
        currentWeekStartDate = targetStartDate;
        dateActuallyChanged = true;
      }
    }
    return {
      'newDate': currentWeekStartDate,
      'snackBarMessage': snackBarMessage,
      'dateChanged': dateActuallyChanged,
    };
  }

  String getCurrentNutrientName() {
    if (selectedNutrientIndex < 0 || selectedNutrientIndex >= kNutrientKeys.length) {
      return "알 수 없음";
    }
    return kNutrientKeys[selectedNutrientIndex];
  }

  void changeNutrient(int indexOffset) {
    selectedNutrientIndex = (selectedNutrientIndex + indexOffset + kNutrientKeys.length) % kNutrientKeys.length;
  }

  bool get canGoBackWeek => currentWeekStartDate.isAfter(oldestWeekStartDateForDisplay);
  bool get canGoForwardWeek => currentWeekStartDate.isBefore(newestWeekStartDateForDisplay);

  bool get canGoBackMonth {
    if (currentSelectedMonth.year < oldestMonthForDisplay.year) return false;
    if (currentSelectedMonth.year == oldestMonthForDisplay.year && currentSelectedMonth.month <= oldestMonthForDisplay.month) {
        return false;
    }
    return true;
  }

  bool get canGoForwardMonth {
    if (currentSelectedMonth.year > newestMonthForDisplay.year) return false;
    if (currentSelectedMonth.year == newestMonthForDisplay.year && currentSelectedMonth.month >= newestMonthForDisplay.month) {
        return false;
    }
    return true;
  }

  static double calculateBarHeight(double value, double maxVisualBarHeight, double maxValueInPeriod) {
    if (value <= 0 || maxValueInPeriod <= 0 || maxVisualBarHeight <= 0) {
      return 0.0;
    }
    double calculatedHeight = (value / maxValueInPeriod) * maxVisualBarHeight;
    return max(0.0, calculatedHeight.isNaN ? 0.0 : calculatedHeight);
  }

  bool get hasFetchedInitialDataStatus => _hasFetchedInitialData;
}