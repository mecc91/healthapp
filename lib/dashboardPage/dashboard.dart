// lib/dashboardPage/dashboard.dart
import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
import 'package:healthymeal/underconstructionPage/underconstruction.dart';

// 분리된 위젯 import
import 'widgets/dashboard_header.dart';
import 'widgets/daily_status_summary_card.dart';
import 'widgets/weekly_score_summary_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ImagePicker _picker = ImagePicker();

  double _avatarScale = 1.0;
  int _selectedIndex = 1; // 초기 선택 인덱스를 카메라(1)로 설정
  double _dailyCardScale = 1.0;
  double _scoreCardScale = 1.0;

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

  void _onBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              child: Column(
                children: [
                  DashboardHeader(
                    avatarScale: _avatarScale,
                    onAvatarTapDown: (_) => setState(() => _avatarScale = 0.85),
                    onAvatarTapUp: (_) {
                      setState(() => _avatarScale = 1.0);
                      _navigateWithFade(context, const Underconstruction());
                    },
                    onAvatarTapCancel: () =>
                        setState(() => _avatarScale = 1.0),
                    onNotificationsPressed: () {
                      _navigateWithFade(context, const Underconstruction());
                      // 알림 버튼 기능 (추후 구현)
                    },
                  ),
                  DailyStatusSummaryCard(
                    scale: _dailyCardScale,
                    onTapDown: (_) => setState(() => _dailyCardScale = 0.98),
                    onTapUp: (_) {
                      setState(() => _dailyCardScale = 1.0);
                      _navigateWithFade(context, const DailyStatus());
                    },
                    onTapCancel: () => setState(() => _dailyCardScale = 1.0),
                  ),
                  WeeklyScoreSummaryCard(
                    scale: _scoreCardScale,
                    onTapDown: (_) => setState(() => _scoreCardScale = 0.98),
                    onTapUp: (_) {
                      setState(() => _scoreCardScale = 1.0);
                      _navigateWithFade(context, const ScoreboardScreen());
                    },
                    onTapCancel: () => setState(() => _scoreCardScale = 1.0),
                  ),
                ],
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