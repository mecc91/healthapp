// lib/nutrientintakePage/nutrient_intake_screen.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/scoreboardPage/widgets/scoreboard_period_toggle.dart'; // Reusing
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart';
import 'nutrient_intake_constants.dart';
import 'services/nutrient_intake_data_service.dart';
import 'widgets/nutrient_selector_button.dart';
import 'widgets/nutrient_weekly_chart.dart';
import 'widgets/nutrient_comment_display.dart';

class NutrientIntakeScreen extends StatefulWidget {
  const NutrientIntakeScreen({super.key});

  @override
  State<NutrientIntakeScreen> createState() => _NutrientIntakeScreenState();
}

class _NutrientIntakeScreenState extends State<NutrientIntakeScreen> {
  final NutrientIntakeDataService _dataService = NutrientIntakeDataService();
  final List<bool> _isSelectedPeriod = [true, false, false, false]; // week, month, quarter, year
  List<Map<String, dynamic>> _currentChartData = [];
  String _currentDateRangeFormatted = "";
  String _currentNutrientName = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _currentChartData = _dataService.getCurrentNutrientWeekData();
      _currentDateRangeFormatted = _dataService.formatDateRange(_dataService.currentWeekStartDate);
      _currentNutrientName = _dataService.getCurrentNutrientName();
    });
  }

  void _onPeriodToggleChanged(int index) {
    setState(() {
      for (int i = 0; i < _isSelectedPeriod.length; i++) {
        _isSelectedPeriod[i] = (i == index);
      }
    });

    if (index == 0) { // 'week' selected
      _dataService.resetToCurrentWeekAndDefaultNutrient(); // 수정된 부분: public 메소드 호출
      _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getPeriodName(index)} 데이터 표시는 아직 구현되지 않았습니다.')),
        );
      }
      setState(() {
        _currentChartData = []; 
        _currentDateRangeFormatted = "${_getPeriodName(index)} 데이터 (미구현)";
      });
    }
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

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }
    if (dateActuallyChanged) {
      _loadData();
    }
  }

  void _handleChangeNutrient(int indexOffset) {
    _dataService.changeNutrient(indexOffset);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
            if (_isSelectedPeriod[0]) 
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
              flex: 6,
              child: NutrientWeeklyChart(
                weekData: _currentChartData,
                onChangeWeek: _handleChangeWeek,
                onChangeNutrientViaSwipe: _handleChangeNutrient,
                canGoBack: _dataService.canGoBack,
                canGoForward: _dataService.canGoForward,
                isWeekPeriodSelected: _isSelectedPeriod[0],
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              flex: 1,
              child: NutrientCommentDisplay(
                nutrientName: _currentNutrientName,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard, 
      ),
    );
  }
}