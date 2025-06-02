// lib/nutrientintakePage/nutrient_intake_screen.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/scoreboardPage/widgets/scoreboard_period_toggle.dart'; //
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart'; //
import 'nutrient_intake_constants.dart'; //
import 'services/nutrient_intake_data_service.dart'; //
import 'widgets/nutrient_selector_button.dart'; //
import 'widgets/nutrient_weekly_chart.dart'; //
import 'widgets/nutrient_comment_display.dart'; //
import 'widgets/nutrient_monthly_calendar_view.dart'; //

class NutrientIntakeScreen extends StatefulWidget {
  final String userId;

  const NutrientIntakeScreen({super.key, required this.userId}); //

  @override
  State<NutrientIntakeScreen> createState() => _NutrientIntakeScreenState();
}

class _NutrientIntakeScreenState extends State<NutrientIntakeScreen> {
  late NutrientIntakeDataService _dataService; //
  final List<bool> _isSelectedPeriod = [true, false, false, false]; //

  List<Map<String, dynamic>> _currentWeekChartData = []; //
  // 월간 데이터 타입을 Map<int, int>에서 Map<int, double>로 변경하고 변수명 변경
  Map<int, double> _currentMonthNutrientData = {}; //

  late DateTime _displayedDate; //
  String _currentDateRangeFormatted = ""; //
  String _currentNutrientNameForComment = ""; //

  bool _isLoading = true; //
  String _loadingError = ""; //

  @override
  void initState() {
    super.initState();
    _dataService = NutrientIntakeDataService(userId: widget.userId); //
    _displayedDate = _dataService.currentWeekStartDate; //
    _fetchAllDataAndLoadUI(); //
  }

