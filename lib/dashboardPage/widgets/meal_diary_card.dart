// lib/dashboardPage/widgets/meal_diary_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MealEntry {
  final String id;
  final String imgPath;
  final int intakeAmount;
  final String? diary;
  final DateTime createdAt;

  MealEntry({
    required this.id,
    required this.imgPath,
    required this.intakeAmount,
    required this.diary,
    required this.createdAt,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'].toString(),
      imgPath: json['imgPath'],
      intakeAmount: json['intakeAmount'],
      diary: json['diary'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MealDiaryCard extends StatefulWidget {
  final String diaryDate;
  final String userId;
  final VoidCallback? onTap;

  const MealDiaryCard({
    super.key,
    required this.userId,
    required this.diaryDate,
    this.onTap,
  });

  @override
  State<MealDiaryCard> createState() => _MealDiaryCardState();
}

class _MealDiaryCardState extends State<MealDiaryCard> {
  List<MealEntry> todayMeals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayMeals();
  }

  Future<void> fetchTodayMeals() async {
    final today = widget.diaryDate; // ✅ 고정된 날짜 사용
    final url = Uri.parse(
        'http://152.67.196.3:4912/users/${widget.userId}/meal-info?date=$today');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final filtered = data.map((e) => MealEntry.fromJson(e)).toList();

      setState(() {
        todayMeals = filtered.take(5).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                Text(
                  "식단 일기 요약 (${widget.diaryDate})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (todayMeals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "오늘의 식단 기록이 없습니다.",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayMeals.length,
                    itemBuilder: (context, index) {
                      final entry = todayMeals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                'http://152.67.196.3:4912/uploads/${entry.imgPath}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.id,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('a h:mm', 'ko_KR')
                                        .format(entry.createdAt),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "섭취량: ${entry.intakeAmount}g",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.diary ?? "작성된 일기가 없습니다.",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                      height: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
