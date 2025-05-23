// lib/nutrientintakePage/widgets/nutrient_monthly_calendar_view.dart
import 'package:flutter/material.dart';

import '../services/nutrient_intake_data_service.dart';



class NutrientMonthlyCalendarView extends StatefulWidget {
  final DateTime selectedMonth; // The first day of the month to display
  final Map<int, int> monthlyNutrientData; // Key: day of month, Value: nutrient intake
  final NutrientIntakeDataService dataService; // To access any other service methods if needed
  final Function(DateTime) onDateSelected; // Callback when a date cell is tapped
  final Function(int) onChangeMonthBySwipe; // Callback for horizontal swipe gesture to change month
  final Function(int) onChangeNutrientBySwipe; // ✅ Callback for vertical swipe gesture to change nutrient
  final bool canGoBackMonth;
  final bool canGoForwardMonth;
  final String currentNutrientName; // Name of the currently displayed nutrient

  const NutrientMonthlyCalendarView({
    super.key,
    required this.selectedMonth,
    required this.monthlyNutrientData,
    required this.dataService,
    required this.onDateSelected,
    required this.onChangeMonthBySwipe,
    required this.onChangeNutrientBySwipe, // ✅ 추가된 콜백
    required this.canGoBackMonth,
    required this.canGoForwardMonth,
    required this.currentNutrientName,
  });

  @override
  State<NutrientMonthlyCalendarView> createState() => _NutrientMonthlyCalendarViewState();
}

class _NutrientMonthlyCalendarViewState extends State<NutrientMonthlyCalendarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color _nutrientBaseColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant NutrientMonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(widget.selectedMonth.year, widget.selectedMonth.month);
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    final emptyCellsPrefix = firstDayOfMonth.weekday % 7;

    return GestureDetector(
      // ✅ 수평 및 수직 스와이프 감지
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200 && widget.canGoBackMonth) {
          widget.onChangeMonthBySwipe(-1); // 이전 달
        } else if (details.primaryVelocity! < -200 && widget.canGoForwardMonth) {
          widget.onChangeMonthBySwipe(1); // 다음 달
        }
      },
      onVerticalDragEnd: (details) { // ✅ 수직 스와이프 감지 추가
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
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemCount: daysInMonth + emptyCellsPrefix,
            itemBuilder: (context, index) {
              if (index < emptyCellsPrefix) {
                return Container();
              }

              final dayNumber = index - emptyCellsPrefix + 1;
              final currentDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber);
              final nutrientValue = widget.monthlyNutrientData[dayNumber] ?? 0;

              Color cellColor = Colors.white;
              Color textColor = Colors.black87;
              const double maxNutrientValueForOpacity = 150.0;

              if (nutrientValue > 0) {
                double opacity = (nutrientValue / maxNutrientValueForOpacity).clamp(0.15, 1.0);
                cellColor = _nutrientBaseColor.withAlpha((opacity * 255).round());
                if (opacity > 0.55) {
                  textColor = Colors.white;
                }
              }

              return GestureDetector(
                onTap: () => widget.onDateSelected(currentDate),
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(6.0),
                    color: cellColor,
                    boxShadow: [
                      if (nutrientValue > 0)
                        BoxShadow(
                          color: Colors.grey.withAlpha(51),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: textColor,
                          ),
                        ),
                        if (nutrientValue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '$nutrientValue',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: textColor.withAlpha(217),
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
