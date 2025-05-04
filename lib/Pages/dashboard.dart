// Pages/dashboard.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthymeal/Pages/dailystatus.dart';
import 'package:healthymeal/Pages/mealrecord.dart';
import 'package:image_picker/image_picker.dart';
// scoreboard.dart import 추가
import 'package:healthymeal/Pages/scoreboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ignore: unused_field
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  Future<void> _takePicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      },);
    } else {
      print('사진이 선택되지 않았습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          // 페이지 스타일
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 84, 239, 138), Color.fromARGB(255, 239, 186, 86)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // 위젯 목록
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 헤더
                  _buildHeader(),
                  // DailyStatus 위젯
                  _buildDailyStatusCard(),
                  // ScoreBoard 위젯
                  _buildWeeklyScoreCard(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // 현재 선택된 인덱스를 상태로 관리하려면 currentIndex도 state 변수로 관리하는 것이 좋습니다.
          // 여기서는 임시로 1로 설정되어 있습니다. 필요시 수정하세요.
          currentIndex: 1, // 기본 선택 아이템 (카메라)
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            // 첫 번째 아이템: 차트 아이콘 (index 0)
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 40), label: ''),
            // 두 번째 아이템: 카메라 아이콘 (index 1)
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 40), label: ''),
            /*BottomNavigationBarItem(
              icon: IconButton(
                onPressed: _takePicture,
                icon: Icon(Icons.camera_alt, size: 40)),
              label: ''
            ),*/
            // 세 번째 아이템: 별 아이콘 (index 2)
            BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 40), label: ''),
          ],
          onTap: (index) {
            // 탭된 아이템의 인덱스(index)에 따라 다른 동작 수행
            if (index == 0) { // 차트 아이콘 (인덱스 0)을 탭했을 때
              Navigator.push( // Scoreboard 화면으로 이동
                context,
                // Scoreboard 클래스는 MaterialApp을 반환하므로, ScoreboardScreen을 사용해야 합니다.
                // scoreboard.dart 파일 내부 구조에 따라 Scoreboard() 또는 ScoreboardScreen()을 사용하세요.
                // 여기서는 ScoreboardScreen을 가정합니다.
                MaterialPageRoute(builder: (context) => const ScoreboardScreen()), // ScoreboardScreen 호출
              );
            } else if (index == 1) { // 카메라 아이콘 (인덱스 1)을 탭했을 때
              Navigator.push( // FoodRecordScreen으로 이동
                context,
                MaterialPageRoute(builder: (context) => const FoodRecordScreen()),
              );
            }
            // 다른 아이템(index 2 등) 탭 시 추가 로직 구현 가능
          },
        ),
      ),
    );
  }

  // _buildHeader, _buildDailyStatusCard, _buildWeeklyScoreCard 함수는 기존과 동일하게 유지
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed:() {},
                color: Colors.black,
              ),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/icons/default_icon.jpg'), // 실제 이미지 경로로 수정 필요
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push( // DailyStatus 화면으로 이동
            context,
            MaterialPageRoute(builder: (context) => const DailyStatus()),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),
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
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScoreCard() {
    // 이 위젯은 데모용 데이터 표시일 수 있습니다. 실제 기능 구현 시 수정 필요.
    final scores = [
      {"day": "Monday", "value": 0.6},
      {"day": "Tuesday", "value": 0.3},
      {"day": "Wednesday", "value": 0.8},
      {"day": "Thursday", "value": 0.85},
      {"day": "Friday", "value": 0.4},
      {"day": "Saturday", "value": 0.2},
      {"day": "Sunday", "value": 0.5},
    ];

    // Weekly Score 카드를 눌렀을 때 Scoreboard 화면으로 이동하도록 InkWell 추가 (선택 사항)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: InkWell( // InkWell 추가
        onTap: () {
          Navigator.push( // Scoreboard 화면으로 이동
            context,
            MaterialPageRoute(builder: (context) => const ScoreboardScreen()),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Score",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...scores.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
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
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}