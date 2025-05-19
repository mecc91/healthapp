import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../nutrientintakePage/nutrientintake.dart';

import 'widgets/scoreboard_period_toggle.dart';
import 'widgets/average_score_display.dart';
import 'widgets/weekly_score_chart.dart';
import 'widgets/score_comment_display.dart';
import 'services/scoreboard_data_service.dart';
import '../../widgets/common_bottom_navigation_bar.dart';
import 'widgets/monthly_calendar_view.dart';
import 'scoreboard_constants.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final List<bool> _isSelectedToggle = [true, false, false, false];

  late ScoreboardDataService _dataService;
  List<Map<String, dynamic>> _currentWeekChartData = [];
  Map<int, int> _currentMonthScores = {};
  double _currentAverageScore = 0;
  String _currentDateRangeFormatted = "";
  late DateTime _displayedDate;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _dataService = ScoreboardDataService();
    _displayedDate = _dataService.currentWeekStartDate;
    _loadDataForCurrentSelection();
  }

  void _loadDataForCurrentSelection() {
    if (!mounted) return;

    if (_isSelectedToggle[0]) { // Week
      _loadDataForWeek(_displayedDate);
    } else if (_isSelectedToggle[1]) { // Month
      _loadDataForMonth(_displayedDate);
    } else {
      setState(() {
        _currentWeekChartData = [];
        _currentMonthScores = {};
        _currentAverageScore = 0;
        if (_isSelectedToggle[1]) {
             _currentDateRangeFormatted = _dataService.formatMonth(_displayedDate);
        } else {
            _currentDateRangeFormatted = "Quarter/Year (Not Implemented)";
        }
      });
    }
  }

  void _loadDataForWeek(DateTime startDate) {
    if (!mounted) return;
    final weekStartDate = startDate.subtract(Duration(days: startDate.weekday -1));
    setState(() {
      _displayedDate = weekStartDate;
      _currentWeekChartData = _dataService.getSimulatedWeekData(weekStartDate);
      _currentAverageScore = _dataService.calculateAverageScore(_currentWeekChartData);
      _currentDateRangeFormatted = _dataService.formatDateRange(weekStartDate);
       _dataService.currentWeekStartDate = weekStartDate;
    });
  }

  void _loadDataForMonth(DateTime monthDate) {
    if (!mounted) return;
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    setState(() {
      _displayedDate = firstDayOfMonth; // _displayedDate 업데이트
      _currentMonthScores = _dataService.getScoresForMonth(firstDayOfMonth);
      _currentAverageScore = _dataService.calculateAverageMonthlyScore(_currentMonthScores);
      _currentDateRangeFormatted = _dataService.formatMonth(firstDayOfMonth);
      _dataService.currentSelectedMonth = firstDayOfMonth;
    });
  }

  void _handleWeekChangeRequest(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd);
    final DateTime newDisplayDate = result['newDate'];
    _showSnackBarMessage(result['snackBarMessage']);

    // 주간 데이터 로드 전에 _displayedDate를 먼저 업데이트하여 애니메이션이 올바르게 트리거되도록 함
    if (result['dateChanged'] || _displayedDate != newDisplayDate) {
        // setState(() { // _loadDataForWeek 내부에서 setState가 호출되므로 중복 호출 방지
        //   _displayedDate = newDisplayDate;
        // });
        _loadDataForWeek(newDisplayDate);
    }
  }

  // _handleMonthChangeRequest는 스와이프 및 버튼 클릭 모두에 사용됨
  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd);
    final DateTime newDisplayMonth = result['newDate'];
    _showSnackBarMessage(result['snackBarMessage']);

    final firstOfNewDisplayMonth = DateTime(newDisplayMonth.year, newDisplayMonth.month, 1);
    if (result['dateChanged'] || _displayedDate != firstOfNewDisplayMonth ) {
        // setState(() { // _loadDataForMonth 내부에서 setState가 호출되므로 중복 호출 방지
        //   _displayedDate = firstOfNewDisplayMonth;
        // });
        _loadDataForMonth(firstOfNewDisplayMonth); // 이 함수 내부에서 _displayedDate가 업데이트 됨
    }
  }

  void _showSnackBarMessage(String? message) {
    if (mounted && message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;
    DateTime newDateToDisplay;
    if (index == 0) {
      newDateToDisplay = _dataService.currentWeekStartDate;
    } else if (index == 1) {
      newDateToDisplay = DateTime(_dataService.currentSelectedMonth.year, _dataService.currentSelectedMonth.month, 1);
    } else {
      newDateToDisplay = _displayedDate; // 다른 탭은 현재 날짜 유지 (또는 특정 로직 추가)
    }

    // _displayedDate를 먼저 설정하고 _loadDataForCurrentSelection를 호출하여 애니메이션 트리거
    setState(() {
      for (int i = 0; i < _isSelectedToggle.length; i++) {
        _isSelectedToggle[i] = (i == index);
      }
      _displayedDate = newDateToDisplay; // _displayedDate 상태 업데이트
    });
    _loadDataForCurrentSelection();
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    final newWeekStartDate = date.subtract(Duration(days: date.weekday - 1));
    setState(() {
      _isSelectedToggle[0] = true;
      _isSelectedToggle[1] = false;
      _isSelectedToggle[2] = false;
      _isSelectedToggle[3] = false;
      _displayedDate = newWeekStartDate; // _displayedDate 상태 업데이트
    });
    _loadDataForWeek(newWeekStartDate);
  }

  Widget _buildDayOfWeekHeader() {
    const List<String> displayDayNames = dayNamesKorean;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: displayDayNames.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    fontSize: 12,
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
    bool canGoWeekBack = false;
    bool canGoWeekForward = false;
    bool canGoMonthBack = false;
    bool canGoMonthForward = false;

    if (_isSelectedToggle[0]) { // 주간 뷰일 때
      canGoWeekBack = _displayedDate.isAfter(_dataService.oldestWeekStartDate);
      canGoWeekForward = _displayedDate.isBefore(_dataService.newestWeekStartDate.add(const Duration(days: 1)));
    } else if (_isSelectedToggle[1]) { // 월간 뷰일 때
        DateTime now = DateTime.now();
        DateTime oldestMonth = DateTime(now.year - 2, 1, 1);
        DateTime newestMonth = DateTime(now.year + 1, 12, 1);
        DateTime currentMonthStart = DateTime(_displayedDate.year, _displayedDate.month, 1);

        canGoMonthBack = currentMonthStart.isAfter(oldestMonth);
        canGoMonthForward = currentMonthStart.isBefore(newestMonth) || currentMonthStart.isAtSameMomentAs(newestMonth);
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Scoreboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreboardPeriodToggle(
              isSelected: _isSelectedToggle,
              onPressed: _onPeriodToggleChanged,
            ),
            const SizedBox(height: 16),
            AverageScoreDisplay(
              averageScore: _currentAverageScore,
              dateRangeFormatted: _currentDateRangeFormatted,
              onDetailPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NutrientIntakeScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: _isSelectedToggle[1] ? 9 : 6,
              child: _isSelectedToggle[0]
                  ? WeeklyScoreChart(
                      weekData: _currentWeekChartData,
                      onChangeWeek: _handleWeekChangeRequest,
                      canGoBack: canGoWeekBack,
                      canGoForward: canGoWeekForward,
                    )
                  : _isSelectedToggle[1]
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.zero,
                                    onPressed: canGoMonthBack ? () => _handleMonthChangeRequest(-1) : null,
                                    color: canGoMonthBack ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.zero,
                                    onPressed: canGoMonthForward ? () => _handleMonthChangeRequest(1) : null,
                                    color: canGoMonthForward ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              _buildDayOfWeekHeader(),
                              Expanded(
                                child: MonthlyCalendarView(
                                  // selectedMonth는 _displayedDate (항상 월의 첫날)로 전달
                                  selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1),
                                  dataService: _dataService,
                                  onDateSelected: (date) {
                                    _switchToWeekViewForDate(date);
                                  },
                                  onChangeMonthBySwipe: _handleMonthChangeRequest, // 스와이프 콜백 연결
                                  canGoBackMonth: canGoMonthBack,       // 이전 달 이동 가능 여부 전달
                                  canGoForwardMonth: canGoMonthForward, // 다음 달 이동 가능 여부 전달
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(child: Text("${_isSelectedToggle[2] ? "Quarter" : "Year"} view not implemented")),
            ),
            if (_isSelectedToggle[0] && _currentWeekChartData.isNotEmpty)
              const ScoreCommentDisplay(),
            if (!_isSelectedToggle[0])
              const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard,
        imagePickerInstance: _picker,
      ),
    );
  }
}