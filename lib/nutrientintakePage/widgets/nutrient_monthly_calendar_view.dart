// lib/nutrientintakePage/widgets/nutrient_monthly_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/scoreboardPage/scoreboard_constants.dart'; //

import '../services/nutrient_intake_data_service.dart'; //

class NutrientMonthlyCalendarView extends StatefulWidget {
  final DateTime selectedMonth; //
  // monthlyNutrientData 타입을 Map<int, int>에서 Map<int, double>로 변경
  final Map<int, double> monthlyNutrientData; //
  final NutrientIntakeDataService dataService; //
  final Function(DateTime) onDateSelected; //
  final Function(int) onChangeMonthBySwipe; //
  final Function(int) onChangeNutrientBySwipe; //
  final bool canGoBackMonth; //
  final bool canGoForwardMonth; //
  final String currentNutrientName; //

  const NutrientMonthlyCalendarView({
    super.key,
    required this.selectedMonth, //
    required this.monthlyNutrientData, //
    required this.dataService, //
    required this.onDateSelected, //
    required this.onChangeMonthBySwipe, //
    required this.onChangeNutrientBySwipe, //
    required this.canGoBackMonth, //
    required this.canGoForwardMonth, //
    required this.currentNutrientName, //
  });

  @override
  State<NutrientMonthlyCalendarView> createState() => _NutrientMonthlyCalendarViewState();
}

