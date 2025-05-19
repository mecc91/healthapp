import 'package:flutter/material.dart';
import 'package:healthymeal/dashboardPage/dashboard.dart';

// ✅ 전역 RouteObserver 선언
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Meal',
      theme: ThemeData(
        fontFamily: 'korfont1', // ✅ 여기에 커스텀 폰트 적용
        useMaterial3: true, // 선택사항: Material 3 사용
      ),
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // ✅ 전역 인스턴스 사용
    );
  }
}
