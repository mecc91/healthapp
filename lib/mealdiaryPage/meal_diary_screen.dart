// lib/mealDiaryPage/meal_diary_screen.dart
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
    final dateString = DateFormat('yyyy-MM-dd').format(widget.displayDate);
    final url =
        'http://152.67.196.3:4912/users/$userId/meal-info?date=$dateString';

    print('🟡 [요청 날짜]: $dateString');
    print('🟡 [요청 userId]: $userId');
    print('🌐 [요청 URL]: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('📦 [응답 상태코드]: ${response.statusCode}');
      print('📦 [응답 본문]: ${response.body}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        print('✅ [파싱된 리스트 길이]: ${data.length}');
        if (data.isNotEmpty) {
          print('✅ [첫 항목 샘플]: ${data.first}');
        }

        setState(() {
          _diaryEntries = data.map((e) => MealDiaryEntry.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print('❌ [요청 실패] 상태코드: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ [에러 발생]: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('식단 일기')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diaryEntries.isEmpty
              ? const Center(child: Text('식단 기록이 없습니다!.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _diaryEntries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final entry = _diaryEntries[index];
                    return MealDiaryCard(entry: entry);
                  },
                ),
    );
  }
}
