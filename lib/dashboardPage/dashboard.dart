import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
import 'package:healthymeal/underconstructionPage/underconstruction.dart';
import 'package:intl/intl.dart';

import '../../main.dart'; // RouteObserver 사용

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

  double _avatarScale = 1.0;
  int _selectedIndex = 1;
  double _dailyCardScale = 1.0;
  double _scoreCardScale = 1.0;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _controller.forward(from: 0);
    final now = DateTime.now().microsecondsSinceEpoch;

    setState(() {
      _scoreCardKey = now;
      _dailyCardKey = now + 1;
      _avatarScale = 0.9;
      _dailyCardScale = 0.95;
      _scoreCardScale = 0.95;
    });

    Future.delayed(const Duration(milliseconds: 20), () {
      if (mounted) {
        setState(() {
          _avatarScale = 1.0;
          _dailyCardScale = 1.0;
          _scoreCardScale = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  Future<void> _takePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (mounted) {
        _navigateWithFade(context, MealRecord(initialImageFile: pickedFile));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 촬영이 취소되었거나 실패했습니다.')),
        );
      }
    }
  }

  void _navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      _navigateWithFade(context, const ScoreboardScreen());
    } else if (index == 1) {
      _takePicture();
    } else if (index == 2) {
      _navigateWithFade(context, const MenuRecommendScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = getCurrentDateFormatted();

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
                          _navigateWithFade(context, const Underconstruction());
                        },
                        onAvatarTapCancel: () =>
                            setState(() => _avatarScale = 1.0),
                        onNotificationsPressed: () {
                          _navigateWithFade(context, const Underconstruction());
                        },
                      ),
                      DailyStatusSummaryCard(
                        key: ValueKey(_dailyCardKey),
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
                        key: ValueKey(_scoreCardKey),
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
                      MealDiaryCard(diaryDate: currentDate),
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
