// lib/nutrientintakePage/nutrient_intake_screen.dart
import 'package:flutter/material.dart';
// 아래 import 경로는 실제 프로젝트 구조에 맞게 확인 필요
import 'package:healthymeal/scoreboardPage/widgets/scoreboard_period_toggle.dart'; // 기간 선택 토글
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart'; // 공통 하단 네비게이션 바
import 'nutrient_intake_constants.dart'; // 상수 (API URL, UI 텍스트 등)
import 'services/nutrient_intake_data_service.dart'; // 데이터 서비스
import 'widgets/nutrient_selector_button.dart'; // 영양소 선택 버튼
import 'widgets/nutrient_weekly_chart.dart'; // 주간 차트 위젯
import 'widgets/nutrient_comment_display.dart'; // 코멘트 표시 위젯
import 'widgets/nutrient_monthly_calendar_view.dart'; // 월간 달력 위젯
// dayNamesKorean를 사용하기 위한 import (실제 경로 확인 필요)
// import '../../scoreboardPage/scoreboard_constants.dart'; // NutrientMonthlyCalendarView 내부에서 직접 import 하도록 변경

class NutrientIntakeScreen extends StatefulWidget {
  final String userId; // 외부에서 userId를 전달받도록 변경

  const NutrientIntakeScreen({super.key, required this.userId});

  @override
  State<NutrientIntakeScreen> createState() => _NutrientIntakeScreenState();
}

class _NutrientIntakeScreenState extends State<NutrientIntakeScreen> {
  late NutrientIntakeDataService _dataService;
  // isSelectedPeriod: 0:주간, 1:월간, 2:분기별, 3:연간
  final List<bool> _isSelectedPeriod = [true, false, false, false];

  List<Map<String, dynamic>> _currentWeekChartData = []; // 주간 차트 데이터
  Map<int, int> _currentMonthScoreData = {}; // 월간 달력 데이터 (일: 점수)

  late DateTime _displayedDate; // 현재 화면에 표시되는 기준 날짜 (주의 시작일 또는 월의 첫날)
  String _currentDateRangeFormatted = ""; // 화면에 표시될 날짜 범위 문자열
  String _currentNutrientNameForComment = ""; // 코멘트에 사용될 현재 영양소 이름

  bool _isLoading = true; // 데이터 로딩 상태
  String _loadingError = ""; // 로딩 중 발생한 오류 메시지

  @override
  void initState() {
    super.initState();
    _dataService = NutrientIntakeDataService(userId: widget.userId); // userId로 데이터 서비스 초기화
    _displayedDate = _dataService.currentWeekStartDate; // 초기 표시는 현재 주의 시작일
    _fetchAllDataAndLoadUI(); // 초기 데이터 로드
  }

