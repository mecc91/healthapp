import 'package:flutter/material.dart';
import 'package:healthymeal/dashboardPage/dashboard.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ 로케일 데이터 초기화를 위해 추가

// ✅ 전역 RouteObserver 선언
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async { // ✅ async로 변경
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Flutter 엔진 바인딩 초기화 보장
  await initializeDateFormatting('ko_KR', null); // ✅ 한국어 로케일 초기화 (필요한 다른 로케일도 추가 가능)
  // 만약 다른 로케일도 지원해야 한다면 여러 번 호출하거나, 첫 번째 인자 없이 null로 호출하여 기본 로케일 데이터를 로드할 수 있습니다.
  // 예: await initializeDateFormatting(null, null); // 모든 지원 로케일 데이터 로드 (큰 앱에서는 비효율적일 수 있음)

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
      // ✅ 앱 전체적으로 한국어 로케일을 사용하려면 MaterialApp에도 설정할 수 있습니다.
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('ko', 'KR'),
      //   // 다른 지원 로케일 추가
      // ],
      // locale: const Locale('ko', 'KR'), // 기본 로케일 설정
    );
  }
}
