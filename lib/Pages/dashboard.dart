import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthymeal/Pages/mealrecord.dart';
import 'package:image_picker/image_picker.dart';

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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 84, 239, 138), Color.fromARGB(255, 239, 186, 86)],
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
          currentIndex: 1,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 40), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 40), label: ''),
            /*BottomNavigationBarItem(
              icon: IconButton(
                onPressed: _takePicture, 
                icon: Icon(Icons.camera_alt, size: 40)),
              label: ''
            ),*/
            BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 40), label: ''),
          ],
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
      ),
    );
  }

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
                backgroundImage: AssetImage('assets/profile.jpg'),
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
    );
  }

  Widget _buildWeeklyScoreCard() {
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
    );
  }
}
