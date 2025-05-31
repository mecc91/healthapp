// lib/dashboardPage/dashboard.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:healthymeal/mealrecordPage/services/meal_gpt_service.dart';
import 'package:healthymeal/profilePage/profile.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
import 'package:healthymeal/underconstructionPage/underconstruction.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import 'package:healthymeal/mealdiaryPage/meal_diary_screen.dart';
import 'package:path_provider/path_provider.dart';

// RouteObserver를 사용하기 위해 main.dart 또는 해당 Observer가 정의된 파일을 import
// 예시 경로이며, 실제 프로젝트 구조에 맞게 수정해야 합니다.
import '../main.dart'; // ✅ 수정: main.dart의 routeObserver를 사용하기 위해 import

// 분리된 위젯 import
import 'widgets/dashboard_header.dart';
import 'widgets/daily_status_summary_card.dart';
import 'widgets/weekly_score_summary_card.dart';
import 'widgets/meal_diary_card.dart'; // dashboard용 MealDiaryCard (날짜 문자열을 받도록 가정)

// main.dart 또는 앱의 최상위 위젯에 RouteObserver 인스턴스가 정의되어 있다고 가정합니다.
// 예: final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
// 이 파일에서는 직접 정의하지 않고, 외부에서 주입받거나 static으로 접근한다고 가정합니다.
// 아래 코드는 예시이며, 실제 프로젝트의 RouteObserver 설정에 맞게 조정해야 합니다.
// 만약 main.dart 등에 routeObserver가 static으로 선언되어 있다면 아래와 같이 사용 가능:
// import 'package:healthymeal/main.dart'; // (main.dart에 routeObserver가 있다고 가정)

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with RouteAware, SingleTickerProviderStateMixin {
  // RouteAware, SingleTickerProviderStateMixin 추가
  final ImagePicker _picker = ImagePicker();

  // _scoreCardKey 및 _dailyCardKey는 이전 코드에서 사용되었으나,
  // 제공된 최신 dashboard.dart에서는 애니메이션 컨트롤에 직접 사용되지 않으므로,
  // 필요 없다면 제거해도 됩니다. 여기서는 일단 유지합니다.
  int _scoreCardKey = DateTime.now().microsecondsSinceEpoch;
  int _dailyCardKey = DateTime.now().microsecondsSinceEpoch + 1;

  double _avatarScale = 1.0;
  int _selectedIndex = 1; // 초기 선택 인덱스를 카메라(1)로 설정
  double _dailyCardScale = 1.0;
  double _scoreCardScale = 1.0;
  double _mealDiaryCardScale = 1.0; // MealDiaryCard 탭 애니메이션을 위한 변수

  // GPT Service
  final MealGptService _mealGptService = MealGptService();
  late XFile _dummyMealImage;
    // dummyMealImage 초기화를 위한 함수 (디버그용)
  void setDummy() async {
    final fileName = "chicken.jpg";
    final byteData = await rootBundle.load("assets/image/chicken.jpg");
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/$fileName");
    await file.writeAsBytes(byteData.buffer.asUint8List());
    _dummyMealImage =  XFile(file.path);
  }

  // 애니메이션 컨트롤러 (이전 코드에서 참조)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 페이지가 빌드된 후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });

    // dummyMealImage 초기화
    setDummy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver 구독 (main.dart 등에 routeObserver가 정의되어 있어야 함)
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // ✅ 수정: main.dart에서 가져온 전역 routeObserver 인스턴스 사용
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // 다른 화면에서 이 화면으로 돌아올 때 애니메이션 재시작
    if (mounted) {
      _animationController.forward(from: 0);
      final now = DateTime.now().microsecondsSinceEpoch;
      setState(() {
        _scoreCardKey = now; // 키 값을 업데이트하여 위젯을 새로 그리도록 유도 (필요한 경우)
        _dailyCardKey = now + 1;
        _avatarScale = 0.9; // 간단한 시각적 피드백
        _dailyCardScale = 0.95;
        _scoreCardScale = 0.95;
        _mealDiaryCardScale = 0.95;
      });
      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted) {
          setState(() {
            _avatarScale = 1.0;
            _dailyCardScale = 1.0;
            _scoreCardScale = 1.0;
            _mealDiaryCardScale = 1.0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // RouteObserver 구독 해지
    // ✅ 수정: main.dart에서 가져온 전역 routeObserver 인스턴스 사용
    // 현재 route를 가져와야 하므로, ModalRoute.of(context)를 사용합니다.
    // 다만, dispose 시점에는 context가 안전하지 않을 수 있으므로,
    // 일반적으로는 didChangeDependencies에서 얻은 PageRoute 객체를 멤버 변수로 저장해두고 사용합니다.
    // 여기서는 RouteObserver의 untrack 메서드를 직접 호출하기보다는,
    // subscribe 시 전달한 route 객체를 사용하여 unsubscribe 하는 것이 일반적입니다.
    // RouteObserver는 내부적으로 RouteAware 객체와 Route 쌍을 관리합니다.
    // 현재 ModalRoute.of(context)가 PageRoute 타입이 아닐 수도 있으므로 주의해야 합니다.
    // 가장 안전한 방법은 didChangeDependencies에서 구독할 때 사용한 route 객체를 저장해두는 것입니다.
    // 여기서는 간단하게 routeObserver.unsubscribe(this)만 호출합니다.
    // RouteObserver는 내부적으로 this (RouteAware 객체)와 매핑된 모든 라우트 구독을 해제합니다.
    routeObserver.unsubscribe(this);
    _animationController.dispose();
    super.dispose();
  }

  // 현재 날짜를 가져와 포맷팅하는 함수
  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
  
  // 카메라 버튼 클릭시 사진촬영 & MealRecord Page로 분기
  Future<void> _takePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (mounted) {
        _navigateWithFade(
          context,
          MealRecord(initialImageFile: pickedFile),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 촬영이 취소되었거나 실패했습니다.')),
        );
      }
    }
  }

  // Fade animation과 함께 Page 분기
  void _navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Bottom NavBar 파트
  void _onBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Scoreboard Page로 분기
    if (index == 0) {
      _navigateWithFade(context, const ScoreboardScreen());
      // MealRecord Page로 분기
    } else if (index == 1) {
      // MealDiaryScreen으로 현재 날짜를 전달하며 이동 (카메라 아이콘 탭 시)
      // 현재는 _takePicture()를 호출하도록 되어 있습니다.
      // 만약 식단 기록 화면으로 바로 이동시키려면 아래 주석을 해제하고 _takePicture()를 주석 처리합니다.
      //_navigateWithFade(context, MealRecord(initialImageFile: _dummyMealImage));     // 사진촬영없이 바로분기
      _takePicture(); // 사진 촬영 로직
      //_mealGptService.sendPing();

      // MenuRecommend Page로 분기
    } else if (index == 2) {
      _navigateWithFade(context, const MenuRecommendScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDateString = getCurrentDateFormatted();
    DateTime currentDateAsDateTime;
    try {
      currentDateAsDateTime = DateFormat('yyyy-MM-dd').parse(currentDateString);
    } catch (e) {
      currentDateAsDateTime = DateTime.now(); // Fallback
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // Stack : non-positioned widget을 배치할 수 있음 (왼쪽 상단이 start)
      //         Positioned(left:, right:, top:, bottom:) 위젯으로 원하는 위젯을 배치 가능
      body: Stack(
        children: [
          // 배경 컨테이너
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE68A),
                  Color(0xFFC8E6C9),
                  Colors.white,
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: SlideTransition(
                // 전체 컬럼에 슬라이드/페이드 애니메이션 적용
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  // Dashboard 위젯 배치
                  child: Column(
                    children: [
                      // Dashboard 헤더 (알림아이콘 & 프로필아이콘)
                      DashboardHeader(
                        avatarScale: _avatarScale,
                        onAvatarTapDown: (_) =>
                            setState(() => _avatarScale = 0.85),
                        onAvatarTapUp: (_) {
                          setState(() => _avatarScale = 1.0);
                          _navigateWithFade(context, const Profile());
                        },
                        onAvatarTapCancel: () =>
                            setState(() => _avatarScale = 1.0),
                        onNotificationsPressed: () {
                          _navigateWithFade(context, const Underconstruction());
                        },
                      ),
                      // DailyStatus Widget
                      DailyStatusSummaryCard(
                        key: ValueKey('dailyCard_$_dailyCardKey'), // Key 사용 예시
                        scale: _dailyCardScale,
                        onTapDown: (_) =>
                            setState(() => _dailyCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _dailyCardScale = 1.0);
                          _navigateWithFade(context, const DailyStatus());
                        },
                        onTapCancel: () =>
                            setState(() => _dailyCardScale = 1.0),
                      ),
                      // Scoreboard Widget
                      WeeklyScoreSummaryCard(
                        key: ValueKey('scoreCard_$_scoreCardKey'), // Key 사용 예시
                        scale: _scoreCardScale,
                        onTapDown: (_) =>
                            setState(() => _scoreCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _scoreCardScale = 1.0);
                          _navigateWithFade(context, const ScoreboardScreen());
                        },
                        onTapCancel: () =>
                            setState(() => _scoreCardScale = 1.0),
                      ),
                      // MealDiaryCard 섹션 (사용자가 제공한 코드 스타일 적용)
                      GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _mealDiaryCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _mealDiaryCardScale = 1.0);
                          // MealDiaryScreen으로 네비게이션, displayDate에 currentDateAsDateTime 전달
                          _navigateWithFade(
                              context,
                              MealDiaryScreen(
                                  displayDate: currentDateAsDateTime));
                        },
                        onTapCancel: () =>
                            setState(() => _mealDiaryCardScale = 1.0),
                        child: AnimatedScale(
                          scale: _mealDiaryCardScale,
                          duration: const Duration(milliseconds: 150),
                          child: MealDiaryCard(
                            // widgets/meal_diary_card.dart의 MealDiaryCard가
                            // diaryDate라는 이름으로 String 타입의 날짜를 받는다고 가정
                            diaryDate: currentDateString,
                            // onTap은 상위 GestureDetector에서 처리하므로 여기서는 필요 없음
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // 하단 여백 추가
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // BottomNavBar (Dashboard 전용)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, size: 35),
              label: ''), // 스코어보드 (인덱스 0)
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt, size: 35),
              label: ''), // 식단 기록 (인덱스 1)
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border, size: 35),
              label: ''), // 메뉴 추천 (인덱스 2)
        ],
      ),
    );
  }
}
