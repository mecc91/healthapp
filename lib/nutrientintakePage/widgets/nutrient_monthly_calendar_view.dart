// lib/nutrientintakePage/widgets/nutrient_monthly_calendar_view.dart
import 'package:flutter/material.dart';

import '../services/nutrient_intake_data_service.dart'; // NutrientIntakeDataService (직접 사용은 없으나, 타입 명시용)

class NutrientMonthlyCalendarView extends StatefulWidget {
  final DateTime selectedMonth; // 현재 선택/표시된 월 (해당 월의 첫째 날)
  final Map<int, int> monthlyNutrientData; // 월간 데이터 (Key: 일(day), Value: DailyIntake.score)
  final NutrientIntakeDataService dataService; // 데이터 서비스 객체 (직접 사용은 없으나, 구조상 전달)
  final Function(DateTime) onDateSelected; // 날짜 셀 클릭 시 콜백 (선택된 날짜 전달)
  final Function(int) onChangeMonthBySwipe; // 월 변경 콜백 (monthsToAdd 전달)
  final Function(int) onChangeNutrientBySwipe; // (코멘트용) 영양소 변경 콜백 (indexOffset 전달)
  final bool canGoBackMonth; // 이전 달로 이동 가능 여부
  final bool canGoForwardMonth; // 다음 달로 이동 가능 여부
  final String currentNutrientName; // (코멘트용) 현재 선택된 영양소 이름

  const NutrientMonthlyCalendarView({
    super.key,
    required this.selectedMonth,
    required this.monthlyNutrientData,
    required this.dataService,
    required this.onDateSelected,
    required this.onChangeMonthBySwipe,
    required this.onChangeNutrientBySwipe,
    required this.canGoBackMonth,
    required this.canGoForwardMonth,
    required this.currentNutrientName,
  });

  @override
  State<NutrientMonthlyCalendarView> createState() => _NutrientMonthlyCalendarViewState();
}

class _NutrientMonthlyCalendarViewState extends State<NutrientMonthlyCalendarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // 애니메이션 컨트롤러
  late Animation<double> _fadeAnimation; // Fade-in 애니메이션
  late Animation<Offset> _slideAnimation; // Slide-up 애니메이션

  // 점수 시각화를 위한 색상 (예: 점수가 높을수록 진한 파란색)
  final Color _scoreBaseColor = Colors.blueAccent; // 점수 시각화 기본 색상

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 애니메이션 지속 시간
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2), // 아래에서 약간 위로 슬라이드
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 위젯 빌드 후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant NutrientMonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 선택된 월, 데이터, 또는 (코멘트용) 영양소 이름이 변경되면 애니메이션 다시 시작
    if (oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month ||
        oldWidget.monthlyNutrientData != widget.monthlyNutrientData ||
        oldWidget.currentNutrientName != widget.currentNutrientName) {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 월의 총 일수
    final daysInMonth = DateUtils.getDaysInMonth(widget.selectedMonth.year, widget.selectedMonth.month);
    // 현재 선택된 월의 첫째 날 DateTime 객체
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    // 달력에서 첫째 날 앞에 표시될 빈 셀의 개수 (일요일 시작 기준, weekday: 일=7, 월=1 ... 토=6)
    // (firstDayOfMonth.weekday % 7) -> 월요일이 0, 일요일이 6이 되도록.
    // 한국 달력은 보통 일요일부터 시작하므로, (firstDayOfMonth.weekday % 7) 사용.
    // 만약 월요일부터 시작하는 달력이라면 (firstDayOfMonth.weekday - 1) 사용.
    final emptyCellsPrefix = firstDayOfMonth.weekday % 7;

    return GestureDetector(
      // 가로 스와이프로 월 변경
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200 && widget.canGoBackMonth) { // 오른쪽으로 스와이프 (이전 달)
          widget.onChangeMonthBySwipe(-1);
        } else if (details.primaryVelocity! < -200 && widget.canGoForwardMonth) { // 왼쪽으로 스와이프 (다음 달)
          widget.onChangeMonthBySwipe(1);
        }
      },
      // 세로 스와이프로 (코멘트용) 영양소 변경
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200) { // 아래로 스와이프 (다음 영양소)
          widget.onChangeNutrientBySwipe(1);
        } else if (details.primaryVelocity! < -200) { // 위로 스와이프 (이전 영양소)
          widget.onChangeNutrientBySwipe(-1);
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // 달력 자체는 스크롤되지 않도록
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 일주일은 7일
              childAspectRatio: 0.9, // 각 셀의 가로세로 비율 (숫자가 작을수록 세로로 길어짐)
            ),
            itemCount: daysInMonth + emptyCellsPrefix, // 총 셀 개수 (빈 셀 + 날짜 셀)
            itemBuilder: (context, index) {
              // 첫째 날 이전의 빈 셀 처리
              if (index < emptyCellsPrefix) {
                return Container(); // 빈 컨테이너
              }

              // 실제 날짜 계산 (1일부터 시작)
              final dayNumber = index - emptyCellsPrefix + 1;
              // 현재 셀에 해당하는 DateTime 객체
              final currentDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber);
              // 해당 날짜의 점수 데이터 (없으면 0)
              final scoreValue = widget.monthlyNutrientData[dayNumber] ?? 0;

              Color cellColor = Colors.white; // 기본 셀 배경색
              Color textColor = Colors.black87; // 기본 텍스트 색상
              const double maxScoreForOpacity = 100.0; // 점수 시각화 기준 (예: 100점 만점)

              if (scoreValue > 0) { // 점수가 있을 경우에만 색상 변경
                // 점수에 따라 투명도 조절 (0.15 ~ 1.0 범위)
                double opacity = (scoreValue / maxScoreForOpacity).clamp(0.15, 1.0);
                cellColor = _scoreBaseColor.withAlpha((opacity * 255).round());
                // 배경색이 진해지면 텍스트 색상을 흰색으로 변경하여 가독성 확보
                if (opacity > 0.55) {
                  textColor = Colors.white;
                }
              }

              return GestureDetector(
                onTap: () => widget.onDateSelected(currentDate), // 날짜 셀 클릭 시 콜백 호출
                child: Container(
                  margin: const EdgeInsets.all(2.0), // 셀 간 간격
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5), // 셀 테두리
                    borderRadius: BorderRadius.circular(6.0), // 셀 모서리 둥글게
                    color: cellColor, // 계산된 셀 배경색
                    boxShadow: [ // 점수가 있을 때만 그림자 효과
                      if (scoreValue > 0)
                        BoxShadow(
                          color: Colors.grey.withAlpha(51), // 연한 그림자
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1), // 그림자 위치 (아래로)
                        ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // 내용물 수직 중앙 정렬
                      children: [
                        // 날짜 텍스트
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: textColor,
                          ),
                        ),
                        // 점수 텍스트 (점수가 있을 때만 표시)
                        if (scoreValue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '$scoreValue', // 점수
                              style: TextStyle(
                                fontSize: 9.5,
                                color: textColor.withAlpha(217), // 약간 투명하게
                                fontWeight: FontWeight.w500,
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
