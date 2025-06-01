// lib/dashboardPage/widgets/meal_diary_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청
import 'dart:convert'; // JSON 파싱
import 'package:intl/intl.dart'; // 날짜 및 시간 포맷팅

// API 응답을 위한 식사 항목 데이터 모델
class MealEntry {
  final String id; // 식사 기록의 고유 ID (API 응답에 따라 String 또는 int)
  final String imgPath; // 이미지 경로 (서버에서 제공하는 상대 경로)
  final int intakeAmount; // 섭취량 (그램 단위)
  final String? diary; // 사용자가 작성한 메모 (선택 사항)
  final DateTime createdAt; // 기록 생성 시간

  MealEntry({
    required this.id,
    required this.imgPath,
    required this.intakeAmount,
    this.diary,
    required this.createdAt,
  });

  // JSON 데이터로부터 MealEntry 객체를 생성하는 factory 생성자
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id']?.toString() ?? 'N/A', // ID가 null일 경우 'N/A'로 표시
      imgPath: json['imgPath'] as String? ?? '', // 이미지 경로가 null일 경우 빈 문자열
      intakeAmount: json['intakeAmount'] as int? ?? 0, // 섭취량이 null일 경우 0
      diary: json['diary'] as String?, // 메모는 null일 수 있음
      createdAt: DateTime.parse(json['createdAt'] as String), // 생성 시간 파싱
    );
  }
}

class MealDiaryCard extends StatefulWidget {
  final String diaryDate; // 표시할 식단 일기의 날짜 (yyyy-MM-dd 형식)
  final String userId; // 현재 사용자 ID
  final VoidCallback? onTap; // 카드 탭 시 실행될 콜백 (선택 사항)
  final Function(TapDownDetails)? onTapDown; // 탭 다운 이벤트 콜백 (선택 사항)
  final Function(TapUpDetails)? onTapUp; // 탭 업 이벤트 콜백 (선택 사항)
  final VoidCallback? onTapCancel; // 탭 취소 이벤트 콜백 (선택 사항)
  final double scale; // 탭 애니메이션을 위한 스케일 값

  const MealDiaryCard({
    super.key,
    required this.userId,
    required this.diaryDate,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.scale = 1.0, // 기본 스케일 값
  });

  @override
  State<MealDiaryCard> createState() => _MealDiaryCardState();
}

class _MealDiaryCardState extends State<MealDiaryCard> {
  List<MealEntry> _todayMeals = []; // 오늘 기록된 식사 목록
  bool _isLoading = true; // 데이터 로딩 상태
  String _errorMessage = ''; // 오류 메시지

  // TODO: API 기본 URL은 상수로 관리하는 것이 좋습니다.
  final String _imageBaseUrl = 'http://152.67.196.3:4912/uploads/';

  @override
  void initState() {
    super.initState();
    _fetchTodayMeals(); // 위젯 초기화 시 오늘 식사 기록 가져오기
  }

  @override
  void didUpdateWidget(covariant MealDiaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // userId 또는 diaryDate가 변경되면 데이터 다시 로드
    if (oldWidget.userId != widget.userId || oldWidget.diaryDate != widget.diaryDate) {
      _fetchTodayMeals();
    }
  }

  // 오늘 식사 기록을 서버에서 가져오는 함수
  Future<void> _fetchTodayMeals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // API 엔드포인트 (특정 날짜의 식단 정보를 가져오도록 쿼리 파라미터 사용)
    // TODO: API 기본 URL은 상수로 관리
    final url = Uri.parse(
      'http://152.67.196.3:4912/users/${widget.userId}/meal-info?date=${widget.diaryDate}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
        final filtered = data
            .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬

        setState(() {
          // 대시보드 요약이므로 최대 3개만 표시 (필요시 조절)
          _todayMeals = filtered.take(3).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '식단 정보를 불러오지 못했습니다 (서버 오류: ${response.statusCode}).';
        });
      }
    } catch (e) {
      print('오늘 식단 불러오기 실패: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '식단 정보를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTapDown,
        onTapUp: widget.onTapUp,
        onTapCancel: widget.onTapCancel,
        child: AnimatedScale(
          scale: widget.scale,
          duration: const Duration(milliseconds: 150),
          child: Card(
            color: const Color(0xFFFCFCFC),
            elevation: 4, // 그림자 조정
            shadowColor: Colors.grey.withAlpha(50), // 그림자 색상 조정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "오늘의 식단 일기 요약 (${widget.diaryDate})", // 카드 제목
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading) // 로딩 중
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: CircularProgressIndicator(strokeWidth: 2.0,),
                    ))
                  else if (_errorMessage.isNotEmpty) // 오류 발생
                     Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(_errorMessage, style: const TextStyle(fontSize: 15, color: Colors.redAccent)),
                      ),
                    )
                  else if (_todayMeals.isEmpty) // 기록 없음
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "오늘의 식단 기록이 없습니다.",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ),
                    )
                  else // 기록 있음: ListView로 표시
                    ListView.separated(
                      shrinkWrap: true, // 내용만큼만 높이 차지
                      physics: const NeverScrollableScrollPhysics(), // 카드 내 스크롤 방지
                      itemCount: _todayMeals.length,
                      itemBuilder: (context, index) {
                        final entry = _todayMeals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0), // 각 항목 간 여백
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 식단 이미지
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  _imageBaseUrl + entry.imgPath, // 완전한 이미지 URL
                                  width: 80, // 이미지 크기 조정
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) { // 이미지 로드 실패 시
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.restaurant_menu_outlined, // 아이콘 변경
                                        color: Colors.grey.shade400,
                                        size: 30, // 아이콘 크기 조정
                                      ),
                                    );
                                  },
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) { // 로딩 중
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 식단 정보 (메뉴 ID, 시간, 섭취량, 메모)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text( // 메뉴 ID (또는 실제 메뉴 이름)
                                      "메뉴: ${entry.id}", // API 응답에 따라 실제 메뉴 이름 필드가 있다면 그것을 사용
                                      style: const TextStyle(
                                        fontSize: 16, // 폰트 크기 조정
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text( // 기록 시간
                                      DateFormat('a h:mm', 'ko_KR').format(entry.createdAt), // 한국 기준 오전/오후 시간
                                      style: const TextStyle(
                                        fontSize: 13, // 폰트 크기 조정
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text( // 섭취량
                                      "섭취량: ${entry.intakeAmount}g",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text( // 메모
                                      entry.diary ?? "작성된 메모가 없습니다.",
                                      style: TextStyle(
                                        fontSize: 12, // 폰트 크기 조정
                                        color: entry.diary == null || entry.diary!.isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black54,
                                        height: 1.3, // 줄 간격 조정
                                      ),
                                      maxLines: 2, // 최대 2줄 표시
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider( // 각 항목 구분선
                        color: Colors.grey.shade200,
                        thickness: 0.8, // 구분선 두께 조정
                        height: 20, // 구분선 높이(여백) 조정
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
