// lib/nutrientintakePage/widgets/nutrient_weekly_chart.dart
import 'package:flutter/material.dart';
import '../nutrient_intake_constants.dart';
import '../services/nutrient_intake_data_service.dart'; // For calculateBarHeight

class NutrientWeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> weekData;
  final Function(int) onChangeWeek; // Callback for week change
  final Function(int) onChangeNutrientViaSwipe; // Callback for nutrient change via vertical swipe
  final bool canGoBack;
  final bool canGoForward;
  final bool isWeekPeriodSelected; // To enable/disable week change interactions

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
  Widget build(BuildContext context) {
    final int maxValueInCurrentWeek = weekData.isEmpty
        ? 100 // Default max value to prevent division by zero if data is empty
        : weekData.map((d) => d['value'] as int).fold(0, (max, current) => current > max ? current : max);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (isWeekPeriodSelected && details.primaryVelocity != null) {
          if (details.primaryVelocity! > 100) { // Swipe Right (Previous week)
            if (canGoBack) onChangeWeek(-1);
          } else if (details.primaryVelocity! < -100) { // Swipe Left (Next week)
            if (canGoForward) onChangeWeek(1);
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 200) { // Swipe Down
            onChangeNutrientViaSwipe(1); // Or -1 depending on desired direction
          } else if (details.primaryVelocity! < -200) { // Swipe Up
            onChangeNutrientViaSwipe(-1); // Or 1
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeightForGraphContainer = constraints.maxHeight;
          final double availableWidthForGraphContainer = constraints.maxWidth;

          final double maxVisualBarHeight = availableHeightForGraphContainer -
              (kGraphTextLineHeightApproximation * 2) -
              kGraphTopSizedBoxHeight -
              kGraphBottomSizedBoxHeight -
              kGraphContainerVerticalPadding;

          final double barWidth = weekData.isEmpty
              ? 0
              : availableWidthForGraphContainer / (weekData.length * 3.0); // Adjusted ratio

          return Container(
            decoration: BoxDecoration(
              color: kNutrientIntakeGraphBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
                vertical: kGraphContainerVerticalPadding / 2, horizontal: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: isWeekPeriodSelected && canGoBack ? () => onChangeWeek(-1) : null,
                  color: isWeekPeriodSelected && canGoBack
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekData.map((dayData) {
                        final barHeightValue = NutrientIntakeDataService.calculateBarHeight(
                          dayData['value'],
                          maxVisualBarHeight > 0 ? maxVisualBarHeight : 0,
                          maxValueInCurrentWeek,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${dayData['value']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: kGraphValueTextFontSize),
                            ),
                            const SizedBox(height: kGraphTopSizedBoxHeight),
                            Container(
                              height: barHeightValue,
                              width: barWidth > 0 ? barWidth : 0,
                              decoration: BoxDecoration(
                                color: kNutrientIntakeGraphAccentColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: kGraphBottomSizedBoxHeight),
                            Text(
                              dayData['day'],
                              style: const TextStyle(
                                  fontSize: kGraphDayTextFontSize, fontWeight: FontWeight.bold),
                            ),
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
                  onPressed: isWeekPeriodSelected && canGoForward ? () => onChangeWeek(1) : null,
                  color: isWeekPeriodSelected && canGoForward
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