  Future<void> _fetchAllDataAndLoadUI() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; //
      _loadingError = ""; //
    });
    try {
      await _dataService.fetchAllDailyIntakes(); //
      _loadDataForCurrentSelection(); //
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = e.toString().replaceFirst("Exception: ", ""); //
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; //
        });
      }
    }
  }

  void _loadDataForCurrentSelection() {
    if (!mounted) return;
    _currentNutrientNameForComment = _dataService.getCurrentNutrientName(); //

    if (_isSelectedPeriod[0]) { //
      _loadDataForWeek(_dataService.currentWeekStartDate); //
    } else if (_isSelectedPeriod[1]) { //
      _loadDataForMonth(_dataService.currentSelectedMonth); //
    } else { //
      setState(() {
        _currentWeekChartData = []; //
        _currentMonthNutrientData = {}; // _currentMonthScoreData에서 변경
        _currentDateRangeFormatted = "${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 (미구현)"; //
      });
    }
  }

  void _loadDataForWeek(DateTime dateForWeek) {
    if (!mounted) return;
    _dataService.setCurrentWeekFromDate(dateForWeek); //
    final weekStartDate = _dataService.currentWeekStartDate; //
    final String currentNutrientKey = _dataService.getCurrentNutrientName(); //

    setState(() {
      _displayedDate = weekStartDate; //
      _currentWeekChartData = _dataService.getNutrientIntakeForWeek(weekStartDate, currentNutrientKey); //
      _currentDateRangeFormatted = _dataService.formatDateRange(weekStartDate); //
      _currentNutrientNameForComment = currentNutrientKey; //
    });
  }

  // _loadDataForMonth 수정
  void _loadDataForMonth(DateTime monthDate) {
    if (!mounted) return;
    final firstDayOfMonth = _dataService.currentSelectedMonth = DateTime(monthDate.year, monthDate.month, 1); //
    final String currentNutrientKey = _dataService.getCurrentNutrientName(); // 현재 선택된 영양소 키

    setState(() {
      _displayedDate = firstDayOfMonth; //
      // getNutrientIntakeForMonth 호출로 변경하고, _currentMonthNutrientData에 저장
      _currentMonthNutrientData = _dataService.getNutrientIntakeForMonth(firstDayOfMonth, currentNutrientKey); //
      _currentDateRangeFormatted = _dataService.formatMonth(firstDayOfMonth); //
      _currentNutrientNameForComment = currentNutrientKey; //
    });
  }

  void _onPeriodToggleChanged(int index) {
    if (!mounted) return;
    if (_isSelectedPeriod[index] && !_isLoading) return; //

    DateTime newDateToDisplay; //
    if (index == 0) { //
      newDateToDisplay = _dataService.currentWeekStartDate; //
    } else if (index == 1) { //
      newDateToDisplay = _dataService.currentSelectedMonth; //
    } else { //
      newDateToDisplay = _displayedDate; //
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( //
          SnackBar(content: Text('${_getPeriodName(index)} 데이터 표시는 아직 구현되지 않았습니다.')), //
        );
      }
    }

    setState(() {
      for (int i = 0; i < _isSelectedPeriod.length; i++) {
        _isSelectedPeriod[i] = (i == index); //
      }
      _displayedDate = newDateToDisplay; //
    });
    _loadDataForCurrentSelection(); //
  }

  String _getPeriodName(int index) {
    if (index == 1) return "월간"; //
    if (index == 2) return "분기별"; //
    if (index == 3) return "연간"; //
    return "주간"; //
  }

  void _handleChangeWeek(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd); //
    final String? snackBarMessage = result['snackBarMessage']; //
    final bool dateActuallyChanged = result['dateChanged']; //
    final DateTime newDisplayDate = _dataService.currentWeekStartDate; //

    if (mounted && snackBarMessage != null) { //
      ScaffoldMessenger.of(context).showSnackBar( //
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)), //
      );
    }
    if (dateActuallyChanged) { //
      _loadDataForWeek(newDisplayDate); //
    }
  }

  void _handleMonthChangeRequest(int monthsToAdd) {
    final result = _dataService.changeMonth(monthsToAdd); //
    final String? snackBarMessage = result['snackBarMessage']; //
    final bool dateActuallyChanged = result['dateChanged']; //
    final DateTime newDisplayMonth = _dataService.currentSelectedMonth; //

    if (mounted && snackBarMessage != null) { //
      ScaffoldMessenger.of(context).showSnackBar( //
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)), //
      );
    }
    if (dateActuallyChanged) { //
       _loadDataForMonth(newDisplayMonth); //
    }
  }

  // _handleChangeNutrient 수정
  void _handleChangeNutrient(int indexOffset) {
    _dataService.changeNutrient(indexOffset); //
    final newNutrientName = _dataService.getCurrentNutrientName(); //
    if(mounted) {
      setState(() {
        _currentNutrientNameForComment = newNutrientName; //
      });
      // 현재 활성화된 뷰의 데이터를 새로운 영양소 기준으로 다시 로드
      if (_isSelectedPeriod[0]) { // 주간 보기 활성 시 //
        _loadDataForWeek(_displayedDate); //
      } else if (_isSelectedPeriod[1]) { // 월간 보기 활성 시 //
        _loadDataForMonth(_displayedDate); // 월간 데이터도 새로운 영양소 기준으로 다시 로드
      }
    }
  }

  void _switchToWeekViewForDate(DateTime date) {
    if (!mounted) return;
    setState(() {
      _isSelectedPeriod[0] = true; //
      _isSelectedPeriod[1] = false; //
      _isSelectedPeriod[2] = false; //
      _isSelectedPeriod[3] = false; //
    });
    _loadDataForWeek(date); //
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; //

    bool canGoMonthBack = false; //
    bool canGoMonthForward = false; //
    if (_isSelectedPeriod[1]) { //
        canGoMonthBack = _dataService.canGoBackMonth; //
        canGoMonthForward = _dataService.canGoForwardMonth; //
    }

    Widget bodyContent; //
    if (_isLoading) { //
      bodyContent = const Center(child: Column( //
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(), //
          SizedBox(height: 16), //
          Text(kLoadingData), //
        ],
      ));
    } else if (_loadingError.isNotEmpty) { //
      bodyContent = Center( //
        child: Padding( //
          padding: const EdgeInsets.all(16.0), //
          child: Column( //
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48), //
              const SizedBox(height: 16), //
              Text(_loadingError, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)), //
              const SizedBox(height: 24), //
              ElevatedButton( //
                  onPressed: _fetchAllDataAndLoadUI, //
                  child: const Text("다시 시도")) //
            ],
          ),
        ),
      );
    } else { //
      bodyContent = Column( //
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScoreboardPeriodToggle( //
            isSelected: _isSelectedPeriod, //
            onPressed: _onPeriodToggleChanged, //
          ),
          const SizedBox(height: 8), //
          if (_isSelectedPeriod[0] || _isSelectedPeriod[1]) //
            Text( //
              _currentDateRangeFormatted, //
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold), //
            ),
          const SizedBox(height: 12), //
          NutrientSelectorButton( //
            selectedNutrientName: _currentNutrientNameForComment, //
            onPressed: () => _handleChangeNutrient(1), //
            buttonWidth: screenSize.width - (16.0 * 2), //
          ),
          const SizedBox(height: 12), //
          Expanded( //
            flex: _isSelectedPeriod[1] ? 9 : 6, //
            child: _isSelectedPeriod[0] //
                ? NutrientWeeklyChart( //
                    weekData: _currentWeekChartData, //
                    onChangeWeek: _handleChangeWeek, //
                    onChangeNutrientViaSwipe: _handleChangeNutrient, //
                    canGoBack: _dataService.canGoBackWeek, //
                    canGoForward: _dataService.canGoForwardWeek, //
                    isWeekPeriodSelected: _isSelectedPeriod[0], //
                  )
                : _isSelectedPeriod[1] //
                    ? Container( //
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0), //
                        decoration: BoxDecoration( //
                          color: kNutrientIntakeGraphBackgroundColor, //
                          borderRadius: BorderRadius.circular(16), //
                        ),
                        child: Column( //
                          children: [
                            Padding( //
                              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0), //
                              child: Row( //
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton( //
                                    icon: const Icon(Icons.chevron_left), //
                                    iconSize: 30.0, //
                                    padding: EdgeInsets.zero, //
                                    constraints: const BoxConstraints(), //
                                    onPressed: canGoMonthBack ? () => _handleMonthChangeRequest(-1) : null, //
                                    color: canGoMonthBack ? Colors.grey.shade700 : Colors.grey.shade300, //
                                  ),
                                  IconButton( //
                                    icon: const Icon(Icons.chevron_right), //
                                    iconSize: 30.0, //
                                    padding: EdgeInsets.zero, //
                                    constraints: const BoxConstraints(), //
                                    onPressed: canGoMonthForward ? () => _handleMonthChangeRequest(1) : null, //
                                    color: canGoMonthForward ? Colors.grey.shade700 : Colors.grey.shade300, //
                                  ),
                                ],
                              ),
                            ),
                            Expanded( //
                              child: NutrientMonthlyCalendarView( //
                                selectedMonth: DateTime(_displayedDate.year, _displayedDate.month, 1), //
                                monthlyNutrientData: _currentMonthNutrientData, // _currentMonthScoreData에서 변경
                                dataService: _dataService, //
                                onDateSelected: (date) { //
                                   _switchToWeekViewForDate(date); //
                                },
                                onChangeMonthBySwipe: _handleMonthChangeRequest, //
                                onChangeNutrientBySwipe: _handleChangeNutrient, //
                                canGoBackMonth: canGoMonthBack, //
                                canGoForwardMonth: canGoMonthForward, //
                                currentNutrientName: _currentNutrientNameForComment, //
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(child: Text("${_getPeriodName(_isSelectedPeriod.indexWhere((e) => e))} 데이터 표시는 아직 구현되지 않았습니다.")), //
          ),
          const SizedBox(height: 10), //
          Flexible( //
            flex: _isSelectedPeriod[1] ? 1 : 2, //
            fit: FlexFit.loose, //
            child: NutrientCommentDisplay( //
              nutrientName: _currentNutrientNameForComment, //
            ),
          ),
        ],
      );
    }

    return Scaffold( //
      appBar: AppBar( //
        leading: IconButton( //
          icon: const Icon(Icons.arrow_back, color: Colors.black), //
          onPressed: () => Navigator.of(context).pop(), //
        ),
        title: const Text(kAppBarTitle, style: TextStyle(fontWeight: FontWeight.bold)), //
        centerTitle: true, //
        backgroundColor: Colors.white, //
        foregroundColor: Colors.black, //
        elevation: 0, //
      ),
      body: Padding( //
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), //
        child: bodyContent, //
      ),
      bottomNavigationBar: const CommonBottomNavigationBar( //
        currentPage: AppPage.scoreboard, //
      ),
    );
  }
}