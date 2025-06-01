import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'meal_diary_entry.dart';
import 'widgets/meal_diary_card.dart';

class MealDiaryScreen extends StatefulWidget {
  final DateTime displayDate;

  const MealDiaryScreen({
    super.key,
    required this.displayDate,
  });

  @override
  State<MealDiaryScreen> createState() => _MealDiaryScreenState();
}

class _MealDiaryScreenState extends State<MealDiaryScreen> {
  List<MealDiaryEntry> _diaryEntries = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
  }

  void _loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _userId = userId);
    _fetchDiaryEntries(userId);
  }

  @override
  void didUpdateWidget(covariant MealDiaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayDate != widget.displayDate && _userId != null) {
      _fetchDiaryEntries(_userId!);
    }
  }

  Future<void> _fetchDiaryEntries(String userId) async {
    setState(() => _isLoading = true);

    final now = widget.displayDate;
    final oneWeekAgo = now.subtract(const Duration(days: 6));

    final url = 'http://152.67.196.3:4912/users/$userId/meal-info';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        final filteredData = data.where((e) {
          final entryDate = DateTime.parse(e['createdAt']);
          return entryDate.isAfter(oneWeekAgo.subtract(const Duration(seconds: 1))) &&
              entryDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();

        setState(() {
          _diaryEntries = filteredData
              .map((e) => MealDiaryEntry.fromJson(e))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ [에러 발생]: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
                              Color(0xFFFDE68A),
                  Color(0xFFC8E6C9),
                  Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ✅ 배경 투명 처리
        appBar: AppBar(title: const Text('식단 일기')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _diaryEntries.isEmpty
                ? const Center(child: Text('식단 기록이 없습니다!'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _diaryEntries.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final entry = _diaryEntries[index];
                      return MealDiaryCard(
                        entry: entry,
                        onDelete: () {
                          setState(() {
                            _diaryEntries.remove(entry); // 삭제 후 즉시 반영
                          });
                        },
                      );
                    },
                  ),
      ),
    );
  }
}