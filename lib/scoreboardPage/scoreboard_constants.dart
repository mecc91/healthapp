// scoreboard_constants.dart
import 'package:flutter/material.dart';

// Scoreboard 화면 전용 색상 (필요에 따라 앱 전체 테마와 통합 가능)
const Color primaryScoreboardColor = Colors.teal;
const Color accentScoreboardColor = Colors.redAccent;

// API 조회 범위 결정 등에 간접적으로 참고될 수 있습니다.
const int weeksOfDataBeforeToday = 12; // 예: 과거 12주 데이터 조회
const int weeksOfDataAfterToday = 4;  // 예: 미래 4주 데이터 조회 (필요시)


// 요일 이름 (차트 등에서 사용 - 영어)
// DateTime.weekday는 1(월요일) ~ 7(일요일)이므로, 인덱스 접근 시 주의 (dayNames[date.weekday-1])
const List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// 요일 이름 (달력 표시용 - 한국어, 일요일 시작)
// MonthlyCalendarView에서 emptyCellsPrefix 계산 시 DateTime.weekday (1:월 ~ 7:일)를
// 0:일 ~ 6:토 인덱스로 변환하여 사용합니다.
const List<String> dayNamesKorean = ['일', '월', '화', '수', '목', '금', '토'];

// 실제 API의 기본 URL (예시이므로 실제 URL로 변경해야 합니다)
const String apiBaseUrl = 'http://152.67.196.3:4912/v3';
