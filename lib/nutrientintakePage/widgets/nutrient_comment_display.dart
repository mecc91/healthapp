// lib/nutrientintakePage/widgets/nutrient_comment_display.dart
import 'package:flutter/material.dart';
import '../nutrient_intake_constants.dart'; // For kDefaultComment

class NutrientCommentDisplay extends StatelessWidget {
  final String nutrientName;
  // final double averageIntake; // Example: to make comment dynamic
  // final String intakeStatus; // Example: "부족", "적정", "과다"

  const NutrientCommentDisplay({
    super.key,
    required this.nutrientName,
    // required this.averageIntake,
    // required this.intakeStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Basic dynamic comment based on nutrient name
    String dynamicTextPart;
    Color dynamicTextColor;

    // This is a placeholder for more sophisticated comment generation logic
    // based on actual data analysis (e.g., averageIntake, intakeStatus)
    if (nutrientName == "Fiber" || nutrientName == "Protein") {
      dynamicTextPart = "권장량에 비해 다소 부족한 편";
      dynamicTextColor = Colors.orange.shade700;
    } else if (nutrientName == "Fat") {
      dynamicTextPart = "적정 수준을 유지하고 있지만 주의가 필요";
      dynamicTextColor = Colors.amber.shade800;
    } else {
      dynamicTextPart = "섭취량 관찰이 필요";
      dynamicTextColor = Colors.red.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: ListView( // Use ListView for potentially longer text
          shrinkWrap: true,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                children: [
                  TextSpan(text: "현재 선택된 '$nutrientName' 섭취량은 "),
                  TextSpan(
                    text: dynamicTextPart,
                    style: TextStyle(fontWeight: FontWeight.bold, color: dynamicTextColor),
                  ),
                  const TextSpan(text: "입니다. ${kDefaultComment}"),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}