import 'package:flutter/material.dart';
import 'package:healthymeal/dashboardPage/dashboard.dart';
import 'package:healthymeal/loginPage/login.dart'; // 로그인 페이지 import
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // ✅ SharedPreferences로 로그인 상태 확인
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  runApp(MyApp(initialRoute: userId == null ? '/' : '/dashboard'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Meal',
      theme: ThemeData(
        fontFamily: 'korfont1',
        useMaterial3: true,
      ),
      initialRoute: initialRoute, // ✅ 자동 로그인 처리
      routes: {
        '/': (context) => const LoginPage(), // 로그인 페이지
        '/dashboard': (context) => const Dashboard(), // 대시보드
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
    );
  }
}
