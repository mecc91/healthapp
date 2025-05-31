import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../meal_diary_entry.dart';

class MealDiaryCard extends StatefulWidget {
  final MealDiaryEntry entry;

  const MealDiaryCard({super.key, required this.entry});

  @override
  State<MealDiaryCard> createState() => _MealDiaryCardState();
}

class _MealDiaryCardState extends State<MealDiaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSettingTapped = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> updateDiary({
    required int mealInfoId,
    required int amount,
    required String newDiary,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('❗ 로그인 정보가 없습니다.');
    }

    final url = Uri.parse(
      'http://152.67.196.3:4912/users/$userId/meal-info/$mealInfoId'
      '?amount=$amount&diary=${Uri.encodeComponent(newDiary)}',
    );

    final response = await http.patch(
      url,
      headers: {'Accept': '*/*'},
    );

    if (response.statusCode != 200) {
      throw Exception('다이어리 수정 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.3;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  widget.entry.imagePath,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image,
                          color: Colors.grey[600], size: imageSize * 0.5),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16.0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.entry.time,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (_) {
                            setState(() => _isSettingTapped = true);
                          },
                          onTapUp: (_) async {
                            setState(() => _isSettingTapped = false);

                            final TextEditingController controller =
                                TextEditingController(text: widget.entry.notes);

                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('식단 메모 수정'),
                                content: TextField(
                                  controller: controller,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: '메모를 입력하세요',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, controller.text),
                                    child: const Text('저장'),
                                  ),
                                ],
                              ),
                            );

                            if (result != null &&
                                result != widget.entry.notes) {
                              try {
                                final mealInfoId = int.parse(widget.entry.menuName
                                    .replaceAll('메뉴 ID: ', '')
                                    .trim());

                                await updateDiary(
                                  mealInfoId: mealInfoId,
                                  amount: widget.entry.intakeAmount,
                                  newDiary: result,
                                );

                                setState(() {
                                  widget.entry.notes = result;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('⚠️ 수정 실패: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          onTapCancel: () {
                            setState(() => _isSettingTapped = false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: AnimatedScale(
                              scale: _isSettingTapped ? 0.85 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: AnimatedOpacity(
                                opacity: _isSettingTapped ? 0.5 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: const Icon(Icons.more_vert,
                                    color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Menu: ${widget.entry.menuName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '섭취량: ${widget.entry.intakeAmount}g',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      widget.entry.notes,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
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
        ),
      ),
    );
  }
}
