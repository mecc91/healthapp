import 'package:flutter/material.dart';

// Scoreboard 화면 전용 색상 (필요에 따라 앱 전체 테마와 통합 가능)
const Color primaryScoreboardColor = Colors.teal;
const Color accentScoreboardColor = Colors.redAccent;

// 데이터 시뮬레이션 설정
const int weeksOfDataBeforeToday = 4;
const int weeksOfDataAfterToday = 0;

// 요일 이름 (차트 등에서 사용)
const List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];