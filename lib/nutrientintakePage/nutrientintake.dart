// lib/nutrientintakePage/nutrient_intake_screen.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/scoreboardPage/widgets/scoreboard_period_toggle.dart'; // Reusing
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart';
import 'nutrient_intake_constants.dart';
import 'services/nutrient_intake_data_service.dart';
import 'widgets/nutrient_selector_button.dart';
import 'widgets/nutrient_weekly_chart.dart';
import 'widgets/nutrient_comment_display.dart';
import 'widgets/nutrient_monthly_calendar_view.dart'; // Import new monthly calendar
import '../../scoreboardPage/scoreboard_constants.dart'; // For dayNamesKorean

class NutrientIntakeScreen extends StatefulWidget {
  const NutrientIntakeScreen({super.key});

  @override
  State<NutrientIntakeScreen> createState() => _NutrientIntakeScreenState();
}

class _NutrientIntakeScreenState extends State<NutrientIntakeScreen> {
  final NutrientIntakeDataService _dataService = NutrientIntakeDataService();
  final List<bool> _isSelectedPeriod = [true, false, false, false]; // week, month, quarter, year

  // State for weekly view
  List<Map<String, dynamic>> _currentWeekChartData = [];

  // State for monthly view
  Map<int, int> _currentMonthNutrientData = {};
  // double _currentAverageMonthlyIntake = 0.0; // Optional: if you want to display this

  // Common state
  late DateTime _displayedDate; // Manages the current date context for week or month
  String _currentDateRangeFormatted = "";
  String _currentNutrientName = "";

  @override
  void initState() {
    super.initState();
    _displayedDate = _dataService.currentWeekStartDate; // Initialize with current week
    _loadDataForCurrentSelection();
  }

  void _loadDataForCurrentSelection() {
    if (!mounted) return;

    _currentNutrientName = _dataService.getCurrentNutrientName();

    if (_isSelectedPeriod[0]) { // Week selected
      _loadDataForWeek(_displayedDate);
    } else if (_isSelectedPeriod[1]) { // Month selected
      _loadDataForMonth(_displayedDate);
    } else {
      // Handle other periods (Quarter/Year) if implemented
      setState(() {
        _currentWeekChartData = [];
        _currentMonthNutrientData = {};
        _currentDateRangeFormatted = "${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 (미구현)";
      });
    }
  }

  void _loadDataForWeek(DateTime startDate) {
    if (!mounted) return;
    // Ensure startDate is the beginning of a week if it's not already
    final weekStartDate = startDate.subtract(Duration(days: startDate.weekday - 1));
    _dataService.currentWeekStartDate = weekStartDate; // Update service's current week

    setState(() {
      _displayedDate = weekStartDate;
      _currentWeekChartData = _dataService.getCurrentNutrientWeekData(); // Uses service's currentWeekStartDate
      _currentDateRangeFormatted = _dataService.formatDateRange(weekStartDate);
      // _currentNutrientName is already set in _loadDataForCurrentSelection
    });
  }

  void _loadDataForMonth(DateTime monthDate) {
    if (!mounted) return;
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    _dataService.currentSelectedMonth = firstDayOfMonth; // Update service's current month

    setState(() {
      _displayedDate = firstDayOfMonth;
      _currentMonthNutrientData = _dataService.getNutrientDataForMonth(firstDayOfMonth, _currentNutrientName);
      // _currentAverageMonthlyIntake = _dataService.calculateAverageMonthlyNutrientIntake(_currentMonthNutrientData); // Optional
      _currentDateRangeFormatted = _dataService.formatMonth(firstDayOfMonth);
      // _currentNutrientName is already set in _loadDataForCurrentSelection
    });
  }

  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;

