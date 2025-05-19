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
import 'scoreboard_constants.dart'; // For dayNamesKorean

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
      _displayedDate = firstDayOfMonth;
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
    if (result['dateChanged'] || _displayedDate != newDisplayDate) {
        _loadDataForWeek(newDisplayDate);
    }
  }

  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd);
    final DateTime newDisplayMonth = result['newDate'];
     _showSnackBarMessage(result['snackBarMessage']);
    final firstOfNewDisplayMonth = DateTime(newDisplayMonth.year, newDisplayMonth.month, 1);
    if (result['dateChanged'] || _displayedDate != firstOfNewDisplayMonth ) {
      _loadDataForMonth(firstOfNewDisplayMonth);
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
    setState(() {
      for (int i = 0; i < _isSelectedToggle.length; i++) {
        _isSelectedToggle[i] = (i == index);
      }
      if (index == 0) { 
        _displayedDate = _dataService.currentWeekStartDate;
      } else if (index == 1) { 
        _displayedDate = DateTime(_dataService.currentSelectedMonth.year, _dataService.currentSelectedMonth.month, 1);
      }
    });
    _loadDataForCurrentSelection();
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    setState(() {
      _isSelectedToggle[0] = true;
      _isSelectedToggle[1] = false;
      _isSelectedToggle[2] = false;
      _isSelectedToggle[3] = false;
      _displayedDate = date.subtract(Duration(days: date.weekday - 1));
    });
    _loadDataForWeek(_displayedDate);
  }

  // Helper widget to build the day of week header for the calendar
  Widget _buildDayOfWeekHeader() {
    // Using dayNamesKorean as defined in scoreboard_constants.dart
    // Ensure this list matches the visual start of your week (e.g., Sunday-first)
    const List<String> displayDayNames = dayNamesKorean;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Add some horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: displayDayNames.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    fontSize: 12, // Adjusted size
                    fontWeight: FontWeight.bold,
                    color: Colors.black54), // Adjusted color
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool canGoBack = true;
    bool canGoForward = true;

    if (_isSelectedToggle[0]) {
      canGoBack = _displayedDate.isAfter(_dataService.oldestWeekStartDate);
      canGoForward = _displayedDate.isBefore(_dataService.newestWeekStartDate.add(const Duration(days: 1)));
    } else if (_isSelectedToggle[1]) {
        DateTime now = DateTime.now();
        DateTime oldestMonth = DateTime(now.year - 2, 1, 1);
        DateTime newestMonth = DateTime(now.year + 1, 12, 1);
        DateTime currentMonthStart = DateTime(_displayedDate.year, _displayedDate.month, 1);

        canGoBack = currentMonthStart.isAfter(oldestMonth);
        // Allow going forward if current month is before or the same as newestMonth
        canGoForward = currentMonthStart.isBefore(newestMonth) || currentMonthStart.isAtSameMomentAs(newestMonth);
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
                  ? WeeklyScoreChart( // This widget already has its own internal padding and box decoration
                      weekData: _currentWeekChartData,
                      onChangeWeek: _handleWeekChangeRequest,
                      canGoBack: canGoBack,
                      canGoForward: canGoForward,
                    )
                  : _isSelectedToggle[1]
                      ? Container( // Box container for the calendar
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Inner padding for the box content
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200, // Similar to WeeklyScoreChart
                            borderRadius: BorderRadius.circular(16), // Similar to WeeklyScoreChart
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 30.0, // Adjusted size
                                    padding: EdgeInsets.zero,
                                    onPressed: canGoBack ? () => _handleMonthChangeRequest(-1) : null,
                                    color: canGoBack ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  // Month name is already in AverageScoreDisplay
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    iconSize: 30.0, // Adjusted size
                                    padding: EdgeInsets.zero,
                                    onPressed: canGoForward ? () => _handleMonthChangeRequest(1) : null,
                                    color: canGoForward ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              _buildDayOfWeekHeader(), // 요일 헤더 추가
                              Expanded(
                                child: MonthlyCalendarView(
                                  selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1),
                                  dataService: _dataService,
                                  onDateSelected: (date) {
                                    _switchToWeekViewForDate(date);
                                  },
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