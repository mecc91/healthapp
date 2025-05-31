// widgets/monthly_calendar_view.dart
import 'package:flutter/material.dart';
import '../services/scoreboard_data_service.dart'; // ScoreboardDataService 사용
// import '../models/daily_intake_model.dart'; // DailyIntake 모델은 서비스에서 처리

class MonthlyCalendarView extends StatefulWidget {
  final DateTime selectedMonth; // 현재 선택/표시된 월 (항상 해당 월의 1일)
  final ScoreboardDataService dataService; // 데이터를 가져오기 위해 필요
  final Function(DateTime) onDateSelected; // 날짜 선택 시 콜백
  final Function(int) onChangeMonthBySwipe; // 스와이프로 월 변경 시 콜백
  final bool canGoBackMonth; // 이전 달 이동 가능 여부
  final bool canGoForwardMonth; // 다음 달 이동 가능 여부

  const MonthlyCalendarView({
    super.key,
    required this.selectedMonth,
    required this.dataService,
    required this.onDateSelected,
    required this.onChangeMonthBySwipe,
    required this.canGoBackMonth,
    required this.canGoForwardMonth,
  });

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<int, int> _currentMonthScoresData = {}; // 일자(int) : 점수(int)
  bool _isCalendarLoading = true;
  String? _calendarErrorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // 애니메이션 속도 조절
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2), // 슬라이드 시작 위치 조절
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadCalendarData(); // 위젯 초기화 시 데이터 로드

    // 애니메이션 시작은 데이터 로드 후 또는 build 메서드에서 조건부로 실행 가능
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted && !_isCalendarLoading) { // 데이터 로드 후 애니메이션 시작
    //     _animationController.forward();
    //   }
    // });
  }

  @override
  void didUpdateWidget(covariant MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 선택된 달이 변경되면 애니메이션과 함께 데이터 다시 로드
    if (oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month) {
      if (mounted) {
        _animationController.reset(); // 애니메이션 리셋
        _loadCalendarData(); // 데이터 다시 로드
      }
    }
  }

  Future<void> _loadCalendarData() async {
    if (!mounted) return;
    setState(() {
      _isCalendarLoading = true;
      _calendarErrorMessage = null;
    });
    try {
      final scores = await widget.dataService.getMonthlyScores(widget.selectedMonth);
      if (mounted) {
        setState(() {
          _currentMonthScoresData = scores;
          _isCalendarLoading = false;
        });
        _animationController.forward(from: 0.0); // 데이터 로드 후 애니메이션 시작
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _calendarErrorMessage = "달력 데이터 로딩 실패";
          _isCalendarLoading = false;
        });
      }
      print("Error loading calendar data: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyScoresToUse = _currentMonthScoresData;
    final daysInMonth = DateUtils.getDaysInMonth(widget.selectedMonth.year, widget.selectedMonth.month);
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    // DateTime.weekday: 월요일(1) ~ 일요일(7)
    // dayNamesKorean은 일요일(0) ~ 토요일(6) 인덱스를 사용하므로 변환 필요
    final emptyCellsPrefix = (firstDayOfMonth.weekday == 7) ? 0 : firstDayOfMonth.weekday;

    if (_isCalendarLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
    }
    if (_calendarErrorMessage != null) {
        return Center(child: Text(_calendarErrorMessage!, style: const TextStyle(color: Colors.red)));
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) { // 오른쪽으로 스와이프 (이전 달)
          if (widget.canGoBackMonth) {
            widget.onChangeMonthBySwipe(-1);
          }
        } else if (details.primaryVelocity! < -100) { // 왼쪽으로 스와이프 (다음 달)
          if (widget.canGoForwardMonth) {
            widget.onChangeMonthBySwipe(1);
          }
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // 부모 스크롤 사용
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 요일 수
              childAspectRatio: 1.0, // 셀의 가로세로 비율
              mainAxisSpacing: 1.0, // 셀 간의 수직 간격
              crossAxisSpacing: 1.0, // 셀 간의 수평 간격
            ),
            itemCount: daysInMonth + emptyCellsPrefix,
            itemBuilder: (context, index) {
              if (index < emptyCellsPrefix) {
                return Container(); // 이전 달의 빈 셀 채우기
              }

              final dayNumber = index - emptyCellsPrefix + 1;
              final currentDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber);
              final score = monthlyScoresToUse[dayNumber] ?? 0; // 해당 날짜의 점수, 없으면 0

              // 오늘 날짜인지 확인
              final bool isToday = DateUtils.isSameDay(currentDate, DateTime.now());

              return GestureDetector(
                onTap: () => widget.onDateSelected(currentDate),
                child: Container(
                  margin: const EdgeInsets.all(1.0), // 셀 간의 아주 작은 간격
                  decoration: BoxDecoration(
                    // 오늘 날짜 강조
                    border: isToday
                        ? Border.all(color: Theme.of(context).primaryColorDark, width: 1.5)
                        : Border.all(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(4.0),
                    // 점수에 따라 배경색 동적 변경 (0점은 흰색, 점수 높을수록 진하게)
                    color: score > 0
                        ? Colors.teal.withAlpha(((score / 100) * 200 + 55).clamp(0, 255).round()) // 점수(0~100)를 alpha(55~255)로 매핑
                        : Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber', // 날짜
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                            color: score > 60 ? Colors.white : (isToday ? Theme.of(context).primaryColorDark : Colors.black87),
                          ),
                        ),
                        if (score > 0) // 점수가 있을 때만 표시
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '$score', // 점수
                              style: TextStyle(
                                fontSize: 9,
                                color: score > 60 ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
