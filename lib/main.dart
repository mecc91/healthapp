import 'package:flutter/material.dart';
// import 'package:healthymeal/gptPages/scoreboard.dart'; // 필요하다면 주석 해제
import 'package:healthymeal/Pages/dashboard.dart'; // Dashboard 위젯 import
// 안녕!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 위젯으로 Dashboard를 감쌉니다.
    return MaterialApp(
      title: 'Healthy Meal App', // 앱 제목 설정
      // theme 관련 설정 제거됨
      home: const Dashboard(), // Dashboard 위젯을 home으로 지정
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}