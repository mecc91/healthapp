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
  int selectedNutrientIndex = 0; // 현재 선택된 영양소 인덱스 (코멘트용)

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

  // 날짜 및 영양소 인덱스 초기화
  void _initializeDatesAndNutrient() {
    final now = DateTime.now();

    // 주간 보기 관련 날짜 초기화
    currentWeekStartDate = _getStartOfWeek(now);
    // 예시: 과거 1년, 미래 3개월까지의 데이터를 UI에서 이동 가능하도록 설정
    oldestWeekStartDateForDisplay = currentWeekStartDate.subtract(const Duration(days: 365 * 1));
    newestWeekStartDateForDisplay = currentWeekStartDate.add(const Duration(days: 90));

    // 월간 보기 관련 날짜 초기화
    currentSelectedMonth = DateTime(now.year, now.month, 1);
    oldestMonthForDisplay = DateTime(now.year - 1, 1, 1); // 예: 과거 1년
    newestMonthForDisplay = DateTime(now.year, now.month + 3, 1); // 예: 미래 3개월 (다음 해로 넘어갈 수 있음)
    // 미래 날짜 경계 조정 (예: 현재 월로부터 3개월 후의 마지막 날까지)
    if (newestMonthForDisplay.isAfter(DateTime(now.year, now.month + 3, 0))) {
      newestMonthForDisplay = DateTime(now.year, now.month + 3, 0);
    }


    selectedNutrientIndex = 0; // 기본 영양소 (kNutrientKeys의 첫 번째)
  }

  // 주어진 날짜가 속한 주의 시작일(월요일)을 반환 (비공개 메서드)
  DateTime _getStartOfWeek(DateTime date) {
    // Dart의 weekday는 월요일이 1, 일요일이 7
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // 외부에서 특정 날짜를 기준으로 현재 주의 시작일을 설정하는 공개 메서드
  void setCurrentWeekFromDate(DateTime date) {
    currentWeekStartDate = _getStartOfWeek(date);
  }

  // API로부터 모든 기간의 DailyIntake 데이터를 가져오는 메소드
  Future<void> fetchAllDailyIntakes({bool forceRefresh = false}) async {
    if (_isFetching && !forceRefresh) return; // 이미 요청 중이면 중복 방지
    if (_hasFetchedInitialData && !forceRefresh) return; // 이미 초기 데이터가 있고, 강제 새로고침이 아니면 반환

    _isFetching = true;
    debugPrint('Attempting to fetch all daily intakes for user: $userId');
    try {
      final response = await http.get(
        Uri.parse('$kApiBaseUrl/users/$userId/daily-intake'),
        // 필요한 경우 헤더 추가 (예: Authorization 토큰)
        // headers: { 'Authorization': 'Bearer YOUR_ACCESS_TOKEN' },
      ).timeout(const Duration(seconds: 15)); // 타임아웃 설정

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 한글 깨짐 방지
        final List<dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        _allFetchedIntakes = decodedData.map((jsonItem) => DailyIntake.fromJson(jsonItem)).toList();
        // 날짜순으로 정렬 (오래된 날짜 -> 최신 날짜)
        _allFetchedIntakes.sort((a, b) => a.day.compareTo(b.day));
        _hasFetchedInitialData = true; // 초기 데이터 로드 완료 플래그 설정
        debugPrint('Successfully fetched ${_allFetchedIntakes.length} daily intake records.');
      } else {
        debugPrint('Failed to load daily intakes. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        _allFetchedIntakes = []; // 실패 시 데이터 초기화
        throw Exception('$kErrorLoadingData (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching daily intakes: $e');
      _allFetchedIntakes = []; // 예외 발생 시 데이터 초기화
      throw Exception('$kErrorLoadingData ($e)');
    } finally {
      _isFetching = false;
    }
  }

  // 특정 주의 일별 점수 데이터를 반환 (DailyIntake.score 사용)
  List<Map<String, dynamic>> getScoresForWeek(DateTime weekStartDate) {
    if (!_hasFetchedInitialData) { // 데이터가 로드되지 않았다면 빈 리스트 반환 또는 예외 처리
       debugPrint("Warning: Trying to get week scores before initial data fetch.");
       return List.generate(7, (i) => {'day': kDayNames[i], 'value': 0, 'date': weekStartDate.add(Duration(days: i))});
    }
    List<Map<String, dynamic>> weekScoreData = [];
    for (int i = 0; i < 7; i++) {
      final currentDate = weekStartDate.add(Duration(days: i));
      // 해당 날짜의 DailyIntake 객체를 찾음
      final intakeForDay = _allFetchedIntakes.firstWhere(
        (intake) =>
            DateUtils.isSameDay(intake.day, currentDate), // DateUtils.isSameDay로 날짜 비교
        // 해당 날짜의 데이터가 없으면 score 0으로 기본값 생성
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0),
      );
      weekScoreData.add({
        'day': kDayNames[i], // "Mon", "Tue", ... (kDayNames는 월요일 시작 기준)
        'value': intakeForDay.score, // 해당 날짜의 점수
        'date': currentDate, // 실제 날짜 정보
      });
    }
    return weekScoreData;
  }

  // 특정 월의 일별 점수 데이터를 반환 (DailyIntake.score 사용)
  Map<int, int> getScoresForMonth(DateTime monthDate) {
     if (!_hasFetchedInitialData) {
      debugPrint("Warning: Trying to get month scores before initial data fetch.");
      return {};
    }
    Map<int, int> monthScoreData = {}; // Key: day of month, Value: score
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final intakeForDay = _allFetchedIntakes.firstWhere(
        (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0),
      );
      monthScoreData[day] = intakeForDay.score;
    }
    return monthScoreData;
  }
  
  // (코멘트용) 선택된 영양소의 특정 월 평균 섭취량 계산
  double getAverageMonthlyIntakeForSelectedNutrient(DateTime monthDate) {
    if (!_hasFetchedInitialData) return 0.0;

    final String nutrientKey = getCurrentNutrientName(); // 현재 선택된 영양소 이름
    List<double> intakesThisMonth = [];
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final dailyIntakeData = _allFetchedIntakes.firstWhere(
            (intake) => DateUtils.isSameDay(intake.day, currentDate),
        orElse: () => DailyIntake(id: '', day: currentDate, score: 0), // 데이터 없으면 기본값
      );
      // DailyIntake 모델의 getNutrientValue 메소드를 사용하여 특정 영양소 값 가져오기
      final value = dailyIntakeData.getNutrientValue(nutrientKey);
      if (value != null && value > 0) { // 유효한 값만 평균 계산에 포함
        intakesThisMonth.add(value);
      }
    }
    if (intakesThisMonth.isEmpty) return 0.0;
    return intakesThisMonth.reduce((a, b) => a + b) / intakesThisMonth.length;
  }

  // 날짜를 현재 주로, 영양소를 첫 번째로 리셋 (UI용)
  void resetToCurrentWeekAndDefaultNutrient() {
    _initializeDatesAndNutrient(); // 날짜 및 영양소 인덱스 초기화
    // _allFetchedIntakes는 유지하거나, 필요시 API를 다시 호출하여 갱신할 수 있습니다.
    // 만약 강제 새로고침이 필요하다면 _hasFetchedInitialData = false; 로 설정 후 fetchAllDailyIntakes 호출
  }

  // 'yyyy년 MMMM' 형식으로 월 포맷 (예: "2023년 5월")
  String formatMonth(DateTime month) {
    return DateFormat('yyyy년 MMMM', 'ko_KR').format(month);
  }

  // 월 변경 로직
  Map<String, dynamic> changeMonth(int monthsToAdd) {
    DateTime newMonthTarget = DateTime(currentSelectedMonth.year, currentSelectedMonth.month + monthsToAdd, 1);
    String? snackBarMessage;
    bool dateActuallyChanged = false;

    // UI상 설정된 가장 오래된/최신 월 경계 확인
    if (newMonthTarget.isBefore(oldestMonthForDisplay) && !DateUtils.isSameDay(newMonthTarget, oldestMonthForDisplay)) {
      snackBarMessage = kErrorPreviousData;
      // newMonthTarget = oldestMonthForDisplay; // 경계로 설정 (선택적)
    } else if (newMonthTarget.isAfter(newestMonthForDisplay) && !DateUtils.isSameDay(newMonthTarget, newestMonthForDisplay)) {
      snackBarMessage = kErrorNextData;
      // newMonthTarget = newestMonthForDisplay; // 경계로 설정 (선택적)
    } else {
      // 실제로 월이 변경되었는지 확인
      if (currentSelectedMonth.year != newMonthTarget.year || currentSelectedMonth.month != newMonthTarget.month) {
           currentSelectedMonth = newMonthTarget;
           dateActuallyChanged = true;
      }
    }
    return {
      'newDate': currentSelectedMonth, // 변경된 (또는 변경되지 않은) 현재 월
      'snackBarMessage': snackBarMessage, // 표시할 메시지
      'dateChanged': dateActuallyChanged, // 실제 날짜 변경 여부
    };
  }

  // 'MMMM d일 ~ MMMM d일' 형식으로 주간 범위 포맷 (예: "5월 1일 ~ 5월 7일")
  String formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    final DateFormat formatter = DateFormat('MMMM d일', 'ko_KR');
    if (startDate.month == endDate.month) {
      return "${DateFormat('yyyy년 MMMM d일', 'ko_KR').format(startDate)} ~ ${DateFormat('d일', 'ko_KR').format(endDate)}";
    } else {
      return "${DateFormat('yyyy년 MMMM d일', 'ko_KR').format(startDate)} ~ ${DateFormat('MMMM d일', 'ko_KR').format(endDate)}";
    }
  }

  // 주 변경 로직
  Map<String, dynamic> changeWeek(int weeksToAdd) {
    final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));
    String? snackBarMessage;
    bool dateActuallyChanged = false;

    if (targetStartDate.isBefore(oldestWeekStartDateForDisplay)) {
      snackBarMessage = kErrorPreviousData;
      // targetStartDate = oldestWeekStartDateForDisplay; // 경계로 설정 (선택적)
    } else if (targetStartDate.isAfter(newestWeekStartDateForDisplay)) {
      snackBarMessage = kErrorNextData;
      // targetStartDate = newestWeekStartDateForDisplay; // 경계로 설정 (선택적)
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

  // 현재 선택된 영양소의 이름을 반환 (코멘트용)
  String getCurrentNutrientName() {
    if (selectedNutrientIndex < 0 || selectedNutrientIndex >= kNutrientKeys.length) {
      return "알 수 없음"; // 인덱스 범위 오류 방지
    }
    return kNutrientKeys[selectedNutrientIndex];
  }

  // 영양소 변경 로직 (코멘트용)
  void changeNutrient(int indexOffset) {
    selectedNutrientIndex = (selectedNutrientIndex + indexOffset + kNutrientKeys.length) % kNutrientKeys.length;
  }

  // 주간 이동 가능 여부 (UI 버튼 활성화용)
  bool get canGoBackWeek => currentWeekStartDate.isAfter(oldestWeekStartDateForDisplay);
  bool get canGoForwardWeek => currentWeekStartDate.isBefore(newestWeekStartDateForDisplay);

  // 월간 이동 가능 여부 (UI 버튼 활성화용)
  bool get canGoBackMonth {
      // 정확한 비교를 위해 year와 month를 각각 비교
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

  // 그래프 바 높이 계산 (NutrientWeeklyChart에서 사용)
  static double calculateBarHeight(int value, double maxVisualBarHeight, int maxValueInPeriod) {
    if (value <= 0 || maxValueInPeriod <= 0 || maxVisualBarHeight <= 0) {
      return 0; // 음수 또는 0 값 처리, 또는 최대 높이가 0 이하인 경우
    }
    // 점수를 0-100 범위로 가정하고, maxValueInPeriod는 참조용 (예: 해당 기간의 최대 점수)
    // 실제 바 높이는 (value / 100) * maxVisualBarHeight 로 계산할 수도 있음 (점수가 항상 0-100이라면)
    // 여기서는 maxValueInPeriod를 기준으로 비율 계산
    double calculatedHeight = (value.toDouble() / maxValueInPeriod.toDouble()) * maxVisualBarHeight;
    return max(0, calculatedHeight.isNaN ? 0 : calculatedHeight); // NaN 및 음수 높이 방지
  }

  // 초기 데이터 로드 상태를 반환하는 getter
  bool get hasFetchedInitialDataStatus => _hasFetchedInitialData;
}
