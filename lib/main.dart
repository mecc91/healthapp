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
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // ✅ 전역 인스턴스 사용
    );
  }
}
