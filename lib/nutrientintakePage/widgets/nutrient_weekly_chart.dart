// lib/nutrientintakePage/widgets/nutrient_weekly_chart.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For max in effectiveMaxValue (though not strictly needed with current logic)
import '../nutrient_intake_constants.dart';
import '../services/nutrient_intake_data_service.dart';

class NutrientWeeklyChart extends StatefulWidget {
  // weekData의 'value'는 이제 int score가 아닌 double nutrientIntake 입니다.
  final List<Map<String, dynamic>> weekData;
  final Function(int) onChangeWeek;
  final Function(int) onChangeNutrientViaSwipe;
  final bool canGoBack;
  final bool canGoForward;
  final bool isWeekPeriodSelected;

  const NutrientWeeklyChart({
    super.key,
    required this.weekData,
    required this.onChangeWeek,
    required this.onChangeNutrientViaSwipe,
    required this.canGoBack,
    required this.canGoForward,
    required this.isWeekPeriodSelected,
  });

  @override
  State<NutrientWeeklyChart> createState() => _NutrientWeeklyChartState();
}

class _NutrientWeeklyChartState extends State<NutrientWeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.weekData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0.0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant NutrientWeeklyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekData != widget.weekData) {
      if (mounted) {
        _controller.reset();
        if (widget.weekData.isNotEmpty) {
          _controller.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // maxValueInPeriod: 이제 double 타입의 섭취량 중 최대값을 찾습니다.
    final double maxValueInPeriod = widget.weekData.isEmpty
        ? 1.0 // 데이터 없을 시 기본값 (0으로 나누기 방지, 적절히 조절)
        : widget.weekData
            .map((d) => d['value'] as double? ?? 0.0) // 'value'는 double 타입의 섭취량
            .reduce((a, b) => a > b ? a : b); // 최대값 찾기

    // effectiveMaxValue: maxValueInPeriod가 0 이하일 경우 나눗셈 오류 방지를 위해 1.0으로 보정
    final double effectiveMaxValue = maxValueInPeriod > 0.0 ? maxValueInPeriod : 1.0;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (widget.isWeekPeriodSelected && details.primaryVelocity != null) {
          if (details.primaryVelocity! > 100 && widget.canGoBack) {
            widget.onChangeWeek(-1);
          } else if (details.primaryVelocity! < -100 && widget.canGoForward) {
            widget.onChangeWeek(1);
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 200) {
            widget.onChangeNutrientViaSwipe(1);
          } else if (details.primaryVelocity! < -200) {
            widget.onChangeNutrientViaSwipe(-1);
          }
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxBarHeight = constraints.maxHeight -
                  (kGraphTextLineHeightApproximation * 2) -
                  kGraphTopSizedBoxHeight -
                  kGraphBottomSizedBoxHeight -
                  kGraphContainerVerticalPadding;

              final double barWidth = widget.weekData.isEmpty
                  ? 0
                  : (constraints.maxWidth - (36 * 2) - 16) / (widget.weekData.length * 1.5);

              return Container(
                decoration: BoxDecoration(
                  color: kNutrientIntakeGraphBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: kGraphContainerVerticalPadding / 2, horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 32.0,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.isWeekPeriodSelected && widget.canGoBack
                          ? () => widget.onChangeWeek(-1)
                          : null,
                      color: widget.isWeekPeriodSelected && widget.canGoBack
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    Expanded(
                      child: widget.weekData.isEmpty
                          ? const Center(child: Text("표시할 데이터가 없습니다.", style: TextStyle(color: Colors.grey)))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: widget.weekData.asMap().entries.map((entry) {
                                final Map<String, dynamic> data = entry.value;
                                // nutrientValue는 이제 double 타입의 섭취량입니다.
                                final double nutrientValue = data['value'] as double? ?? 0.0;
                                final String dayName = data['day'] as String? ?? '';

                                // NutrientIntakeDataService.calculateBarHeight 호출 시 double 값 전달
                                final barHeight =
                                    NutrientIntakeDataService.calculateBarHeight(
                                  nutrientValue, // double 타입 섭취량
                                  maxBarHeight > 0 ? maxBarHeight : 1.0, // maxBarHeight 0 이하 방지
                                  effectiveMaxValue, // double 타입의 해당 주 최대 섭취량
                                );

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // 섭취량 텍스트 (소수점 한 자리까지 표시)
                                    Text(
                                      nutrientValue.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: kGraphValueTextFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: kGraphTopSizedBoxHeight),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: barHeight < 0 ? 0 : barHeight),
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, animatedHeight, child) {
                                        return Container(
                                          height: animatedHeight,
                                          width: barWidth > 0 ? barWidth : 10,
                                          decoration: BoxDecoration(
                                            color: kNutrientIntakeGraphAccentColor,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: kGraphBottomSizedBoxHeight),
                                    Text(
                                      dayName,
                                      style: const TextStyle(
                                        fontSize: kGraphDayTextFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 32.0,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed:
                          widget.isWeekPeriodSelected && widget.canGoForward
                              ? () => widget.onChangeWeek(1)
                              : null,
                      color: widget.isWeekPeriodSelected && widget.canGoForward
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}