import 'package:flutter/material.dart';
import '../scoreboard_constants.dart'; // 상수 파일 import

class ScoreboardPeriodToggle extends StatelessWidget {
  final List<bool> isSelected;
  final Function(int) onPressed;

  const ScoreboardPeriodToggle({
    super.key,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: isSelected,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        selectedColor: Colors.white,
        color: Colors.black54,
        fillColor: primaryScoreboardColor,
        borderColor: Colors.grey.shade300,
        selectedBorderColor: primaryScoreboardColor,
        constraints: const BoxConstraints(minHeight: 35.0, minWidth: 50.0),
        children: const [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("week")),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("month")),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("quater")),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("year")),
        ],
      ),
    );
  }
}