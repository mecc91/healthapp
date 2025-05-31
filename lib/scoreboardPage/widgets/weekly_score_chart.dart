// widgets/weekly_score_chart.dart
import 'package:flutter/material.dart';
import 'dart:math'; // for max
import '../scoreboard_constants.dart'; // 상수 사용

// main.dart 또는 앱의 진입점에서 RouteObserver를 설정해야 합니다.
// 예: final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// 그리고 MaterialApp(navigatorObservers: [routeObserver], ...)
// 이 파일에서는 routeObserver가 설정되어 있다고 가정합니다.
// 실제로는 main.dart에서 가져오거나 의존성 주입을 통해 받아야 합니다.
// import '../../main.dart'; // hypothetical import for routeObserver

double _calculateBarHeight(
    int value, double heightForMaxPossibleBar, int referenceMaxValueInPeriod) {
  if (value <= 0 ||
      referenceMaxValueInPeriod <= 0 ||
      heightForMaxPossibleBar <= 0) {
    return 0;
  }
  // 점수는 0-100 범위라고 가정
  double calculatedHeight = (value / 100.0) * heightForMaxPossibleBar;
  return max(0, calculatedHeight.isNaN ? 0 : calculatedHeight); // NaN 및 음수 방지
}

class WeeklyScoreChart extends StatefulWidget {
  final List<Map<String, dynamic>> weekData; // 'day': String, 'value': int, 'date': DateTime
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

  // RouteObserver를 사용하기 위한 설정 (main.dart에서 주입 필요)
  // 이 예제에서는 직접 참조 대신 ModalRoute를 사용합니다.
  // final RouteObserver<PageRoute>? routeObserver = MyApp.routeObserver; // MyApp.routeObserver는 예시

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 애니메이션 지속 시간
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2), // 아래에서 위로 약간 올라오는 효과
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // 데이터가 준비되면 애니메이션 시작
    // initState에서 weekData가 비어있을 수 있으므로, didUpdateWidget 또는 build에서 시작 고려
    if (widget.weekData.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) _controller.forward(from: 0.0);
       });
    }
  }

  @override
  void didUpdateWidget(covariant WeeklyScoreChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // weekData가 변경되었을 때 (참조 또는 내용) 애니메이션 다시 시작
    // List의 내용을 비교하는 것은 복잡하므로, scoreboard.dart에서 key를 변경하여
    // 위젯을 새로 그리도록 유도하는 것이 더 간단하고 확실할 수 있습니다.
    // 여기서는 참조가 변경되었다고 가정하고 애니메이션을 다시 시작합니다.
    if (oldWidget.weekData != widget.weekData || (widget.weekData.isNotEmpty && oldWidget.weekData.isEmpty)) {
       if (mounted) {
         _controller.reset();
         _controller.forward();
       }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final route = ModalRoute.of(context);
    // if (route is PageRoute && routeObserver != null) {
    //   routeObserver!.subscribe(this, route);
    // }
  }

  @override
  void didPopNext() { // 다른 화면에서 이 화면으로 돌아왔을 때
    if (mounted) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    // final route = ModalRoute.of(context);
    // if (route is PageRoute && routeObserver != null) {
    //   routeObserver!.unsubscribe(this);
    // }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 150) { // 오른쪽 스와이프 (이전 주) - 민감도 조절
          if (widget.canGoBack) widget.onChangeWeek(-1);
        } else if (details.primaryVelocity! < -150) { // 왼쪽 스와이프 (다음 주) - 민감도 조절
          if (widget.canGoForward) widget.onChangeWeek(1);
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(builder: (context, constraints) {
            // 차트 영역의 최대 높이에서 상단 점수 텍스트, 하단 요일 텍스트, 약간의 여백 제외
            final double heightFor100 = constraints.maxHeight - 40; // 점수 100일 때의 막대 최대 높이
            // 좌우 화살표 버튼 및 내부 패딩 제외한 순수 막대 영역 너비
            final double availableWidthForBars = constraints.maxWidth - (36 * 2) - (4.0 * 2); // 버튼 크기, 좌우 패딩
            final double barWidth = widget.weekData.isEmpty
                ? 0
                // 막대 간 간격을 주기 위해 전체 너비를 요일 수로 나누고 비율 적용
                : (availableWidthForBars / widget.weekData.length) * 0.65;

            if (widget.weekData.isEmpty) {
              // 데이터가 없을 경우 사용자에게 메시지 표시
              return const Center(
                child: Text(
                  "표시할 주간 데이터가 없습니다.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0), // 내부 패딩 조절
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // 배경색
                borderRadius: BorderRadius.circular(12), // 모서리 둥글게
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 32.0, // 아이콘 크기 조절
                    padding: EdgeInsets.zero,
                    tooltip: "이전 주",
                    onPressed:
                        widget.canGoBack ? () => widget.onChangeWeek(-1) : null,
                    color: widget.canGoBack
                        ? Colors.grey.shade700
                        : Colors.grey.shade400, // 비활성화 시 색상 연하게
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // 막대 간격 균등하게
                      crossAxisAlignment: CrossAxisAlignment.end, // 막대를 아래 정렬
                      children: widget.weekData.asMap().entries.map((entry) {
                        // final int index = entry.key;
                        final Map<String, dynamic> dayData = entry.value;
                        final int scoreValue = dayData['value'] as int? ?? 0;
                        final String dayLabel = dayData['day'] as String? ?? '';
                        // final DateTime date = dayData['date'] as DateTime; // 날짜 정보

                        final barHeight = _calculateBarHeight(
                            scoreValue, heightFor100, 100); // 점수는 0-100 기준

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text( // 점수 표시
                              "$scoreValue",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10, // 폰트 크기 조절
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2), // 점수와 막대 사이 간격
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: barHeight),
                              duration: const Duration(milliseconds: 400), // 애니메이션 속도
                              curve: Curves.easeOutQuart, // 애니메이션 커브
                              builder: (context, animatedHeight, child) {
                                return Container(
                                  height: animatedHeight,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: accentScoreboardColor, // 막대 색상
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4), // 막대 상단 모서리 둥글게
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 3), // 막대와 요일 사이 간격
                            Text( // 요일 표시
                              dayLabel,
                              style: const TextStyle(
                                fontSize: 10, // 폰트 크기 조절
                                fontWeight: FontWeight.w500, // 폰트 두께
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
                    tooltip: "다음 주",
                    onPressed: widget.canGoForward
                        ? () => widget.onChangeWeek(1)
                        : null,
                    color: widget.canGoForward
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
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
