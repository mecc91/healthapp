import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/scoreboard_data_service.dart';
import '../scoreboard_constants.dart'; // For dayNamesKorean (optional)

class MonthlyCalendarView extends StatelessWidget {
  final DateTime selectedMonth;
  final ScoreboardDataService dataService;
  final Function(DateTime) onDateSelected;

  const MonthlyCalendarView({
    super.key,
    required this.selectedMonth,
    required this.dataService,
    required this.onDateSelected,
  });

  Widget _buildDayOfWeekHeader() {
    // Using dayNamesKorean from constants if defined, otherwise fallback
    // The order should match how your calendar grid starts (e.g., Sunday or Monday)
    // Current implementation of emptyCellsPrefix assumes Monday is the first day (weekday 1)
    // If you use dayNamesKorean (Sun, Mon, ...), adjust emptyCellsPrefix calculation or this list
    // For this example, let's assume the grid starts visually with Sunday if dayNamesKorean is used.
    // However, the `emptyCellsPrefix` is based on DateTime's `weekday` (1=Mon, 7=Sun).
    // So, if dayNamesKorean is ['일', '월', ...], we need to adjust grid start or this header.

    // Let's stick to a Monday-starting week to align with `DateTime.weekday` and `emptyCellsPrefix` logic easily.
    // If you want Sunday start, `emptyCellsPrefix` needs `(weekDayOfFirstDay % 7)`
    // and day names should be shifted.

    // For simplicity, let's use Monday-Saturday, Sunday (or adjust dayNames if needed)
    // Or, provide a specific list here.
    final List<String> displayDayNames = dayNamesKorean; // Or a custom list like ['월', '화', ..., '일']

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: displayDayNames.map((day) {
        return Expanded( // Ensure equal spacing
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
          ),
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final monthlyScores = dataService.getScoresForMonth(selectedMonth);

    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    
    // IMPORTANT: DateTime.weekday returns 1 for Monday and 7 for Sunday.
    // emptyCellsPrefix calculates how many empty cells are needed before the 1st day,
    // assuming the grid starts on Monday.
    int emptyCellsPrefix = firstDayOfMonth.weekday - 1; // 0 for Mon, 1 for Tue, ..., 6 for Sun

    // If using dayNamesKorean starting with '일', and you want Sunday as the visual start of the week:
    // emptyCellsPrefix = firstDayOfMonth.weekday % 7; // 0 for Sun, 1 for Mon, ...
    // And the dayNamesKorean should be ['일', '월', '화', '수', '목', '금', '토']

    // For consistency with the provided screenshot (which doesn't show day names yet)
    // and common calendar layouts, let's assume we want to display '일' to '토'.
    // The `firstDayOfMonth.weekday` (1=Mon, 7=Sun) needs to be mapped to this.
    // If `dayNamesKorean` is `['일', '월', ..., '토']`, then Sunday is index 0.
    // `emptyCellsPrefix` would be `firstDayOfMonth.weekday % 7`.

    // Let's adjust `emptyCellsPrefix` for a Sunday-first visual week
    // with `dayNamesKorean = ['일', '월', '화', '수', '목', '금', '토']`.
    // `DateTime.sunday` is 7. So `firstDayOfMonth.weekday % 7` will be 0 if Sunday.
    // This seems correct.
    emptyCellsPrefix = firstDayOfMonth.weekday % 7;


    return Column( // Removed LayoutBuilder as parent Expanded will handle sizing
      children: [
        // _buildDayOfWeekHeader() is now inside the decorative box in scoreboard.dart
        // but can be kept here if the box only surrounds the GridView.
        // For now, moving it to scoreboard.dart to be inside the styled box.
        // If you want it outside the box, keep it here.

        // If days of week header should be here (above the grid, but potentially outside the main box)
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: _buildDayOfWeekHeader(),
        // ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0, // Adjust as needed (e.g., 0.9 for taller)
            ),
            itemCount: daysInMonth + emptyCellsPrefix,
            itemBuilder: (context, index) {
              if (index < emptyCellsPrefix) {
                return Container();
              }

              final dayNumber = index - emptyCellsPrefix + 1;
              final currentDate = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
              final score = monthlyScores[dayNumber] ?? 0;

              return GestureDetector(
                onTap: () => onDateSelected(currentDate),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4.0),
                    color: score > 0 ? Colors.teal.withOpacity(score / 100.0) : Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: score > 50 ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (score > 0)
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 9,
                              color: score > 50 ? Colors.white70 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}