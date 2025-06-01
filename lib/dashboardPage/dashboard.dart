// lib/dashboardPage/dashboard.dart

import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart'; // 일일 상태 페이지
import 'package:healthymeal/mealrecordPage/mealrecord.dart'; // 식사 기록 페이지
import 'package:healthymeal/profilePage/profile.dart'; // 프로필 페이지
import 'package:healthymeal/recommendationPage/recommendation.dart'; // 메뉴 추천 페이지
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import 'package:healthymeal/scoreboardPage/scoreboard.dart'; // 스코어보드 페이지
import 'package:healthymeal/underconstructionPage/underconstruction.dart'; // 개발 중 페이지
import 'package:intl/intl.dart'; // 날짜 포맷팅
import 'package:healthymeal/mealdiaryPage/meal_diary_screen.dart'; // 식단 일기 상세 페이지
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 접근

import '../main.dart'; // routeObserver 사용 (main.dart에 정의되어 있어야 함)
import 'widgets/dashboard_header.dart'; // 대시보드 헤더 위젯
import 'widgets/daily_status_summary_card.dart'; // 일일 상태 요약 카드 위젯
import 'widgets/weekly_score_summary_card.dart'; // 주간 점수 요약 카드 위젯
import 'widgets/meal_diary_card.dart' as DashboardMealDiaryCard; // 이름 충돌 방지를 위한 alias

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with RouteAware, SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker(); // 이미지 선택기 인스턴스

  // 각 카드의 애니메이션 및 새로고침을 위한 고유 키
  int _scoreCardKey = DateTime.now().microsecondsSinceEpoch;
  int _dailyCardKey = DateTime.now().microsecondsSinceEpoch + 1;
  int _mealDiaryCardKey = DateTime.now().microsecondsSinceEpoch + 2;

  // 위젯 스케일 애니메이션을 위한 변수
  double _avatarScale = 1.0;
  double _dailyCardScale = 1.0;
  double _scoreCardScale = 1.0;
  double _mealDiaryCardScale = 1.0;

  int _selectedIndexInBottomNav = 1; // 하단 네비게이션 바의 현재 선택된 인덱스 (1: 카메라(식사기록))

  // 페이지 진입/퇴장 애니메이션 컨트롤러
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation; // 페이드 효과
  late Animation<Offset> _slideAnimation; // 슬라이드 효과

  String? _userId; // 현재 사용자 ID
  late String _currentDateStringForMealDiary; // 오늘 날짜 문자열 (식단 일기 카드용)
  late DateTime _currentDateAsDateTimeForMealDiary; // 오늘 날짜 DateTime 객체 (식단 일기 상세 화면 전달용)


  @override
  void initState() {
    super.initState();

    // 오늘 날짜 설정
    final now = DateTime.now();
    _currentDateStringForMealDiary = DateFormat('yyyy-MM-dd').format(now);
    _currentDateAsDateTimeForMealDiary = now;

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 애니메이션 지속 시간
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // 아래에서 약간 위로 올라오는 효과
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 위젯 빌드 후 애니메이션 시작 및 사용자 ID 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
      _loadUserId();
    });
  }

  // SharedPreferences에서 사용자 ID 로드
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (mounted) {
      setState(() {
        _userId = id;
      });
    }
  }

  // RouteAware 관련 설정: 다른 화면에서 돌아왔을 때 UI 갱신 및 애니메이션 재시작
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route); // main.dart의 routeObserver 구독
    }
  }

  @override
  void didPopNext() { // 다른 화면에서 이 화면으로 돌아왔을 때 호출
    if (mounted) {
      _animationController.forward(from: 0.0); // 페이지 진입 애니메이션 다시 시작
      final nowMicroseconds = DateTime.now().microsecondsSinceEpoch;
      // 카드들의 key를 변경하여 강제로 다시 그리도록 함 (데이터 새로고침 효과)
      // 스케일 애니메이션을 위한 초기화
      setState(() {
        _scoreCardKey = nowMicroseconds;
        _dailyCardKey = nowMicroseconds + 1;
        _mealDiaryCardKey = nowMicroseconds + 2; // 식단 일기 카드 키도 업데이트
        _avatarScale = 0.9; // 아바타 스케일 초기화 (탭 효과 준비)
        _dailyCardScale = 0.95;
        _scoreCardScale = 0.95;
        _mealDiaryCardScale = 0.95;
        _selectedIndexInBottomNav = 1; // 대시보드로 돌아오면 중앙 탭 활성화
      });
      // 짧은 지연 후 스케일을 원래대로 복원하여 시각적 효과 제공
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _avatarScale = 1.0;
            _dailyCardScale = 1.0;
            _scoreCardScale = 1.0;
            _mealDiaryCardScale = 1.0;
          });
        }
      });
       _loadUserId(); // 사용자 ID를 다시 로드하여 최신 상태 반영 (예: 로그아웃 후 재로그인)
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // routeObserver 구독 해지
    _animationController.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }

  // 카메라를 통해 사진을 촬영하고 식사 기록 화면으로 이동
  Future<void> _takePictureAndNavigateToMealRecord() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1200);
      if (pickedFile != null) {
        if (mounted) {
          _navigateWithFadeTransition( // 페이드 전환 효과와 함께 페이지 이동
            context,
            MealRecord(initialImageFile: pickedFile), // 촬영한 이미지를 전달
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진 촬영이 취소되었거나 실패했습니다.')),
          );
        }
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 접근 중 오류 발생: $e')),
        );
      }
    }
  }

  // 페이드 전환 효과를 사용한 페이지 이동 함수
  void _navigateWithFadeTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300), // 전환 시간
      ),
    );
  }

  // 하단 네비게이션 바 아이템 탭 시 호출되는 함수
  void _onBottomNavigationTap(int index) {
    if (_selectedIndexInBottomNav == index && index != 1) return; // 이미 선택된 탭(카메라 제외)이면 무시
    
    setState(() {
      _selectedIndexInBottomNav = index;
    });

    switch (index) {
      case 0: // 스코어보드
        _navigateWithFadeTransition(context, const ScoreboardScreen());
        break;
      case 1: // 식사 기록 (카메라)
        _takePictureAndNavigateToMealRecord();
        // 카메라 화면에서 돌아올 때 _selectedIndexInBottomNav를 다시 1로 설정하기 위해 didPopNext에서 처리
        break;
      case 2: // 메뉴 추천
        _navigateWithFadeTransition(context, const MenuRecommendScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // 전체 배경색
      body: Stack( // 배경 그라데이션과 내용을 겹치기 위해 Stack 사용
        children: [
          // 상단 배경 그라데이션
          Container(
            height: 220, // 그라데이션 높이
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE68A), // 밝은 노란색
                  Color(0xFFC8E6C9), // 연한 녹색
                  Colors.white,      // 흰색으로 점차 사라짐
                ],
                stops: [0.0, 0.6, 1.0], // 색상 전환 지점
              ),
            ),
          ),
          // 실제 내용 (스크롤 가능)
          SafeArea(
            child: SlideTransition( // 페이지 슬라이드 애니메이션
              position: _slideAnimation,
              child: FadeTransition( // 페이지 페이드 애니메이션
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 대시보드 헤더
                      DashboardHeader(
                        avatarScale: _avatarScale,
                        onAvatarTapDown: (_) => setState(() => _avatarScale = 0.9),
                        onAvatarTapUp: (_) {
                          setState(() => _avatarScale = 1.0);
                          _navigateWithFadeTransition(context, const Profile());
                        },
                        onAvatarTapCancel: () => setState(() => _avatarScale = 1.0),
                        onNotificationsPressed: () {
                          _navigateWithFadeTransition(context, const Underconstruction());
                        },
                      ),
                      // 일일 영양 상태 요약 카드
                      DailyStatusSummaryCard(
                        key: ValueKey('dailyCard_$_dailyCardKey'), // 키를 통해 새로고침 유도
                        scale: _dailyCardScale,
                        onTapDown: (_) => setState(() => _dailyCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _dailyCardScale = 1.0);
                          _navigateWithFadeTransition(context, const DailyStatus());
                        },
                        onTapCancel: () => setState(() => _dailyCardScale = 1.0),
                        onTap: () => _navigateWithFadeTransition(context, const DailyStatus()),
                      ),
                      // 주간 점수 요약 카드
                      WeeklyScoreSummaryCard(
                        key: ValueKey('scoreCard_$_scoreCardKey'),
                        scale: _scoreCardScale,
                        onTapDown: (_) => setState(() => _scoreCardScale = 0.98),
                        onTapUp: (_) {
                          setState(() => _scoreCardScale = 1.0);
                          _navigateWithFadeTransition(context, const ScoreboardScreen());
                        },
                        onTapCancel: () => setState(() => _scoreCardScale = 1.0),
                        onTap: () => _navigateWithFadeTransition(context, const ScoreboardScreen()),
                      ),
                      // 식단 일기 요약 카드 (사용자 ID가 있을 때만 표시)
                      if (_userId != null)
                        DashboardMealDiaryCard.MealDiaryCard( // alias 사용
                          key: ValueKey('mealDiaryCard_$_mealDiaryCardKey-${_userId ?? ""}-${_currentDateStringForMealDiary}'),
                          diaryDate: _currentDateStringForMealDiary,
                          userId: _userId!,
                          scale: _mealDiaryCardScale,
                          onTapDown: (_) => setState(() => _mealDiaryCardScale = 0.98),
                          onTapUp: (_) {
                            setState(() => _mealDiaryCardScale = 1.0);
                            _navigateWithFadeTransition(
                              context,
                              MealDiaryScreen(
                                displayDate: _currentDateAsDateTimeForMealDiary, // 오늘 날짜 전달
                              ),
                            );
                          },
                          onTapCancel: () => setState(() => _mealDiaryCardScale = 1.0),
                          onTap: () => _navigateWithFadeTransition(
                            context,
                            MealDiaryScreen(displayDate: _currentDateAsDateTimeForMealDiary),
                          ),
                        )
                      else // 사용자 ID 로딩 중이거나 없을 때 플레이스홀더
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 4,
                            child: const SizedBox(
                              height: 100, // 다른 카드들과 비슷한 높이
                              child: Center(child: Text("식단 일기 로딩 중...")),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20), // 하단 여백
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 공통 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexInBottomNav,
        onTap: _onBottomNavigationTap,
        selectedItemColor: Colors.black87, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey.shade600, // 선택되지 않은 아이템 색상
        showSelectedLabels: false, // 레이블 숨김
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed, // 모든 아이템 고정 표시
        backgroundColor: Colors.white,
        elevation: 8.0,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), // 스코어보드 아이콘
              activeIcon: Icon(Icons.bar_chart),
              label: '스코어보드'), // 레이블은 숨겨지지만 접근성을 위해 제공
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined), // 식사기록(카메라) 아이콘
              activeIcon: Icon(Icons.camera_alt),
              label: '식사기록'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined), // 메뉴추천 아이콘
              activeIcon: Icon(Icons.star),
              label: '메뉴추천'),
        ],
      ),
    );
  }
}
