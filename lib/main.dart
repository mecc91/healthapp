import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ 추가
import 'package:healthymeal/dashboardPage/dashboard.dart';
import 'package:healthymeal/loginPage/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

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
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const Dashboard(),
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      localizationsDelegates: [
        // ✅ DatePicker 오류 해결
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
    );
  }
}
