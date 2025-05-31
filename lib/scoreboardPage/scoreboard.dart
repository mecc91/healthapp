// scoreboard.dart
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // 필요시 사용
// import '../nutrientintakePage/nutrientintake.dart'; // 필요시 사용

import 'widgets/scoreboard_period_toggle.dart';
import 'widgets/average_score_display.dart';
import 'widgets/weekly_score_chart.dart';
import 'widgets/score_comment_display.dart';
import 'services/scoreboard_data_service.dart';
// import '../../widgets/common_bottom_navigation_bar.dart'; // 필요시 사용
import 'widgets/monthly_calendar_view.dart';
import 'scoreboard_constants.dart';
// import 'models/daily_intake_model.dart'; // 모델 import는 서비스 파일에서 처리

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final List<bool> _isSelectedToggle = [true, false, false, false]; // 0:주, 1:월, 2:분기, 3:년

  late ScoreboardDataService _dataService;
  List<Map<String, dynamic>> _currentWeekChartData = [];
  Map<int, int> _currentMonthScores = {}; // 일자(int) : 점수(int)

  double _currentAverageScore = 0;
  String _currentDateRangeFormatted = "";
  late DateTime _displayedDate; // 현재 화면에 표시되는 기준 날짜 (주의 시작일 또는 월의 첫날)

  // final ImagePicker _picker = ImagePicker(); // 필요시 사용

  bool _isLoading = true;
  String? _errorMessage;
  String _userId = "TestUser"; // TODO: 실제 사용자 ID로 교체 필요

  @override
  void initState() {
    super.initState();
    // TODO: 실제 사용자 ID를 가져오는 로직으로 대체해야 합니다.
    // 예를 들어, 로그인 정보에서 가져오거나, 상위 위젯에서 전달받을 수 있습니다.
    // _userId = getActualUserId();
    _dataService = ScoreboardDataService(userId: _userId);
    _displayedDate = _dataService.currentWeekStartDate; // 초기 표시는 현재 주의 시작일
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _dataService.fetchAllDataForUser(); // 앱 시작 시 전체 데이터 한 번 로드
      await _loadDataForCurrentSelection(); // 현재 선택된 뷰(주간)에 대한 데이터 로드
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "초기 데이터 로딩 실패: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDataForCurrentSelection() async {
    if (!mounted) return;
    if (!_dataService.isInitialDataFetched && !_isLoading) { // 아직 초기 데이터 로드가 안된 경우 방지
        await _loadInitialData(); // 혹시 모를 상황 대비
        return; // _loadInitialData가 _loadDataForCurrentSelection을 다시 호출할 것임
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSelectedToggle[0]) { // Week
        await _loadDataForWeek(_displayedDate);
      } else if (_isSelectedToggle[1]) { // Month
        await _loadDataForMonth(_displayedDate);
      } else { // Quarter/Year (미구현 상태)
        if (mounted) {
          setState(() {
            _currentWeekChartData = [];
            _currentMonthScores = {};
            _currentAverageScore = 0;
            _currentDateRangeFormatted = _isSelectedToggle[2] ? "분기별 (미구현)" : "연간 (미구현)";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "데이터를 불러오는 중 오류가 발생했습니다: $e";
          _isLoading = false;
        });
      }
      print("Error in _loadDataForCurrentSelection: $e");
    }
  }

  Future<void> _loadDataForWeek(DateTime targetDate) async {
    if (!mounted) return;
    // targetDate는 사용자가 보려는 주의 아무 날짜나 될 수 있음. 주의 시작일로 정규화.
    final weekStartDate = targetDate.subtract(Duration(days: targetDate.weekday - 1));

    final weekData = await _dataService.getWeekData(weekStartDate);
    final averageScore = _dataService.calculateAverageScore(weekData);
    final dateRange = _dataService.formatDateRange(weekStartDate);

    if (mounted) {
      setState(() {
        _displayedDate = weekStartDate; // 화면 기준 날짜 업데이트
        _currentWeekChartData = weekData;
        _currentAverageScore = averageScore;
        _currentDateRangeFormatted = dateRange;
        _dataService.currentWeekStartDate = weekStartDate; // 서비스의 현재 주도 업데이트
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataForMonth(DateTime targetMonthDate) async {
    if (!mounted) return;
    // targetMonthDate는 해당 월의 아무 날짜나 될 수 있음. 월의 첫날로 정규화.
    final firstDayOfMonth = DateTime(targetMonthDate.year, targetMonthDate.month, 1);

    final monthlyScores = await _dataService.getMonthlyScores(firstDayOfMonth);
    final averageScore = _dataService.calculateAverageMonthlyScore(monthlyScores);
    final monthFormatted = _dataService.formatMonth(firstDayOfMonth);

    if (mounted) {
      setState(() {
        _displayedDate = firstDayOfMonth; // 화면 기준 날짜 업데이트
        _currentMonthScores = monthlyScores;
        _currentAverageScore = averageScore;
        _currentDateRangeFormatted = monthFormatted;
        _dataService.currentSelectedMonth = firstDayOfMonth; // 서비스의 현재 월도 업데이트
        _isLoading = false;
      });
    }
  }

  void _handleWeekChangeRequest(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd);
    final DateTime newDisplayDate = result['newDate'];
    _showSnackBarMessage(result['snackBarMessage']);

    if (result['dateChanged'] || _displayedDate != newDisplayDate) {
      if (mounted) {
        // _displayedDate를 setState로 먼저 변경하여 UI가 즉시 반응하도록 하고,
        // 그 후 데이터를 비동기적으로 로드합니다.
        setState(() {
          _displayedDate = newDisplayDate;
        });
      }
      _loadDataForWeek(newDisplayDate); // 변경된 displayedDate 기준으로 데이터 로드
    }
  }

  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd);
    final DateTime newDisplayMonth = result['newDate']; // 이는 해당 월의 1일
    _showSnackBarMessage(result['snackBarMessage']);

    if (result['dateChanged'] || _displayedDate != newDisplayMonth) {
      if (mounted) {
        setState(() {
          _displayedDate = newDisplayMonth;
        });
      }
      _loadDataForMonth(newDisplayMonth);
    }
  }

  void _showSnackBarMessage(String? message) {
    if (mounted && message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // 이전 스낵바 제거
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;
    if (_isSelectedToggle[index]) return; // 이미 선택된 탭이면 변경 없음

    DateTime newDateToDisplay;
    if (index == 0) { // Week
      // 현재 달력에서 보고 있던 날짜가 있다면 그 날짜가 포함된 주로, 아니면 서비스의 현재 주로
      newDateToDisplay = _dataService.currentWeekStartDate;
    } else if (index == 1) { // Month
      newDateToDisplay = DateTime(_dataService.currentSelectedMonth.year, _dataService.currentSelectedMonth.month, 1);
    } else { // Quarter/Year (미구현)
      newDateToDisplay = _displayedDate; // 일단 현재 날짜 유지
    }

    if (mounted) {
      setState(() {
        for (int i = 0; i < _isSelectedToggle.length; i++) {
          _isSelectedToggle[i] = (i == index);
        }
        _displayedDate = newDateToDisplay; // _displayedDate를 먼저 업데이트
      });
    }
    _loadDataForCurrentSelection(); // 그 후 데이터 로드
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    // 사용자가 달력에서 특정 날짜를 선택하면, 해당 날짜가 포함된 주로 전환
    final newWeekStartDate = date.subtract(Duration(days: date.weekday - 1));
    if (mounted) {
      setState(() {
        _isSelectedToggle[0] = true; // 주간 탭 활성화
        _isSelectedToggle[1] = false;
        _isSelectedToggle[2] = false;
        _isSelectedToggle[3] = false;
        _displayedDate = newWeekStartDate; // _displayedDate 업데이트
      });
    }
    _loadDataForWeek(newWeekStartDate); // 해당 주의 데이터 로드
  }

  Widget _buildDayOfWeekHeader() {
    // dayNamesKorean은 일요일부터 시작 ['일', '월', ..., '토']
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayNamesKorean.map((day) {
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

    if (_dataService.isInitialDataFetched) { // 초기 데이터 로드 후 경계 계산
        if (_isSelectedToggle[0]) { // 주간 뷰
        canGoWeekBack = _displayedDate.isAfter(_dataService.oldestWeekStartDate);
        canGoWeekForward = _displayedDate.isBefore(_dataService.newestWeekStartDate);
        } else if (_isSelectedToggle[1]) { // 월간 뷰
            DateTime oldestMonthBoundary = DateTime(DateTime.now().year - 2, 1, 1); // 예시
            DateTime newestMonthBoundary = DateTime(DateTime.now().year + 1, 12, 1); // 예시
            DateTime currentMonthStart = DateTime(_displayedDate.year, _displayedDate.month, 1);

            canGoMonthBack = currentMonthStart.isAfter(oldestMonthBoundary);
            canGoMonthForward = currentMonthStart.isBefore(newestMonthBoundary);
        }
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
                print("Detail button pressed. User ID: $_userId");
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => NutrientIntakeScreen(userId: _userId)), // userId 전달
                // );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: _isSelectedToggle[1] ? 9 : 6, // 월간 뷰일 때 더 많은 공간
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,
                            ),
                          ))
                      : _isSelectedToggle[0] // 주간 뷰
                          ? WeeklyScoreChart(
                              weekData: _currentWeekChartData,
                              onChangeWeek: _handleWeekChangeRequest,
                              canGoBack: canGoWeekBack,
                              canGoForward: canGoWeekForward,
                            )
                          : _isSelectedToggle[1] // 월간 뷰
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
                                          // 현재 월 표시 (선택적)
                                          // Text(_dataService.formatMonth(_displayedDate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                          selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1),
                                          dataService: _dataService,
                                          onDateSelected: _switchToWeekViewForDate,
                                          onChangeMonthBySwipe: _handleMonthChangeRequest,
                                          canGoBackMonth: canGoMonthBack,
                                          canGoForwardMonth: canGoMonthForward,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(child: Text("${_isSelectedToggle[2] ? "분기별" : "연간"} 뷰는 아직 구현되지 않았습니다.", style: const TextStyle(fontSize: 16))),
            ),
            // 주간 코멘트는 주간 뷰이고, 로딩/에러가 아닐 때만 표시
            if (_isSelectedToggle[0] && _currentWeekChartData.isNotEmpty && !_isLoading && _errorMessage == null)
              const ScoreCommentDisplay(),
            if (!_isSelectedToggle[0]) // 주간 뷰가 아닐 때는 하단 여백
              const SizedBox(height: 10),
          ],
        ),
      ),
      // bottomNavigationBar: CommonBottomNavigationBar( // 필요시 사용
      //   currentPage: AppPage.scoreboard,
      //   imagePickerInstance: _picker,
      // ),
    );
  }
}
