import 'package:flutter/material.dart';
import 'dart:math';
import '../scoreboard_constants.dart'; // 상수 파일 import

// 막대 높이 계산 유틸리티 함수 (이 파일 내에 private으로 두거나, 별도 유틸리티 파일로 분리 가능)
double _calculateBarHeight(int value, double heightForMaxPossibleBar, int referenceMaxValueInPeriod) {
  if (value <= 0 || referenceMaxValueInPeriod <= 0 || heightForMaxPossibleBar <= 0) return 0;
  // 현재는 점수가 0~100점으로 고정되어 있다고 가정하고 referenceMaxValueInPeriod를 100으로 사용
  // 만약 동적으로 변한다면, 해당 기간의 최대값을 기준으로 비율 계산 필요
  double calculatedHeight = (value / 100.0) * heightForMaxPossibleBar; // 100점 만점 기준
  return max(0, calculatedHeight);
}

class WeeklyScoreChart extends StatelessWidget {
  final List<Map<String, dynamic>> weekData;
  final Function(int) onChangeWeek; // weeksToAdd (-1 또는 1)를 파라미터로 받음
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 100) { // 오른쪽으로 스와이프 (이전 주)
          if (canGoBack) onChangeWeek(-1);
        } else if (details.primaryVelocity! < -100) { // 왼쪽으로 스와이프 (다음 주)
          if (canGoForward) onChangeWeek(1);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeightForGraphContainer = constraints.maxHeight;
          final double availableWidthForGraphContainer = constraints.maxWidth;

          // 차트 레이아웃 관련 상수들 (테마나 스타일로 관리 가능)
          const double valueTextFontSize = 9.0;
          const double dayTextFontSize = 9.0;
          const double textLineHeightApproximation = valueTextFontSize * 1.7; // 폰트 높이 근사치
          const double topSizedBoxHeight = 1.0; // 막대 위 텍스트와 막대 사이 간격
          const double bottomSizedBoxHeight = 1.0; // 막대와 요일 텍스트 사이 간격
          const double graphContainerVerticalPadding = 8.0 * 2; // 컨테이너 자체의 상하 패딩
          const double iconButtonEffectiveWidth = 36.0; // 좌우 화살표 버튼 너비
          const double horizontalPaddingForBarArea = 5.0 * 2; // 막대 영역 좌우 패딩

          // 100점짜리 막대가 차지할 수 있는 최대 시각적 높이
          final double heightFor100PointBarVisual =
              availableHeightForGraphContainer -
                  (textLineHeightApproximation * 2) - // 상단 값 텍스트, 하단 요일 텍스트
                  topSizedBoxHeight -
                  bottomSizedBoxHeight -
                  graphContainerVerticalPadding;

          // 실제 막대들이 그려질 수 있는 영역의 너비
          final double barDisplayAreaWidth = availableWidthForGraphContainer -
              (iconButtonEffectiveWidth * 2) - // 좌우 화살표 버튼 너비 제외
              horizontalPaddingForBarArea;

          // 각 막대의 너비
          final double barWidth = weekData.isEmpty
              ? 0
              : barDisplayAreaWidth / (weekData.length * 1.8); // 막대 개수와 간격 비율 고려

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: canGoBack ? () => onChangeWeek(-1) : null,
                  color: canGoBack ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekData.map((dayData) {
                        final barHeightValue = _calculateBarHeight(
                            dayData['value'],
                            heightFor100PointBarVisual > 0
                                ? heightFor100PointBarVisual
                                : 0,
                            100 // 기준 최대값 (100점 만점)
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${dayData['value']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: valueTextFontSize)),
                            const SizedBox(height: topSizedBoxHeight),
                            Container(
                              height: barHeightValue,
                              width: barWidth > 0 ? barWidth : 0,
                              decoration: BoxDecoration(
                                color: accentScoreboardColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: bottomSizedBoxHeight),
                            Text(dayData['day'],
                                style: const TextStyle(
                                    fontSize: dayTextFontSize,
                                    fontWeight: FontWeight.bold)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: canGoForward ? () => onChangeWeek(1) : null,
                  color: canGoForward
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}