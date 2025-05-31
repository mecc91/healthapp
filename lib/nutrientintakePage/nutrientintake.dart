// lib/nutrientintakePage/nutrient_intake_screen.dart
import 'package:flutter/material.dart';
// 아래 import 경로는 실제 프로젝트 구조에 맞게 확인 필요
import 'package:healthymeal/scoreboardPage/widgets/scoreboard_period_toggle.dart';
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart';
import 'nutrient_intake_constants.dart';
import 'services/nutrient_intake_data_service.dart';
import 'widgets/nutrient_selector_button.dart';
import 'widgets/nutrient_weekly_chart.dart';
import 'widgets/nutrient_comment_display.dart';
import 'widgets/nutrient_monthly_calendar_view.dart';
// dayNamesKorean를 사용하기 위한 import (실제 경로 확인 필요)
import '../../scoreboardPage/scoreboard_constants.dart'; // 예시 경로

class NutrientIntakeScreen extends StatefulWidget {
  final String userId; // 외부에서 userId를 전달받도록 변경

  const NutrientIntakeScreen({super.key, required this.userId});

  @override
  State<NutrientIntakeScreen> createState() => _NutrientIntakeScreenState();
}

class _NutrientIntakeScreenState extends State<NutrientIntakeScreen> {
  late NutrientIntakeDataService _dataService;
  final List<bool> _isSelectedPeriod = [true, false, false, false];

  List<Map<String, dynamic>> _currentWeekChartData = [];
  Map<int, int> _currentMonthScoreData = {};

  late DateTime _displayedDate;
  String _currentDateRangeFormatted = "";
  String _currentNutrientNameForComment = "";

  bool _isLoading = true;
  String _loadingError = "";

  @override
  void initState() {
    super.initState();
    _dataService = NutrientIntakeDataService(userId: widget.userId);
    _displayedDate = _dataService.currentWeekStartDate;
    _fetchAllDataAndLoadUI();
  }

