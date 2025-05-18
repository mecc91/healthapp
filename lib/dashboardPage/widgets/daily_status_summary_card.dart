// lib/dashboardPage/widgets/daily_status_summary_card.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/service/dailystatusservice.dart';

class DailyStatusSummaryCard extends StatefulWidget {
  final double scale;
  final Function(TapDownDetails) onTapDown;
  final Function(TapUpDetails) onTapUp;
  final VoidCallback onTapCancel;

  const DailyStatusSummaryCard({
    super.key, //애니매이션 강제 리부트트
    required this.scale,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  State<DailyStatusSummaryCard> createState() => _DailyStatusSummaryCardState();
}

class _DailyStatusSummaryCardState extends State<DailyStatusSummaryCard> {

  // 추후 API Request를 위한 Service
  final DailyStatusService _dailyStatusService = DailyStatusService(baseUrl: "http://...");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // 실제 데이터는 외부에서 주입받거나 상태 관리로 처리하는 것이 좋습니다.
  final List<Map<String, dynamic>> nutrients = const [
    {"label": "탄수화물", "value": 0.95, "color": Colors.orange},
    {"label": "단백질", "value": 0.75, "color": Colors.yellow},
    {"label": "지방", "value": 0.65, "color": Colors.green},
    {"label": "나트륨", "value": 0.9, "color": Colors.red},
    {"label": "식이섬유", "value": 0.6, "color": Colors.purple},
    {"label": "당류", "value": 0.5, "color": Colors.lightBlue},
    {"label": "콜레스테롤", "value": 0.85, "color": Colors.deepOrange},
  ];

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
        onTapDown: widget.onTapDown,
        onTapUp: widget.onTapUp,
        onTapCancel: widget.onTapCancel,
        child: AnimatedScale(
          scale: widget.scale,
          duration: const Duration(milliseconds: 150),
          child: Card(
            color: const Color(0xFFFCFCFC),
            elevation: 5,
            shadowColor: Colors.grey.withAlpha(77),
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
                    "Daily Status",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  // 7개 막대에 대하여
                  ...nutrients.map((item) {
                    final double value = item["value"]! as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["label"]! as String,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 5),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: value),
                            duration: Duration(
                                milliseconds: 700 + (value * 300).toInt()),
                            builder: (context, animatedValue, child) {
                              // 그래프 막대바 부분
                              return LinearProgressIndicator(
                                value: animatedValue,
                                backgroundColor: Colors.grey.shade300,
                                color: _getProgressColor(animatedValue),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(10),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
