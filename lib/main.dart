import 'package:flutter/material.dart';
import 'package:healthymeal/dashboardPage/dashboard.dart'; // Dashboard 위젯 import


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 위젯으로 Dashboard를 감쌉니다.
    return MaterialApp(
      title: 'Healthy Meal', // 앱 제목 설정
      home: const Dashboard(), // Dashboard 위젯을 home으로 지정
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}