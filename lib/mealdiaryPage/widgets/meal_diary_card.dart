// lib/mealDiaryPage/widgets/meal_diary_card.dart
import 'package:flutter/material.dart';
import '../meal_diary_entry.dart'; // Import the data model

class MealDiaryCard extends StatelessWidget {
  final MealDiaryEntry entry;

  const MealDiaryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.3; // Adjust image size ratio as needed

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset( // MODIFIED: Was Image.network
              entry.imagePath,  // MODIFIED: Was entry.imageUrl
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              // MODIFIED: loadingBuilder is not directly applicable to Image.asset in the same way.
              // Image.asset loads quickly from local assets. If you need a frameBuilder for custom effects:
              // frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              //   if (wasSynchronouslyLoaded) {
              //     return child;
              //   }
              //   return AnimatedOpacity(
              //     opacity: frame == null ? 0 : 1,
              //     duration: const Duration(seconds: 1),
              //     curve: Curves.easeOut,
              //     child: child,
              //   );
              // },
              errorBuilder: (context, error, stackTrace) {
                // This will be called if the asset is not found or is corrupted
                print('Error loading asset: ${entry.imagePath}, Error: $error');
                return Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.grey[600], size: imageSize * 0.5),
                );
              },
            ),
          ),

          const SizedBox(width: 16.0), // Spacing between image and text

          // Details on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                Text(
                  entry.time,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Menu
                Text(
                  'Menu: ${entry.menuName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // Semi-bold
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),

                // Intake Amount
                Text(
                  '섭취량: ${entry.intakeAmount}', // "Intake Amount"
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12.0),

                // Notes
                Text(
                  entry.notes,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.4, // Line spacing
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}