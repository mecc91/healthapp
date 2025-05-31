import 'package:flutter/material.dart';

import '../services/scoreboard_data_service.dart';


class MonthlyCalendarView extends StatefulWidget {
  final DateTime selectedMonth;
  final ScoreboardDataService dataService;
  final Function(DateTime) onDateSelected;
  final Function(int) onChangeMonthBySwipe; // 스와이프로 월 변경 콜백
  final bool canGoBackMonth;
  final bool canGoForwardMonth;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // weekly_score_chart와 유사한 지속 시간
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3), // 아래에서 위로 슬라이드
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 초기 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 선택된 달이 변경되면 애니메이션 다시 시작
    if (oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month) {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyScores = widget.dataService.getScoresForMonth(widget.selectedMonth);
    final daysInMonth = DateUtils.getDaysInMonth(widget.selectedMonth.year, widget.selectedMonth.month);
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    final emptyCellsPrefix = firstDayOfMonth.weekday % 7; // 일요일 시작 기준 (0:일, 1:월 ... 6:토)

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
          child: Column(
            children: [
              // 요일 헤더는 ScoreboardScreen에서 외부 박스 안에 위치하므로 여기서는 GridView만 포함
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0, // 셀 비율 (조정 가능)
                  ),
                  itemCount: daysInMonth + emptyCellsPrefix,
                  itemBuilder: (context, index) {
                    if (index < emptyCellsPrefix) {
                      return Container(); // 이전 달의 빈 셀
                    }

                    final dayNumber = index - emptyCellsPrefix + 1;
                    final currentDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber);
                    final score = monthlyScores[dayNumber] ?? 0;

                    return GestureDetector(
                      onTap: () => widget.onDateSelected(currentDate),
                      child: Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4.0),
                          color: score > 0 ? Colors.teal.withAlpha((score * 2.55).round()) : Colors.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: score > 50 ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (score > 0)
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: score > 50 ? Colors.white70 : Colors.black54,
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
            ],
          ),
        ),
      ),
    );
  }
}