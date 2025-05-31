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
import 'package:intl/intl.dart';
import 'package:healthymeal/mealdiaryPage/meal_diary_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// RouteObserver를 사용하기 위해 main.dart 또는 해당 Observer가 정의된 파일을 import
// 예시 경로이며, 실제 프로젝트 구조에 맞게 수정해야 합니다.
import '../main.dart'; // ✅ 수정: main.dart의 routeObserver를 사용하기 위해 import

// 분리된 위젯 import
import 'widgets/dashboard_header.dart';
import 'widgets/daily_status_summary_card.dart';
import 'widgets/weekly_score_summary_card.dart';
import 'widgets/meal_diary_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with RouteAware, SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  int _scoreCardKey = DateTime.now().microsecondsSinceEpoch;
  int _dailyCardKey = DateTime.now().microsecondsSinceEpoch + 1;
  int _mealDiaryCardKey = DateTime.now().microsecondsSinceEpoch + 2;
  double _avatarScale = 1.0;
  int _selectedIndex = 1;
  double _dailyCardScale = 1.0;
  double _scoreCardScale = 1.0;
  double _mealDiaryCardScale = 1.0;
  final MealGptService _mealGptService = MealGptService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _userId;

  late final String currentDateString;
  late final DateTime currentDateAsDateTime;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    currentDateString = DateFormat('yyyy-MM-dd').format(now);
    currentDateAsDateTime = now;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
      }
    });
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (mounted) {
      setState(() {
        _userId = id;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (mounted) {
      _animationController.forward(from: 0);
      final now = DateTime.now().microsecondsSinceEpoch;
      setState(() {
        _scoreCardKey = now;
        _dailyCardKey = now + 1;
        _mealDiaryCardKey = now + 2;
        _avatarScale = 0.9;
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
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
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
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
                      DailyStatusSummaryCard(
                        key: ValueKey('dailyCard_$_dailyCardKey'),
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
                      WeeklyScoreSummaryCard(
                        key: ValueKey('scoreCard_$_scoreCardKey'),
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
                      GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _mealDiaryCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _mealDiaryCardScale = 1.0);
                          _navigateWithFade(
                            context,
                            MealDiaryScreen(displayDate: currentDateAsDateTime),
                          );
                        },
                        onTapCancel: () =>
                            setState(() => _mealDiaryCardScale = 1.0),
                        child: AnimatedScale(
                          scale: _mealDiaryCardScale,
                          duration: const Duration(milliseconds: 150),
                          child: _userId == null
                              ? const SizedBox.shrink()
                              : MealDiaryCard(
                                  diaryDate: currentDateString,
                                  userId: _userId!,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
              icon: Icon(Icons.bar_chart, size: 35), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt, size: 35), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border, size: 35), label: ''),
        ],
      ),
    );
  }
}