  Future<void> _fetchAllDataAndLoadUI() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingError = "";
    });
    try {
      await _dataService.fetchAllDailyIntakes();
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

  void _loadDataForCurrentSelection() {
    if (!mounted) return;

    _currentNutrientNameForComment = _dataService.getCurrentNutrientName();

    if (_isSelectedPeriod[0]) { // Week selected
      // _loadDataForWeek는 _displayedDate를 사용하므로, _displayedDate가 정확한 주의 시작일이어야 함.
      // _dataService.currentWeekStartDate가 이미 올바르게 설정되어 있다고 가정.
      _loadDataForWeek(_dataService.currentWeekStartDate);
    } else if (_isSelectedPeriod[1]) { // Month selected
      _loadDataForMonth(_dataService.currentSelectedMonth);
    } else {
      setState(() {
        _currentWeekChartData = [];
        _currentMonthScoreData = {};
        _currentDateRangeFormatted = "${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 (미구현)";
      });
    }
  }

  // dateForWeek는 해당 주의 아무 날짜나 될 수 있음. 서비스에서 주의 시작일로 변환.
  void _loadDataForWeek(DateTime dateForWeek) {
    if (!mounted) return;
    // 서비스에 현재 주를 설정하도록 요청 (내부적으로 _getStartOfWeek 사용)
    _dataService.setCurrentWeekFromDate(dateForWeek);
    // 서비스로부터 올바르게 설정된 주의 시작일을 가져옴
    final weekStartDate = _dataService.currentWeekStartDate;

    setState(() {
      _displayedDate = weekStartDate; // UI에 표시될 날짜도 업데이트
      _currentWeekChartData = _dataService.getScoresForWeek(weekStartDate);
      _currentDateRangeFormatted = _dataService.formatDateRange(weekStartDate);
    });
  }

  void _loadDataForMonth(DateTime monthDate) {
    if (!mounted) return;
    final firstDayOfMonth = _dataService.currentSelectedMonth = DateTime(monthDate.year, monthDate.month, 1);

    setState(() {
      _displayedDate = firstDayOfMonth;
      _currentMonthScoreData = _dataService.getScoresForMonth(firstDayOfMonth);
      _currentDateRangeFormatted = _dataService.formatMonth(firstDayOfMonth);
    });
  }

  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;

    DateTime newDateToDisplay;
    if (index == 0) {
      newDateToDisplay = _dataService.currentWeekStartDate;
    } else if (index == 1) {
      newDateToDisplay = _dataService.currentSelectedMonth;
    } else {
      newDateToDisplay = _displayedDate;
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
    // _displayedDate가 변경되었으므로, _loadDataForCurrentSelection()을 호출하여
    // 해당 날짜 기준으로 주/월 데이터를 다시 로드
    _loadDataForCurrentSelection();
  }

  String _getPeriodName(int index) {
    if (index == 1) return "월간";
    if (index == 2) return "분기별";
    if (index == 3) return "연간";
    return "주간";
  }

  void _handleChangeWeek(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd);
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];
    // changeWeek는 서비스의 currentWeekStartDate를 업데이트하므로, 이를 사용
    final DateTime newDisplayDate = _dataService.currentWeekStartDate;


    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged) { // 날짜가 실제로 변경된 경우에만 UI 업데이트
      _loadDataForWeek(newDisplayDate);
    }
  }

  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd);
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];
    // changeMonth는 서비스의 currentSelectedMonth를 업데이트하므로, 이를 사용
    final DateTime newDisplayMonth = _dataService.currentSelectedMonth;

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged) {
       _loadDataForMonth(newDisplayMonth);
    }
  }

  void _handleChangeNutrient(int indexOffset) {
    _dataService.changeNutrient(indexOffset);
    if(mounted) {
      setState(() {
        _currentNutrientNameForComment = _dataService.getCurrentNutrientName();
      });
    }
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    // _loadDataForWeek가 내부적으로 _dataService.setCurrentWeekFromDate를 호출하여
    // 서비스의 currentWeekStartDate를 올바르게 설정함.
    
    setState(() {
      _isSelectedPeriod[0] = true;
      _isSelectedPeriod[1] = false;
      _isSelectedPeriod[2] = false;
      _isSelectedPeriod[3] = false;
      // _displayedDate는 _loadDataForWeek 내부에서 설정됨
    });
    _loadDataForWeek(date); // 선택된 날짜를 전달하여 해당 주로 전환
  }

  Widget _buildDayOfWeekHeader() {
    // dayNamesKorean는 scoreboard_constants.dart 에서 가져옴 (실제 경로 확인)
    const List<String> displayDayNames = dayNamesKorean; 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: displayDayNames.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
          Text(kLoadingData),
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
          ScoreboardPeriodToggle( // 주간/월간 선택 토글
            isSelected: _isSelectedPeriod,
            onPressed: _onPeriodToggleChanged,
          ),
          const SizedBox(height: 8),
          // 선택된 기간(주 또는 월) 표시
          if (_isSelectedPeriod[0] || _isSelectedPeriod[1])
            Text(
              _currentDateRangeFormatted,
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),
          // 영양소 선택 버튼 (코멘트용)
          NutrientSelectorButton(
            selectedNutrientName: _currentNutrientNameForComment,
            onPressed: () => _handleChangeNutrient(1), // 다음 영양소로 변경
            buttonWidth: screenSize.width - (16.0 * 2), // 화면 너비에 맞춤
          ),
          const SizedBox(height: 12),
          // 주간 차트 또는 월간 달력 표시 영역
          Expanded(
            flex: _isSelectedPeriod[1] ? 9 : 6, // 월간 보기일 때 더 많은 공간 할당
            child: _isSelectedPeriod[0] // 주간 보기 선택 시
                ? NutrientWeeklyChart(
                    weekData: _currentWeekChartData, // 날짜별 점수 데이터
                    onChangeWeek: _handleChangeWeek,
                    onChangeNutrientViaSwipe: _handleChangeNutrient, // 코멘트용 영양소 변경
                    canGoBack: _dataService.canGoBackWeek,
                    canGoForward: _dataService.canGoForwardWeek,
                    isWeekPeriodSelected: _isSelectedPeriod[0],
                  )
                : _isSelectedPeriod[1] // 월간 보기 선택 시
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: kNutrientIntakeGraphBackgroundColor, // 주간 차트와 동일한 배경색
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
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: canGoMonthBack ? () => _handleMonthChangeRequest(-1) : null,
                                    color: canGoMonthBack ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  // 월 이름은 달력 위에 이미 표시되므로 중복 제거
                                  IconButton(
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
                            _buildDayOfWeekHeader(), // 요일 헤더 (일, 월, 화...)
                            Expanded(
                              child: NutrientMonthlyCalendarView(
                                selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1),
                                monthlyNutrientData: _currentMonthScoreData, // 날짜별 점수 데이터
                                dataService: _dataService,
                                onDateSelected: (date) {
                                   _switchToWeekViewForDate(date); // 날짜 클릭 시 해당 주로 전환
                                },
                                onChangeMonthBySwipe: _handleMonthChangeRequest,
                                onChangeNutrientBySwipe: _handleChangeNutrient, // 코멘트용 영양소 변경
                                canGoBackMonth: canGoMonthBack,
                                canGoForwardMonth: canGoMonthForward,
                                currentNutrientName: _currentNutrientNameForComment, // 코멘트용
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
          Flexible(
            flex: 1, // 남은 공간 차지
            child: NutrientCommentDisplay(
              nutrientName: _currentNutrientNameForComment, // 코멘트는 선택된 영양소 기준
              // averageIntake: _currentAverageMonthlyIntakeForComment, // 필요시 주입
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
        title: const Text(kAppBarTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 화면 전체 패딩
        child: bodyContent,
      ),
      // 공통 하단 네비게이션 바 (실제 경로 확인 필요)
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard, // 현재 페이지 표시 (예시)
      ),
    );
  }
}
