import 'package:flutter/material.dart';
import 'dart:math';
import '../scoreboard_constants.dart';

// ✅ 전역 routeObserver 사용한다고 가정
import '../../main.dart'; // 여기서 routeObserver 가져온다고 가정

double _calculateBarHeight(
    int value, double heightForMaxPossibleBar, int referenceMaxValueInPeriod) {
  if (value <= 0 ||
      referenceMaxValueInPeriod <= 0 ||
      heightForMaxPossibleBar <= 0) return 0;
  double calculatedHeight = (value / 100.0) * heightForMaxPossibleBar;
  return max(0, calculatedHeight);
}

class WeeklyScoreChart extends StatefulWidget {
  final List<Map<String, dynamic>> weekData;
  final Function(int) onChangeWeek;
  final bool canGoBack;
  final bool canGoForward;

  const WeeklyScoreChart({
    super.key,
    required this.weekData,
    required this.onChangeWeek,
    required this.canGoBack,
    required this.canGoForward,
  });

  @override
  State<WeeklyScoreChart> createState() => _WeeklyScoreChartState();
}

class _WeeklyScoreChartState extends State<WeeklyScoreChart>
    with SingleTickerProviderStateMixin, RouteAware {
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant WeeklyScoreChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekData != widget.weekData) {
      _controller.forward(from: 0);
    }
  }

  // ✅ RouteObserver: 구독
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  // ✅ Back 후 복귀 시 애니메이션 실행
  @override
  void didPopNext() {
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) {
          if (widget.canGoBack) widget.onChangeWeek(-1);
        } else if (details.primaryVelocity! < -100) {
          if (widget.canGoForward) widget.onChangeWeek(1);
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(builder: (context, constraints) {
            final double heightFor100 = constraints.maxHeight - 40;
            final double barAreaWidth = constraints.maxWidth - 36 * 2 - 5.0 * 2;
            final double barWidth = widget.weekData.isEmpty
                ? 0
                : barAreaWidth / (widget.weekData.length * 1.8);

            return Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 36.0,
                    padding: EdgeInsets.zero,
                    onPressed:
                        widget.canGoBack ? () => widget.onChangeWeek(-1) : null,
                    color: widget.canGoBack
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.weekData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dayData = entry.value;
                        final barHeight = _calculateBarHeight(
                            dayData['value'], heightFor100, 100);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${dayData['value']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 1),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: barHeight),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, animatedHeight, child) {
                                return Container(
                                  height: animatedHeight,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: accentScoreboardColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 1),
                            Text(
                              dayData['day'],
                              style: const TextStyle(
                                fontSize: 9,
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
                    onPressed: widget.canGoForward
                        ? () => widget.onChangeWeek(1)
                        : null,
                    color: widget.canGoForward
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
