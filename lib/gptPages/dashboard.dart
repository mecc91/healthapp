import 'package:flutter/material.dart';
import 'package:healthymeal/gptPages/mealrecord.dart'; // mealrecord.dart 파일을 import 합니다.

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB1F2C8), Color(0xFFD7B26F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildDailyStatusCard(),
                _buildWeeklyScoreCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 현재 선택된 인덱스 (대시보드는 0)
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''), // 카메라 아이콘 (인덱스 1)
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: ''),
        ],
        // onTap 콜백 추가
        onTap: (index) {
          if (index == 1) { // 카메라 아이콘 (인덱스 1)을 탭했을 때
            Navigator.push( // MealRecordScreen으로 이동
              context,
              MaterialPageRoute(builder: (context) => const FoodRecordScreen()),
            );
          }
          // 다른 아이템 탭 시 추가 로직 구현 가능
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                // TODO: 실제 프로필 이미지 경로로 변경하세요.
                // backgroundImage: AssetImage('assets/profile.jpg'),
                backgroundColor: Colors.grey, // 임시 배경색
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStatusCard() {
    final nutrients = [
      {"label": "탄수화물", "value": 0.95, "color": Colors.orange},
      {"label": "단백질", "value": 0.75, "color": Colors.yellow},
      {"label": "지방", "value": 0.65, "color": Colors.green},
      {"label": "나트륨", "value": 0.9, "color": Colors.red},
      {"label": "식이섬유", "value": 0.6, "color": Colors.purple},
      {"label": "당류", "value": 0.5, "color": Colors.lightBlue},
      {"label": "콜레스테롤", "value": 0.85, "color": Colors.deepOrange},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daily Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...nutrients.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["label"]! as String),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: item["value"]! as double,
                          backgroundColor: Colors.grey[300],
                          color: item["color"] as Color,
                          minHeight: 6, // 프로그레스 바 높이 조절
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScoreCard() {
    final scores = [
      {"day": "Monday", "value": 0.6},
      {"day": "Tuesday", "value": 0.3},
      {"day": "Wednesday", "value": 0.8},
      {"day": "Thursday", "value": 0.85},
      // TODO: 실제 데이터로 채우세요.
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), // 하단 패딩 추가
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Score",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (scores.isEmpty) // 데이터가 없을 경우 메시지 표시
                const Center(child: Text('이번 주 점수 데이터가 없습니다.'))
              else
               ...scores.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            item["day"]! as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: item["value"]! as double,
                            backgroundColor: Colors.grey[300],
                            color: Colors.tealAccent,
                             minHeight: 6, // 프로그레스 바 높이 조절
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}