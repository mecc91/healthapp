// lib/nutrientintakePage/widgets/nutrient_selector_button.dart
import 'package:flutter/material.dart';

class NutrientSelectorButton extends StatelessWidget {
  final String selectedNutrientName;
  final VoidCallback onPressed;
  final double? buttonWidth;

  const NutrientSelectorButton({
    super.key,
    required this.selectedNutrientName,
    required this.onPressed,
    this.buttonWidth,
  });

  /*@override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth ?? MediaQuery.of(context).size.width - (16.0 * 2), // Default width
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange.shade800,
          side: BorderSide(color: Colors.orange.shade600, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          selectedNutrientName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            selectedNutrientName,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}