    DateTime newDateToDisplay;
    if (index == 0) { // Week
      newDateToDisplay = _dataService.currentWeekStartDate;
    } else if (index == 1) { // Month
      newDateToDisplay = _dataService.currentSelectedMonth;
    } else {
      // For Quarter/Year, decide on a default display date or logic
      newDateToDisplay = _displayedDate; // Keep current for now
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
      _displayedDate = newDateToDisplay;
    });
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
    final DateTime newDisplayDate = result['newDate'];

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged || _displayedDate != newDisplayDate) {
      _loadDataForWeek(newDisplayDate); // This will call setState
    }
  }

  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd);
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];
    final DateTime newDisplayMonth = result['newDate'];

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged || _displayedDate != newDisplayMonth) {
       _loadDataForMonth(newDisplayMonth); // This will call setState
    }
  }


  void _handleChangeNutrient(int indexOffset) {
    _dataService.changeNutrient(indexOffset);
    _loadDataForCurrentSelection(); // Reloads data for the currently selected period and new nutrient
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    final newWeekStartDate = date.subtract(Duration(days: date.weekday - 1));
    setState(() {
      _isSelectedPeriod[0] = true; // Switch to week
      _isSelectedPeriod[1] = false;
      _isSelectedPeriod[2] = false;
      _isSelectedPeriod[3] = false;
      _displayedDate = newWeekStartDate;
    });
    _loadDataForWeek(newWeekStartDate);
  }

  Widget _buildDayOfWeekHeader() {
    const List<String> displayDayNames = dayNamesKorean; // 일 월 화 수 목 금 토
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), // Adjusted horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: displayDayNames.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    fontSize: 11, // Slightly smaller
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
    if (_isSelectedPeriod[1]) { // Only relevant for month view
        canGoMonthBack = _dataService.canGoBackMonth;
        canGoMonthForward = _dataService.canGoForwardMonth;
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
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScoreboardPeriodToggle(
              isSelected: _isSelectedPeriod,
              onPressed: _onPeriodToggleChanged,
            ),
            const SizedBox(height: 8),
            // Date Range Display - shows for week or month
            if (_isSelectedPeriod[0] || _isSelectedPeriod[1])
              Text(
                _currentDateRangeFormatted,
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),
            NutrientSelectorButton(
              selectedNutrientName: _currentNutrientName,
              onPressed: () => _handleChangeNutrient(1),
              buttonWidth: screenSize.width - (16.0 * 2),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: _isSelectedPeriod[1] ? 9 : 6, // More flex for month view if needed
              child: _isSelectedPeriod[0] // WEEK VIEW
                  ? NutrientWeeklyChart(
                      weekData: _currentWeekChartData,
                      onChangeWeek: _handleChangeWeek,
                      onChangeNutrientViaSwipe: _handleChangeNutrient, // 주간 차트의 영양소 변경
                      canGoBack: _dataService.canGoBackWeek,
                      canGoForward: _dataService.canGoForwardWeek,
                      isWeekPeriodSelected: _isSelectedPeriod[0],
                    )
                  : _isSelectedPeriod[1] // MONTH VIEW
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0), // Reduced vertical padding
                          decoration: BoxDecoration(
                            color: kNutrientIntakeGraphBackgroundColor, // Match weekly chart background
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Padding( // Padding for month navigation row
                                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0), // Reduced padding
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      iconSize: 30.0,
                                      padding: EdgeInsets.zero, // Compact
                                      constraints: const BoxConstraints(), // Compact
                                      onPressed: canGoMonthBack ? () => _handleMonthChangeRequest(-1) : null,
                                      color: canGoMonthBack ? Colors.grey.shade700 : Colors.grey.shade300,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      iconSize: 30.0,
                                      padding: EdgeInsets.zero, // Compact
                                      constraints: const BoxConstraints(), // Compact
                                      onPressed: canGoMonthForward ? () => _handleMonthChangeRequest(1) : null,
                                      color: canGoMonthForward ? Colors.grey.shade700 : Colors.grey.shade300,
                                    ),
                                  ],
                                ),
                              ),
                              _buildDayOfWeekHeader(),
                              Expanded(
                                child: NutrientMonthlyCalendarView(
                                  selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1),
                                  monthlyNutrientData: _currentMonthNutrientData,
                                  dataService: _dataService,
                                  onDateSelected: (date) {
                                     _switchToWeekViewForDate(date);
                                  },
                                  onChangeMonthBySwipe: _handleMonthChangeRequest,
                                  onChangeNutrientBySwipe: _handleChangeNutrient, // ✅ 월간 달력의 영양소 변경 연결
                                  canGoBackMonth: canGoMonthBack,
                                  canGoForwardMonth: canGoMonthForward,
                                  currentNutrientName: _currentNutrientName,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(child: Text("${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 표시는 아직 구현되지 않았습니다.")),
            ),
            const SizedBox(height: 10),
            Flexible( // Keep comment display flexible
              flex: 1,
              child: NutrientCommentDisplay(
                nutrientName: _currentNutrientName,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard, // Or adjust as per actual navigation context
      ),
    );
  }
}
