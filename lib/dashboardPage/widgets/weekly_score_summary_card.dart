// lib/dashboardPage/widgets/weekly_score_summary_card.dart
import 'package:flutter/material.dart';

class WeeklyScoreSummaryCard extends StatelessWidget {
  final double scale;
  final Function(TapDownDetails) onTapDown;
  final Function(TapUpDetails) onTapUp;
  final VoidCallback onTapCancel;

  // 실제 데이터는 외부에서 주입받거나 상태 관리로 처리하는 것이 좋습니다.
  // 여기서는 기존 하드코딩된 데이터를 유지합니다.
  final List<Map<String, dynamic>> scores = const [
    {"day": "Monday", "value": 0.6},
    {"day": "Tuesday", "value": 0.3},
    {"day": "Wednesday", "value": 0.8},
    {"day": "Thursday", "value": 0.85},
    {"day": "Friday", "value": 0.4},
    {"day": "Saturday", "value": 0.2},
    {"day": "Sunday", "value": 0.5},
  ];

  const WeeklyScoreSummaryCard({
    super.key,
    required this.scale,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  Color _getProgressColor(double animatedValue) {
    if (animatedValue <= 0.25) return Colors.red.shade400;
    if (animatedValue <= 0.40) return Colors.orange.shade400;
    if (animatedValue <= 0.60) return Colors.amber.shade500;
    if (animatedValue <= 0.85) return Colors.lightGreen.shade500;
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          child: Card(
            color: const Color(0xFFFCFCFC),
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Score",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ...scores.map((item) {
                    final double value = item["value"]! as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              item["day"]! as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: value),
                              duration: Duration(
                                  milliseconds: 700 + (value * 300).toInt()),
                              builder: (context, animatedValue, child) {
                                return LinearProgressIndicator(
                                  value: animatedValue,
                                  backgroundColor: Colors.grey[300],
                                  color: _getProgressColor(animatedValue),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(10),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}