  // 모든 데이터를 가져오고 UI를 로드하는 비동기 함수
  Future<void> _fetchAllDataAndLoadUI() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingError = "";
    });
    try {
      // 데이터 서비스에서 모든 일일 섭취 데이터를 가져옴
      await _dataService.fetchAllDailyIntakes();
      // 현재 선택된 기간(주간/월간)에 맞춰 데이터 로드
      _loadDataForCurrentSelection();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 현재 선택된 기간(주간/월간)에 따라 데이터를 로드하는 함수
  void _loadDataForCurrentSelection() {
    if (!mounted) return;

    // 코멘트에 표시될 현재 영양소 이름 업데이트
    _currentNutrientNameForComment = _dataService.getCurrentNutrientName();

    if (_isSelectedPeriod[0]) { // 주간 보기 선택 시
      // _displayedDate는 해당 주의 시작일이어야 함
      _loadDataForWeek(_dataService.currentWeekStartDate);
    } else if (_isSelectedPeriod[1]) { // 월간 보기 선택 시
      // _displayedDate는 해당 월의 첫째 날이어야 함
      _loadDataForMonth(_dataService.currentSelectedMonth);
    } else { // 분기별/연간 보기 (미구현)
      setState(() {
        _currentWeekChartData = [];
        _currentMonthScoreData = {};
        _currentDateRangeFormatted = "${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 (미구현)";
      });
    }
  }

  // 특정 주의 데이터를 로드하는 함수
  // dateForWeek는 해당 주의 아무 날짜나 될 수 있으며, 서비스에서 주의 시작일로 변환함
  void _loadDataForWeek(DateTime dateForWeek) {
    if (!mounted) return;
    // 서비스에 현재 주를 설정하도록 요청 (내부적으로 _getStartOfWeek 사용)
    _dataService.setCurrentWeekFromDate(dateForWeek);
    // 서비스로부터 올바르게 설정된 주의 시작일을 가져옴
    final weekStartDate = _dataService.currentWeekStartDate;

    setState(() {
      _displayedDate = weekStartDate; // UI에 표시될 날짜도 업데이트
      _currentWeekChartData = _dataService.getScoresForWeek(weekStartDate); // 주간 점수 데이터 가져오기
      _currentDateRangeFormatted = _dataService.formatDateRange(weekStartDate); // 날짜 범위 문자열 포맷팅
    });
  }

  // 특정 월의 데이터를 로드하는 함수
  void _loadDataForMonth(DateTime monthDate) {
    if (!mounted) return;
    // monthDate는 해당 월의 아무 날짜나 될 수 있으며, 월의 첫째 날로 정규화
    final firstDayOfMonth = _dataService.currentSelectedMonth = DateTime(monthDate.year, monthDate.month, 1);

    setState(() {
      _displayedDate = firstDayOfMonth; // UI에 표시될 날짜 업데이트
      _currentMonthScoreData = _dataService.getScoresForMonth(firstDayOfMonth); // 월간 점수 데이터 가져오기
      _currentDateRangeFormatted = _dataService.formatMonth(firstDayOfMonth); // 월 이름 문자열 포맷팅
    });
  }

  // 기간 선택 토글 변경 시 호출되는 함수
  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;
    if (_isSelectedPeriod[index] && !_isLoading) return; // 이미 선택된 탭이거나 로딩 중이 아닐 때 변경 없음

    DateTime newDateToDisplay;
    if (index == 0) { // 주간
      newDateToDisplay = _dataService.currentWeekStartDate;
    } else if (index == 1) { // 월간
      newDateToDisplay = _dataService.currentSelectedMonth;
    } else { // 분기별/연간 (미구현)
      newDateToDisplay = _displayedDate; // 일단 현재 날짜 유지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getPeriodName(index)} 데이터 표시는 아직 구현되지 않았습니다.')),
        );
      }
    }

    setState(() {
      for (int i = 0; i < _isSelectedPeriod.length; i++) {
        _isSelectedPeriod[i] = (i == index);
      }
      _displayedDate = newDateToDisplay; // _displayedDate 업데이트
    });
    // _displayedDate가 변경되었으므로, 해당 날짜 기준으로 주/월 데이터를 다시 로드
    _loadDataForCurrentSelection();
  }

  // 기간 토글 인덱스에 따른 기간 이름 반환
  String _getPeriodName(int index) {
    if (index == 1) return "월간";
    if (index == 2) return "분기별";
    if (index == 3) return "연간";
    return "주간"; // 기본값
  }

  // 주 변경 요청 처리 (주간 차트에서 호출)
  void _handleChangeWeek(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd); // 서비스에 주 변경 요청
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];
    final DateTime newDisplayDate = _dataService.currentWeekStartDate; // 서비스에서 업데이트된 주의 시작일

    if (mounted && snackBarMessage != null) { // 스낵바 메시지가 있으면 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged) { // 날짜가 실제로 변경된 경우에만 UI 업데이트
      _loadDataForWeek(newDisplayDate);
    }
  }

  // 월 변경 요청 처리 (월간 달력에서 호출)
  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd); // 서비스에 월 변경 요청
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];
    final DateTime newDisplayMonth = _dataService.currentSelectedMonth; // 서비스에서 업데이트된 월의 첫날

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged) {
       _loadDataForMonth(newDisplayMonth);
    }
  }

  // 영양소 변경 요청 처리 (영양소 선택 버튼 또는 스와이프 시 호출)
  void _handleChangeNutrient(int indexOffset) {
    _dataService.changeNutrient(indexOffset); // 서비스에 영양소 변경 요청
    if(mounted) {
      setState(() {
        // 코멘트에 표시될 영양소 이름 업데이트
        _currentNutrientNameForComment = _dataService.getCurrentNutrientName();
      });
    }
  }

  // 월간 달력에서 특정 날짜 클릭 시 해당 날짜가 포함된 주로 전환하는 함수
  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    // _loadDataForWeek가 내부적으로 _dataService.setCurrentWeekFromDate를 호출하여
    // 서비스의 currentWeekStartDate를 올바르게 설정함.
    
    setState(() {
      _isSelectedPeriod[0] = true; // 주간 탭 활성화
      _isSelectedPeriod[1] = false;
      _isSelectedPeriod[2] = false;
      _isSelectedPeriod[3] = false;
      // _displayedDate는 _loadDataForWeek 내부에서 해당 주의 시작일로 설정됨
    });
    _loadDataForWeek(date); // 선택된 날짜를 전달하여 해당 주로 전환
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // 월간 보기 시 이전/다음 달 이동 가능 여부
    bool canGoMonthBack = false;
    bool canGoMonthForward = false;
    if (_isSelectedPeriod[1]) { // 월간 보기일 때만
        canGoMonthBack = _dataService.canGoBackMonth;
        canGoMonthForward = _dataService.canGoForwardMonth;
    }

    Widget bodyContent; // 화면 본문 내용 (로딩, 오류, 또는 실제 데이터)
    if (_isLoading) {
      bodyContent = const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(kLoadingData), // "데이터를 불러오는 중..."
        ],
      ));
    } else if (_loadingError.isNotEmpty) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_loadingError, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _fetchAllDataAndLoadUI, // 재시도 버튼
                  child: const Text("다시 시도"))
            ],
          ),
        ),
      );
    } else { // 데이터 로딩 성공 시
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScoreboardPeriodToggle( // 주간/월간/분기/연간 선택 토글
            isSelected: _isSelectedPeriod,
            onPressed: _onPeriodToggleChanged,
          ),
          const SizedBox(height: 8),
          // 선택된 기간(주 또는 월) 표시
          if (_isSelectedPeriod[0] || _isSelectedPeriod[1])
            Text(
              _currentDateRangeFormatted, // 포맷팅된 날짜 범위 또는 월 이름
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),
          // 영양소 선택 버튼 (코멘트용)
          NutrientSelectorButton(
            selectedNutrientName: _currentNutrientNameForComment,
            onPressed: () => _handleChangeNutrient(1), // 다음 영양소로 변경 (순환)
            buttonWidth: screenSize.width - (16.0 * 2), // 화면 너비에 맞춤 (양쪽 패딩 제외)
          ),
          const SizedBox(height: 12),
          // 주간 차트 또는 월간 달력 표시 영역
          Expanded(
            flex: _isSelectedPeriod[1] ? 9 : 6, // 월간 보기일 때 더 많은 공간 할당
            child: _isSelectedPeriod[0] // 주간 보기 선택 시
                ? NutrientWeeklyChart(
                    weekData: _currentWeekChartData, // 주간 점수 데이터
                    onChangeWeek: _handleChangeWeek, // 주 변경 콜백
                    onChangeNutrientViaSwipe: _handleChangeNutrient, // 스와이프로 영양소 변경 (코멘트용)
                    canGoBack: _dataService.canGoBackWeek, // 이전 주 이동 가능 여부
                    canGoForward: _dataService.canGoForwardWeek, // 다음 주 이동 가능 여부
                    isWeekPeriodSelected: _isSelectedPeriod[0], // 현재 주간 보기 활성화 여부
                  )
                : _isSelectedPeriod[1] // 월간 보기 선택 시
                    ? Container( // 월간 달력 컨테이너
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: kNutrientIntakeGraphBackgroundColor, // 주간 차트와 유사한 배경색
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // 월 이동 버튼 영역
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton( // 이전 달 이동 버튼
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: canGoMonthBack ? () => _handleMonthChangeRequest(-1) : null,
                                    color: canGoMonthBack ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  // 월 이름은 달력 위에 이미 표시되므로 중복될 수 있어 제거 또는 다른 방식으로 표시 가능
                                  IconButton( // 다음 달 이동 버튼
                                    icon: const Icon(Icons.chevron_right),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: canGoMonthForward ? () => _handleMonthChangeRequest(1) : null,
                                    color: canGoMonthForward ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                            // _buildDayOfWeekHeader(), // 요일 헤더는 NutrientMonthlyCalendarView 내부로 이동
                            Expanded( // 실제 달력 위젯
                              child: NutrientMonthlyCalendarView(
                                selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1), // 현재 표시 월
                                monthlyNutrientData: _currentMonthScoreData, // 월간 점수 데이터
                                dataService: _dataService, // 데이터 서비스 전달
                                onDateSelected: (date) { // 날짜 선택 시 콜백
                                   _switchToWeekViewForDate(date); // 해당 날짜가 포함된 주로 전환
                                },
                                onChangeMonthBySwipe: _handleMonthChangeRequest, // 스와이프로 월 변경
                                onChangeNutrientBySwipe: _handleChangeNutrient, // 스와이프로 영양소 변경 (코멘트용)
                                canGoBackMonth: canGoMonthBack, // 이전 달 이동 가능 여부
                                canGoForwardMonth: canGoMonthForward, // 다음 달 이동 가능 여부
                                currentNutrientName: _currentNutrientNameForComment, // 현재 영양소 이름 (코멘트용)
                              ),
                            ),
                          ],
                        ),
                      )
                    // 분기별/연간 보기 (미구현)
                    : Center(child: Text("${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 표시는 아직 구현되지 않았습니다.")),
          ),
          const SizedBox(height: 10),
          // 하단 코멘트 표시 영역
          Flexible( // 남은 공간을 유동적으로 차지
            flex: _isSelectedPeriod[1] ? 1 : 2, // 월간 보기일 때 코멘트 영역을 조금 덜 차지하도록 조정
            fit: FlexFit.loose, // 내용이 적으면 작게, 많으면 최대한 차지
            child: NutrientCommentDisplay(
              nutrientName: _currentNutrientNameForComment, // 코멘트는 선택된 영양소 기준
              // averageIntake: _dataService.getAverageMonthlyIntakeForSelectedNutrient(_displayedDate), // 필요시 평균 섭취량 주입
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(kAppBarTitle, style: TextStyle(fontWeight: FontWeight.bold)), // "섭취 데이터"
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 화면 전체 패딩
        child: bodyContent,
      ),
      // 공통 하단 네비게이션 바
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard, // 현재 페이지가 스코어보드 기능과 유사하므로 임시 지정 (실제 앱 구조에 맞게 변경)
      ),
    );
  }
}
