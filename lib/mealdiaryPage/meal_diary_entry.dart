// lib/mealdiaryPage/meal_diary_entry.dart
import 'package:intl/intl.dart'; // 날짜 및 시간 포맷팅을 위해

class MealDiaryEntry {
  final String imagePath; // 음식 이미지 경로 (네트워크 URL)
  final String time; // 식사 시간 (포맷팅된 문자열, 예: "오전 10:05")
  final String menuName; // 메뉴 이름 또는 식별자 (예: "메뉴 ID: 123")
  final int intakeAmount; // 섭취량 (그램 단위)
  final DateTime createdAt; // 기록 생성 시간 (정렬 및 필터링에 사용)
  String notes; // 사용자가 작성한 메모 (수정 가능)

  MealDiaryEntry({
    required this.imagePath,
    required this.time,
    required this.menuName,
    required this.intakeAmount,
    required this.notes,
    required this.createdAt,
  });

  // JSON 데이터로부터 MealDiaryEntry 객체를 생성하는 factory 생성자
  factory MealDiaryEntry.fromJson(Map<String, dynamic> json) {
    // createdAt 필드가 문자열로 제공된다고 가정하고 DateTime 객체로 파싱
    final DateTime createdAt = DateTime.parse(json['createdAt'] as String);
    // createdAt 시간을 한국 기준 오전/오후 시간으로 포맷팅 (예: "오후 3:20")
    final String timeFormatted = DateFormat('a h:mm', 'ko_KR').format(createdAt);

    // API 응답의 imgPath에 기본 URL을 추가하여 완전한 이미지 경로 생성
    // TODO: API 기본 URL은 상수로 관리하는 것이 좋습니다.
    final String imageBaseUrl = 'http://152.67.196.3:4912/uploads/';
    final String fullImagePath = imageBaseUrl + (json['imgPath'] as String? ?? '');

    return MealDiaryEntry(
      imagePath: fullImagePath, // 완전한 이미지 URL
      time: timeFormatted, // 포맷팅된 식사 시간
      // menuName은 API 응답의 'id' 필드를 사용하여 "메뉴 ID: [id]" 형식으로 구성
      menuName: '메뉴 ID: ${json['id']?.toString() ?? '알 수 없음'}',
      // intakeAmount가 null일 경우 0으로 기본값 설정
      intakeAmount: json['intakeAmount'] as int? ?? 0,
      // diary(메모)가 null일 경우 빈 문자열로 기본값 설정
      notes: json['diary'] as String? ?? '',
      createdAt: createdAt, // 파싱된 DateTime 객체
    );
  }
}
