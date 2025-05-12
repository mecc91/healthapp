// lib/dashboardPage/dashboard.dart
// Jiwoo님의 UI/UX 및 애니메이션 요소를 Gyuhyeong님의 코드에 통합

import 'dart:io'; // XFile을 File로 변환하거나 할 때 필요할 수 있으나, 현재 코드에서는 직접 사용되지 않음.
                 // Jiwoo 코드에서는 _imageFile 상태 변수(File 타입)가 있었으나,
                 // Gyuhyeong의 XFile 전달 방식을 유지하므로 직접적인 File 상태 관리는 제거.

import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
// RecommendationPage는 BottomNavigationBar에서 현재 사용되지 않으므로 주석 처리 유지
// import 'package:healthymeal/recommendationPage/recommendation.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ImagePicker _picker = ImagePicker();

  // Jiwoo 코드에서 가져온 상태 변수들
  double _avatarScale = 1.0;
  int _selectedIndex = 1; // 초기 선택 인덱스를 카메라(1)로 설정 (Gyuhyeong 코드 스타일 유지)
  double _dailyScale = 1.0;
  double _scoreScale = 1.0;

  // Gyuhyeong 코드의 핵심 기능: 카메라로 사진 촬영 후 MealRecord 페이지로 XFile 전달
  Future<void> _takePicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (mounted) {
        // Jiwoo 코드의 _navigateWithFade를 사용하여 페이지 이동
        _navigateWithFade(
          context,
          MealRecord(initialImageFile: pickedFile), // XFile 전달
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

  // Jiwoo 코드에서 가져온 페이지 전환 함수
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
        transitionDuration: const Duration(milliseconds: 300), // 300ms 페이드 효과
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp은 main.dart에서 관리하므로 여기서는 Scaffold로 시작
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Jiwoo 스타일 배경색
      body: Stack( // Jiwoo 스타일 그라데이션 배경을 위한 Stack 구조
        children: [
          Container( // 그라데이션 배경
            height: 250, // 그라데이션 영역 높이
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE68A), // 밝은 Amber
                  Color(0xFFC8E6C9), // 연한 Green
                  Colors.white,      // 하단은 흰색으로 자연스럽게 연결
                ],
                stops: [0.0, 0.7, 1.0], // 그라데이션 중단점
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(), // 헤더 위젯
                  _buildDailyStatusCard(), // Daily Status 카드 위젯
                  _buildWeeklyScoreCard(), // Weekly Score 카드 위젯
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 선택된 탭 인덱스
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // 탭 선택 시 인덱스 변경
          });
          if (index == 0) { // 스코어보드 탭
            _navigateWithFade(context, const Scoreboard());
          } else if (index == 1) { // 카메라 탭
            _takePicture(); // 사진 촬영 함수 호출
          } else if (index == 2) { // 별 아이콘 탭 (DailyStatus 또는 Recommendation)
                                     // Jiwoo 코드는 DailyStatus, Gyuhyeong 코드는 Recommendation (주석처리)
                                     // 여기서는 DailyStatus로 연결 (Jiwoo 스타일)
            _navigateWithFade(context, const DailyStatus());
            // 만약 Recommendation 페이지로 연결하고 싶다면 아래 코드로 변경
            // _navigateWithFade(context, const Recommendation());
          }
        },
        selectedItemColor: Colors.black, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 미선택 아이템 색상
        showSelectedLabels: false, // 선택된 라벨 숨김
        showUnselectedLabels: false, // 미선택 라벨 숨김
        type: BottomNavigationBarType.fixed, // 고정된 타입
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 35), label: ''), // 아이콘 크기 조정
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 35), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 35), label: ''),
        ],
      ),
    );
  }

  // 헤더 위젯 빌드 함수 (Jiwoo 스타일 적용)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20), // 패딩 조정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87), // 텍스트 색상 명시
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28), // 아이콘 크기 조정
                onPressed: () {
                  // 알림 버튼 기능 (추후 구현)
                },
                color: Colors.black54, // 아이콘 색상 변경
              ),
              const SizedBox(width: 8), // 간격 조정
              GestureDetector( // Jiwoo 스타일 탭 애니메이션 적용
                onTapDown: (_) => setState(() => _avatarScale = 0.85), // 탭 시작 시 축소
                onTapUp: (_) {
                  setState(() => _avatarScale = 1.0); // 탭 종료 시 복원
                  _navigateWithFade(context, const Scoreboard()); // Scoreboard로 이동 (Jiwoo 스타일)
                },
                onTapCancel: () => setState(() => _avatarScale = 1.0), // 탭 취소 시 복원
                child: AnimatedScale(
                  scale: _avatarScale,
                  duration: const Duration(milliseconds: 150), // 애니메이션 속도
                  child: CircleAvatar(
                    radius: 20, // 크기 조정
                    backgroundImage: const AssetImage('assets/profile.jpg'), // Gyuhyeong의 이미지 경로 유지
                                                                         // Jiwoo의 'assets/image/default_man.png' 사용 시 경로 수정 필요
                    backgroundColor: Colors.grey.shade300, // 이미지 없을 경우 배경색
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Daily Status 카드 위젯 빌드 함수 (Jiwoo 스타일 적용)
  Widget _buildDailyStatusCard() {
    // Gyuhyeong 코드의 데이터 구조 사용
    final nutrients = [
      {"label": "탄수화물", "value": 0.95, "color": Colors.orange},
      {"label": "단백질", "value": 0.75, "color": Colors.yellow}, // Jiwoo는 동적 색상, Gyuhyeong은 고정 -> Jiwoo 동적 색상 로직 적용
      {"label": "지방", "value": 0.65, "color": Colors.green},
      {"label": "나트륨", "value": 0.9, "color": Colors.red},
      {"label": "식이섬유", "value": 0.6, "color": Colors.purple},
      {"label": "당류", "value": 0.5, "color": Colors.lightBlue},
      {"label": "콜레스테롤", "value": 0.85, "color": Colors.deepOrange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector( // Jiwoo 스타일 탭 애니메이션
        onTapDown: (_) => setState(() => _dailyScale = 0.98), // 미세 조정된 스케일
        onTapUp: (_) {
          setState(() => _dailyScale = 1.0);
          _navigateWithFade(context, const DailyStatus()); // DailyStatus 페이지로 이동
        },
        onTapCancel: () => setState(() => _dailyScale = 1.0),
        child: AnimatedScale(
          scale: _dailyScale,
          duration: const Duration(milliseconds: 150),
          child: Card( // Jiwoo 스타일 카드
            color: const Color(0xFFFCFCFC), // 카드 배경색
            elevation: 5, // 그림자 깊이
            shadowColor: Colors.grey.withOpacity(0.3), // 그림자 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18), // 모서리 둥글게
              side: BorderSide(color: Colors.grey.shade200, width: 1.0), // 테두리
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Status",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ...nutrients.map((item) {
                    final double value = item["value"]! as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7), // 간격 조정
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["label"]! as String, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 5),
                          TweenAnimationBuilder<double>( // Jiwoo 스타일 프로그레스 바 애니메이션
                            tween: Tween(begin: 0.0, end: value),
                            duration: Duration(milliseconds: 700 + (value * 300).toInt()), // 값에 따라 다른 속도
                            builder: (context, animatedValue, child) {
                              return LinearProgressIndicator(
                                value: animatedValue,
                                backgroundColor: Colors.grey.shade300,
                                color: () { // Jiwoo 스타일 동적 색상 로직
                                  if (animatedValue <= 0.25) return Colors.red.shade400;
                                  if (animatedValue <= 0.40) return Colors.orange.shade400;
                                  if (animatedValue <= 0.60) return Colors.amber.shade500;
                                  if (animatedValue <= 0.85) return Colors.lightGreen.shade500;
                                  return Colors.green.shade500;
                                }(),
                                minHeight: 10, // 높이
                                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Weekly Score 카드 위젯 빌드 함수 (Jiwoo 스타일 적용)
  Widget _buildWeeklyScoreCard() {
    // Gyuhyeong 코드의 데이터 구조 사용
    final scores = [
      {"day": "Monday", "value": 0.6},
      {"day": "Tuesday", "value": 0.3},
      {"day": "Wednesday", "value": 0.8},
      {"day": "Thursday", "value": 0.85},
      {"day": "Friday", "value": 0.4},
      {"day": "Saturday", "value": 0.2},
      {"day": "Sunday", "value": 0.5},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector( // Jiwoo 스타일 탭 애니메이션
        onTapDown: (_) => setState(() => _scoreScale = 0.98),
        onTapUp: (_) {
          setState(() => _scoreScale = 1.0);
          _navigateWithFade(context, const Scoreboard()); // Scoreboard 페이지로 이동
        },
        onTapCancel: () => setState(() => _scoreScale = 1.0),
        child: AnimatedScale(
          scale: _scoreScale,
          duration: const Duration(milliseconds: 150),
          child: Card( // Jiwoo 스타일 카드
            color: const Color(0xFFFCFCFC),
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Score",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ...scores.map((item) {
                    final double value = item["value"]! as double;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80, // 너비 조정
                            child: Text(
                              item["day"]! as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54), // 스타일 변경
                            ),
                          ),
                          const SizedBox(width: 10), // 간격 추가
                          Expanded(
                            child: TweenAnimationBuilder<double>( // Jiwoo 스타일 프로그레스 바 애니메이션
                              tween: Tween(begin: 0.0, end: value),
                              duration: Duration(milliseconds: 700 + (value * 300).toInt()),
                              builder: (context, animatedValue, child) {
                                return LinearProgressIndicator(
                                  value: animatedValue,
                                  backgroundColor: Colors.grey[300],
                                  color: () { // Jiwoo 스타일 동적 색상 로직
                                    if (animatedValue <= 0.25) return Colors.red.shade400;
                                    if (animatedValue <= 0.40) return Colors.orange.shade400;
                                    if (animatedValue <= 0.60) return Colors.amber.shade500;
                                    if (animatedValue <= 0.85) return Colors.lightGreen.shade500;
                                    return Colors.green.shade500;
                                  }(),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(10),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