class _NutrientMonthlyCalendarViewState extends State<NutrientMonthlyCalendarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; //
  late Animation<double> _fadeAnimation; //
  late Animation<Offset> _slideAnimation; //

  final Color _scoreBaseColor = Colors.teal; //

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController( //
      vsync: this,
      duration: const Duration(milliseconds: 500), //
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate( //
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn), //
    );

    _slideAnimation = Tween<Offset>( //
      begin: const Offset(0.0, 0.2), //
      end: Offset.zero, //
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic), //
    );

    WidgetsBinding.instance.addPostFrameCallback((_) { //
      if (mounted) {
        _animationController.forward(); //
      }
    });
  }

  @override
  void didUpdateWidget(covariant NutrientMonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth.year != widget.selectedMonth.year || //
        oldWidget.selectedMonth.month != widget.selectedMonth.month || //
        oldWidget.monthlyNutrientData != widget.monthlyNutrientData || //
        oldWidget.currentNutrientName != widget.currentNutrientName) { //
      if (mounted) {
        _animationController.forward(from: 0.0); //
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); //
    super.dispose();
  }

  Widget _buildDayOfWeekHeader() {
    const List<String> displayDayNames = dayNamesKorean; //
    return Padding( //
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), //
      child: Row( //
        mainAxisAlignment: MainAxisAlignment.spaceAround, //
        children: displayDayNames.map((day) { //
          return Expanded( //
            child: Center( //
              child: Text( //
                day, //
                style: const TextStyle( //
                    fontSize: 11, //
                    fontWeight: FontWeight.bold, //
                    color: Colors.black54), //
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(widget.selectedMonth.year, widget.selectedMonth.month); //
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1); //
    final emptyCellsPrefix = firstDayOfMonth.weekday % 7; //

    // 해당 월의 최대 섭취량 계산 (투명도 조절용)
    double maxNutrientValueForMonth = 1.0; // 0으로 나누기 방지 기본값
    if (widget.monthlyNutrientData.isNotEmpty) { //
      final maxVal = widget.monthlyNutrientData.values.fold(0.0, (prev, element) => element > prev ? element : prev); //
      if (maxVal > 0) {
        maxNutrientValueForMonth = maxVal;
      }
    }

    return GestureDetector( //
      onHorizontalDragEnd: (details) { //
        if (details.primaryVelocity == null) return; //
        if (details.primaryVelocity! > 200 && widget.canGoBackMonth) { //
          widget.onChangeMonthBySwipe(-1); //
        } else if (details.primaryVelocity! < -200 && widget.canGoForwardMonth) { //
          widget.onChangeMonthBySwipe(1); //
        }
      },
      onVerticalDragEnd: (details) { //
        if (details.primaryVelocity == null) return; //
        if (details.primaryVelocity! > 200) { //
          widget.onChangeNutrientBySwipe(1); //
        } else if (details.primaryVelocity! < -200) { //
          widget.onChangeNutrientBySwipe(-1); //
        }
      },
      child: SlideTransition( //
        position: _slideAnimation, //
        child: FadeTransition( //
          opacity: _fadeAnimation, //
          child: Column( //
            children: [
              _buildDayOfWeekHeader(), //
              Expanded( //
                child: GridView.builder( //
                  physics: const NeverScrollableScrollPhysics(), //
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( //
                    crossAxisCount: 7, //
                    childAspectRatio: 0.9, //
                    mainAxisSpacing: 1.0, //
                    crossAxisSpacing: 1.0, //
                  ),
                  itemCount: daysInMonth + emptyCellsPrefix, //
                  itemBuilder: (context, index) {
                    if (index < emptyCellsPrefix) { //
                      return Container(); //
                    }

                    final dayNumber = index - emptyCellsPrefix + 1; //
                    final currentDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber); //
                    // nutrientValue는 이제 double 타입의 섭취량
                    final double nutrientValue = widget.monthlyNutrientData[dayNumber] ?? 0.0; //

                    Color cellColor = Colors.white; //
                    Color textColor = Colors.black87; //
                    bool isToday = DateUtils.isSameDay(currentDate, DateTime.now()); //


                    if (nutrientValue > 0) { // nutrientValue가 0보다 클 때만 색상 변경 //
                      // 해당 월의 최대 섭취량(maxNutrientValueForMonth) 기준으로 투명도 조절
                      double opacity = (nutrientValue / maxNutrientValueForMonth).clamp(0.2, 1.0); //
                      cellColor = _scoreBaseColor.withOpacity(opacity); //
                      if (opacity > 0.55) { //
                        textColor = Colors.white; //
                      }
                    }

                    return GestureDetector( //
                      onTap: () => widget.onDateSelected(currentDate), //
                      child: Container( //
                        margin: const EdgeInsets.all(1.5), //
                        decoration: BoxDecoration( //
                          border: isToday //
                            ? Border.all(color: Colors.deepOrangeAccent, width: 1.5) //
                            : Border.all(color: Colors.grey.shade300, width: 0.5), //
                          borderRadius: BorderRadius.circular(6.0), //
                          color: cellColor, //
                          boxShadow: [ //
                            if (nutrientValue > 0) //
                              BoxShadow( //
                                color: Colors.grey.withOpacity(0.15), //
                                spreadRadius: 1, //
                                blurRadius: 2, //
                                offset: const Offset(0, 1), //
                              ),
                          ],
                        ),
                        child: Center( //
                          child: Column( //
                            mainAxisAlignment: MainAxisAlignment.center, //
                            children: [
                              Text( //
                                '$dayNumber', //
                                style: TextStyle( //
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal, //
                                  fontSize: 12.5, //
                                  // 오늘 날짜 텍스트 색상 강조 로직 수정
                                  color: (isToday && textColor != Colors.white) ? Colors.deepOrangeAccent : textColor, //
                                ),
                              ),
                              if (nutrientValue > 0) // nutrientValue가 0보다 클 때만 섭취량 표시 //
                                Padding( //
                                  padding: const EdgeInsets.only(top: 2.0), //
                                  child: Text( //
                                    // 섭취량을 소수점 한 자리까지 표시
                                    nutrientValue.toStringAsFixed(1), //
                                    style: TextStyle( //
                                      fontSize: 9.5, //
                                      color: textColor.withOpacity(0.85), //
                                      fontWeight: FontWeight.w500, //
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
            ],
          ),
        ),
      ),
    );
  }
}