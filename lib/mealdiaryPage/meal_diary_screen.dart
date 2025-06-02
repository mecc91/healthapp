import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 사용자 ID 등 로컬 데이터 접근
import 'dart:convert'; // JSON 데이터 처리를 위해
import 'package:http/http.dart' as http; // HTTP 요청을 위해
import 'package:intl/intl.dart'; // 날짜 포맷팅
import 'package:healthymeal/dashboardPage/dashboard.dart'; // ✅ Dashboard 임포트

import 'meal_diary_entry.dart'; // 식단 일기 데이터 모델
import 'widgets/meal_diary_card.dart'; // 각 식단 일기를 표시하는 카드 위젯

class MealDiaryScreen extends StatefulWidget {
  final DateTime displayDate; // 특정 날짜의 식단 일기를 표시 (대시보드에서 전달받음)

  const MealDiaryScreen({
    super.key,
    required this.displayDate,
  });

  @override
  State<MealDiaryScreen> createState() => _MealDiaryScreenState();
}

class _MealDiaryScreenState extends State<MealDiaryScreen> {
  List<MealDiaryEntry> _diaryEntries = []; // 화면에 표시될 식단 일기 목록
  bool _isLoading = true; // 데이터 로딩 상태
  String? _userId; // 현재 로그인한 사용자 ID
  String _errorMessage = ''; // 오류 메시지

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchEntries(); // 사용자 ID 로드 후 식단 일기 가져오기
  }

  @override
  void didUpdateWidget(covariant MealDiaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayDate != widget.displayDate && _userId != null) {
      _fetchDiaryEntries(_userId!, widget.displayDate);
    }
  }

  Future<void> _loadUserIdAndFetchEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '사용자 정보를 찾을 수 없습니다. 로그인이 필요합니다.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _userId = userId);
      _fetchDiaryEntries(userId, widget.displayDate); // 특정 날짜의 데이터 가져오기
    }
  }

  Future<void> _fetchDiaryEntries(String userId, DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        'http://152.67.196.3:4912/users/$userId/meal-info?date=$formattedDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        if (mounted) {
          setState(() {
            _diaryEntries = data
                .map((e) => MealDiaryEntry.fromJson(e as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                '식단 기록을 불러오는데 실패했습니다 (서버 오류: ${response.statusCode}).';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '식단 기록을 불러오는 중 오류가 발생했습니다: $e';
        });
      }
      print('❌ [식단 일기 로드 에러 발생]: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat appBarDateFormat = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR');

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
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(appBarDateFormat.format(widget.displayDate)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  )
                : _diaryEntries.isEmpty
                    ? const Center(child: Text('해당 날짜의 식단 기록이 없습니다!'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _diaryEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _diaryEntries[index];
                          return MealDiaryCard(
                            key: ValueKey(entry.foodName +
                                entry.createdAt.toIso8601String()),
                            entry: entry,
                            onDelete: () {
                              if (mounted) {
                                setState(() {
                                  _diaryEntries.removeAt(index);
                                });
                              }
                            },
                          );
                        },
                      ),
      ),
    );
  }
}
