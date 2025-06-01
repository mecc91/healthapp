import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 사용자 ID 등 로컬 데이터 접근
import 'dart:convert'; // JSON 데이터 처리를 위해
import 'package:http/http.dart' as http; // HTTP 요청을 위해
import 'package:intl/intl.dart'; // 날짜 포맷팅

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

  // 위젯의 displayDate가 변경될 때마다 해당 날짜의 식단 일기를 다시 가져옴
  @override
  void didUpdateWidget(covariant MealDiaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayDate != widget.displayDate && _userId != null) {
      _fetchDiaryEntries(_userId!, widget.displayDate);
    }
  }

  // SharedPreferences에서 사용자 ID를 로드하고 식단 일기를 가져오는 함수
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

  // 특정 날짜의 식단 일기 목록을 서버에서 가져오는 함수
  Future<void> _fetchDiaryEntries(String userId, DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // API 엔드포인트 (특정 날짜의 데이터를 가져오도록 쿼리 파라미터 추가)
    // TODO: API 기본 URL은 상수로 관리하는 것이 좋습니다.
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = 'http://152.67.196.3:4912/users/$userId/meal-info?date=$formattedDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩

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
            _errorMessage = '식단 기록을 불러오는데 실패했습니다 (서버 오류: ${response.statusCode}).';
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
    // 날짜 포맷터 (예: "2023년 5월 30일 화요일")
    final DateFormat appBarDateFormat = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR');

    return Container(
      // 배경 그라데이션
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDE68A), // 상단 색상
            Color(0xFFC8E6C9), // 중간 색상
            Colors.white, // 하단 색상
          ],
          stops: [0.0, 0.5, 1.0], // 색상 전환 지점
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Scaffold 배경을 투명하게 하여 Container 그라데이션이 보이도록 함
        appBar: AppBar(
          title: Text(appBarDateFormat.format(widget.displayDate)), // 앱바 제목에 날짜 표시
          backgroundColor: Colors.transparent, // 앱바 배경 투명
          elevation: 0, // 앱바 그림자 제거
          leading: IconButton( // 뒤로가기 버튼
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때
            : _errorMessage.isNotEmpty
                ? Center( // 오류 발생 시
                    child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  ))
                : _diaryEntries.isEmpty
                    ? const Center(child: Text('해당 날짜의 식단 기록이 없습니다!')) // 기록이 없을 때
                    : ListView.builder( // 기록이 있을 때 목록 표시
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // 목록 상하 패딩
                        itemCount: _diaryEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _diaryEntries[index];
                          return MealDiaryCard(
                            key: ValueKey(entry.menuName + entry.createdAt.toIso8601String()), // 고유 키 부여 (삭제 시 애니메이션 등)
                            entry: entry,
                            onDelete: () { // 삭제 콜백 처리
                              if (mounted) {
                                setState(() {
                                  _diaryEntries.removeAt(index); // UI에서 즉시 제거
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
