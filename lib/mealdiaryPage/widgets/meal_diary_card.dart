import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 접근
import 'dart:convert'; // JSON 파싱
import '../meal_diary_entry.dart'; // 식단 일기 데이터 모델

class MealDiaryCard extends StatefulWidget {
  final MealDiaryEntry entry; // 표시할 식단 일기 데이터
  final VoidCallback? onDelete; // 삭제 콜백 함수 (선택 사항)

  const MealDiaryCard({super.key, required this.entry, this.onDelete});

  @override
  State<MealDiaryCard> createState() => _MealDiaryCardState();
}

class _MealDiaryCardState extends State<MealDiaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController; // 페이드 애니메이션 컨트롤러
  late Animation<double> _fadeAnimation; // 페이드 애니메이션
  bool _isSettingTapped = false; // 설정(더보기) 버튼 탭 상태

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 애니메이션 지속 시간
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn, // 애니메이션 커브
    );
    _fadeController.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _fadeController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 다이어리 내용 업데이트 API 호출
  Future<void> updateDiary({
    required int mealInfoId, // 식사 정보 ID
    required int amount, // 섭취량 (API 스펙에 따라 필요할 수 있음)
    required String newDiary, // 새로운 다이어리 내용
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // 저장된 사용자 ID 가져오기

    if (userId == null) throw Exception('❗ 로그인 정보 없음');

    // API URL 구성 (쿼리 파라미터로 amount와 diary 전달)
    // TODO: API 기본 URL은 상수로 관리하는 것이 좋습니다.
    final url = Uri.parse(
      'http://152.67.196.3:4912/users/$userId/meal-info/$mealInfoId'
      '?amount=$amount&diary=${Uri.encodeComponent(newDiary)}', // diary 내용 URL 인코딩
    );

    final response = await http.patch(url, headers: {'Accept': '*/*'}); // PATCH 요청
    if (response.statusCode != 200) {
      throw Exception('다이어리 수정 실패: ${response.statusCode}, ${response.body}');
    }
    print('✅ 다이어리 업데이트 성공');
  }

  // 식단 기록 삭제 API 호출
  Future<void> deleteDiary(int mealInfoId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('❗ 로그인 정보 없음');

    final url = Uri.parse(
      'http://152.67.196.3:4912/users/$userId/meal-info/$mealInfoId',
    );

    final response = await http.delete(url); // DELETE 요청

    if (response.statusCode == 204 || response.statusCode == 200) { // 성공 (204 No Content 포함)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 삭제가 완료되었습니다')),
        );
      }
      print('✅ 식단 기록 삭제 성공');
      return;
    }
    throw Exception('삭제 실패: ${response.statusCode}, ${response.body}');
  }

  // 수정/삭제 옵션을 보여주는 모달 바텀 시트
  void _showEditDeleteOptions(BuildContext context, int mealInfoId) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))), // 상단 모서리 둥글게
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min, // 내용만큼 높이 차지
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note_outlined, color: Colors.blueAccent),
            title: const Text('메모 수정'),
            onTap: () => Navigator.pop(context, 'edit'), // 'edit' 액션 반환
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('기록 삭제', style: TextStyle(color: Colors.redAccent)),
            onTap: () => Navigator.pop(context, 'delete'), // 'delete' 액션 반환
          ),
        ],
      ),
    );

    if (action == 'edit') { // '메모 수정' 선택 시
      _editDiaryNote(context, mealInfoId);
    } else if (action == 'delete') { // '기록 삭제' 선택 시
      _confirmAndDeleteDiary(context, mealInfoId);
    }
  }

  // 다이어리 메모 수정 다이얼로그 표시
  void _editDiaryNote(BuildContext context, int mealInfoId) async {
    final controller = TextEditingController(text: widget.entry.notes); // 기존 메모 내용으로 초기화
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('식단 메모 수정'),
        content: TextField(
          controller: controller,
          maxLines: 4, // 여러 줄 입력 가능
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '메모를 입력하세요...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), // 취소
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text), // 저장 (입력된 텍스트 반환)
              child: const Text('저장')),
        ],
      ),
    );

    // 새 메모 내용이 있고 기존 내용과 다를 경우 업데이트
    if (result != null && result != widget.entry.notes) {
      try {
        await updateDiary(
          mealInfoId: mealInfoId,
          amount: widget.entry.intakeAmount, // API 스펙에 따라 필요한 섭취량 전달
          newDiary: result,
        );
        if (mounted) {
          setState(() {
            widget.entry.notes = result; // UI 즉시 업데이트
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 메모가 수정되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ 메모 수정 실패: $e')),
          );
        }
      }
    }
  }

  // 삭제 확인 다이얼로그 표시 후 삭제 실행
  void _confirmAndDeleteDiary(BuildContext context, int mealInfoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 식단 기록을 정말 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), // 취소
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true), // 삭제 확인
              child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) { // 사용자가 '삭제'를 확인했을 경우
      try {
        await deleteDiary(mealInfoId);
        widget.onDelete?.call(); // onDelete 콜백 호출 (UI에서 해당 아이템 제거)
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ 삭제 실패: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.28; // 이미지 크기를 화면 너비의 28%로 조정

    // mealInfoId 추출 (widget.entry.menuName이 "메뉴 ID: 123" 형식이라고 가정)
    // 실제 ID 추출 방식은 API 응답 및 MealDiaryEntry 모델에 따라 달라질 수 있음
    int? mealInfoId;
    try {
      mealInfoId = int.tryParse(widget.entry.menuName.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      print("mealInfoId 파싱 오류: ${widget.entry.menuName}, 오류: $e");
    }


    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 카드 모서리 둥글게
        elevation: 3, // 카드 그림자 효과
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 카드 외부 여백
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 카드 내부 여백
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // 내용물 상단 정렬
            children: [
              // 식단 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // 이미지 모서리 둥글게
                child: Image.network( // 네트워크 이미지 로드
                  widget.entry.imagePath,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover, // 이미지를 영역에 맞게 채움
                  errorBuilder: (context, error, stackTrace) { // 이미지 로드 실패 시
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.grey[200],
                      child: Icon(Icons.restaurant_menu, // 기본 아이콘 표시
                          color: Colors.grey[400], size: imageSize * 0.5),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) { // 로딩 중
                    if (loadingProgress == null) return child;
                    return Container(
                       width: imageSize,
                       height: imageSize,
                       color: Colors.grey[200],
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
              const SizedBox(width: 16.0), // 이미지와 텍스트 사이 간격

              // 식단 정보 (시간, 메뉴, 섭취량, 메모)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row( // 식사 시간 및 더보기 버튼
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.entry.time, // 식사 시간 (예: "오전 10:05")
                            style: const TextStyle(
                              fontSize: 18, // 폰트 크기 조정
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 더보기 (수정/삭제) 버튼
                        if (mealInfoId != null) // mealInfoId가 있을 때만 버튼 표시
                          GestureDetector(
                            behavior: HitTestBehavior.translucent, // 탭 영역 확장
                            onTapDown: (_) => setState(() => _isSettingTapped = true),
                            onTapUp: (_) {
                              setState(() => _isSettingTapped = false);
                              _showEditDeleteOptions(context, mealInfoId!); // 옵션 표시
                            },
                            onTapCancel: () =>
                                setState(() => _isSettingTapped = false),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 0, bottom: 8, right: 0), // 탭 영역 확보
                              child: AnimatedScale( // 탭 효과
                                scale: _isSettingTapped ? 0.85 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: AnimatedOpacity(
                                  opacity: _isSettingTapped ? 0.6 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(Icons.more_vert, color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text( // 메뉴 이름
                      // '메뉴 ID: ' 부분 제거하고 실제 메뉴 이름만 표시 (API 응답에 따라 수정 필요)
                      widget.entry.menuName.startsWith("메뉴 ID: ")
                          ? "메뉴: ${widget.entry.menuName.substring(6).trim()}"
                          : "메뉴: ${widget.entry.menuName}",
                      style: const TextStyle(
                        fontSize: 15, // 폰트 크기 조정
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text( // 섭취량
                      '섭취량: ${widget.entry.intakeAmount}g',
                      style: TextStyle(
                        fontSize: 13, // 폰트 크기 조정
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // 메모 (내용이 없으면 "작성된 메모가 없습니다." 표시)
                    Text(
                      widget.entry.notes.isEmpty ? "작성된 메모가 없습니다." : widget.entry.notes,
                      style: TextStyle(
                        fontSize: 12.5, // 폰트 크기 조정
                        color: widget.entry.notes.isEmpty ? Colors.grey.shade500 : Colors.grey[800],
                        height: 1.4, // 줄 간격
                      ),
                      maxLines: 3, // 최대 3줄 표시
                      overflow: TextOverflow.ellipsis, // 내용이 길면 말줄임표
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
