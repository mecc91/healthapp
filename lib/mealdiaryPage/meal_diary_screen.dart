// lib/mealDiaryPage/meal_diary_screen.dart
import 'package:flutter/material.dart';
// Assuming you might want this
import 'package:intl/intl.dart'; // For date formatting

import 'meal_diary_entry.dart';
import 'widgets/meal_diary_card.dart';

class MealDiaryScreen extends StatefulWidget {
  // You might pass the date to display, or fetch it based on today's date
  final DateTime displayDate;

  const MealDiaryScreen({
    super.key,
    required this.displayDate,
  });

  @override
  State<MealDiaryScreen> createState() => _MealDiaryScreenState();
}

class _MealDiaryScreenState extends State<MealDiaryScreen> {
  // --- Placeholder Data ---
  // In a real app, you would fetch this data based on widget.displayDate
  // from a database, API, or state management solution.
  late List<MealDiaryEntry> _diaryEntries;

  @override
  void initState() {
    super.initState();
    // Initialize with placeholder data for the example date
    _loadEntriesForDate(widget.displayDate);
  }

  void _loadEntriesForDate(DateTime date) {
    // Simulate fetching data for 2025-04-02
    // Replace with your actual data fetching logic and actual asset paths
    if (DateFormat('yyyy-MM-dd').format(date) == '2025-05-16') {
      _diaryEntries = [
        MealDiaryEntry(
          imagePath:
              'assets/image/jajangmyeon.jpg', // MODIFIED: Placeholder asset path
          time: '13:04',
          menuName: '짜장면',
          intakeAmount: '600g',
          notes:
              '오늘 아침은 평소보다 든든하게 먹고 싶어서 동네 중국집에서 짜장면을 포장해왔다. 살짝 불긴 했지만 면도 좋고 건더기 고기도 적당히 들어있어서 만족스러웠다. 다음엔 계란 후라이 하나 올려 먹으면 더 좋을 것 같다.',
          dateTime: DateTime(2025, 4, 2, 13, 4),
        ),
        MealDiaryEntry(
          imagePath:
              'assets/image/chicken.jpg', // MODIFIED: Placeholder asset path
          time: '20:14',
          // menuName: // 이전 주석 처리된 라인 (선택적으로 유지 또는 삭제)
          // '짜장면', // Image shows chicken, but text says 짜장면. ... <<-- 이 줄이 문제의 원인이었으며 삭제되었습니다.
          // For consistency, let's assume the menuName should reflect the image if we are changing it to a local asset.
          menuName: '후라이드 치킨', // MODIFIED for clarity
          intakeAmount:
              '600g', // This might also need adjustment if menuName changes
          notes:
              '저녁엔 친구들이랑 황금올리브 치킨을 시켜 먹었다. 겉은 바삭하고 속은 촉촉해서 역시 맛있었다. 소스 없이도 짜지 않고 혼자 반 마리 정도는 충분히 먹는 느낌. 양배추 샐러드가 없어 좀 아쉽긴 했지만, 맛있게 먹었다!',
          dateTime: DateTime(2025, 4, 2, 20, 14),
        ),
        MealDiaryEntry(
          imagePath:
              'assets/image/bibimbap.jpg', // MODIFIED: Placeholder asset path
          time: '08:30',
          menuName: '비빔밥',
          intakeAmount: '450g',
          notes:
              '아침은 간단하게 냉장고에 있던 나물들과 계란 후라이를 넣어 비빔밥을 만들어 먹었다. 고추장을 조금만 넣어 간을 맞추니 건강하고 맛있었다.',
          dateTime: DateTime(2025, 4, 2, 8, 30),
        ),
      ];
      // Sort entries by time
      _diaryEntries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } else {
      // Handle cases for other dates (e.g., show empty list or different data)
      _diaryEntries = [];
    }
    // Trigger a rebuild if the state changes after initial build
    if (mounted) {
      setState(() {});
    }
  }
  // --- End Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.displayDate);

    return Scaffold(
      backgroundColor: Colors.white, // Match the image background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        // Optional: Add actions like a date picker
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.calendar_today, color: Colors.black54),
        //     onPressed: () {
        //       // TODO: Implement date picking logic
        //     },
        //   ),
        // ],
      ),
      body: _diaryEntries.isEmpty
          ? Center(
              child: Text(
                '${DateFormat('yyyy년 MM월 dd일').format(widget.displayDate)}\n\n 등록된 식단 기록이 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _diaryEntries.length,
              itemBuilder: (context, index) {
                return MealDiaryCard(entry: _diaryEntries[index]);
              },
            ),
      // Optional: Add the common bottom navigation bar if needed for this screen
      // bottomNavigationBar: const CommonBottomNavigationBar(
      //   currentPage: AppPage.dashboard, // Or whichever page this relates to
      // ),
    );
  }
}