import 'package:flutter/material.dart';
import '../nutrient_intake_constants.dart';
import '../services/nutrient_intake_data_service.dart';

class NutrientWeeklyChart extends StatefulWidget {
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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant NutrientWeeklyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekData != widget.weekData) {
      _controller.forward(from: 0); // 데이터 바뀌면 애니메이션 재실행
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int maxValue = widget.weekData.isEmpty
        ? 100
        : widget.weekData
            .map((d) => d['value'] as int)
            .reduce((a, b) => a > b ? a : b);

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
                  : constraints.maxWidth / (widget.weekData.length * 3.0);

              return Container(
                decoration: BoxDecoration(
                  color: kNutrientIntakeGraphBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: kGraphContainerVerticalPadding / 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 36.0,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: widget.weekData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final barHeight =
                              NutrientIntakeDataService.calculateBarHeight(
                            data['value'],
                            maxBarHeight,
                            maxValue,
                          );

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${data['value']}",
                                style: const TextStyle(
                                  fontSize: kGraphValueTextFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: kGraphTopSizedBoxHeight),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: barHeight),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedHeight, child) {
                                  return Container(
                                    height: animatedHeight,
                                    width: barWidth,
                                    decoration: BoxDecoration(
                                      color: kNutrientIntakeGraphAccentColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                  height: kGraphBottomSizedBoxHeight),
                              Text(
                                data['day'],
                                style: const TextStyle(
                                  fontSize: kGraphDayTextFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 36.0,
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
