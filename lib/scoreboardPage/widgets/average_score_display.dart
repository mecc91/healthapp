import 'package:flutter/material.dart';
import '../scoreboard_constants.dart'; // 상수 파일 import

class AverageScoreDisplay extends StatelessWidget {
  final double averageScore;
  final String dateRangeFormatted;
  final VoidCallback onDetailPressed;

  const AverageScoreDisplay({
    super.key,
    required this.averageScore,
    required this.dateRangeFormatted,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // 필요시 조정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("avr",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(text: averageScore.toStringAsFixed(0)),
                        const TextSpan(
                          text: ' point',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dateRangeFormatted,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              OutlinedButton(
                onPressed: onDetailPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryScoreboardColor,
                  side: const BorderSide(color: primaryScoreboardColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text("detail"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}