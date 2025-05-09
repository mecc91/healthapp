// Fixed Dashboard.dart with working screen transitions and bottomNavigationBar

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _avatarScale = 1.0;
  int _selectedIndex = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('사진이 선택되지 않았습니다');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainDashboard(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            _navigateWithFade(context, const Scoreboard());
          } else if (index == 1) {
            _navigateWithFade(context, const MealRecord());
          } else if (index == 2) {
            _navigateWithFade(context, const DailyStatus());
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: ''),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    final nutrients = [
      {"label": "탄수화물", "value": 0.95, "color": Colors.orange},
      {"label": "단백질", "value": 0.75, "color": Colors.yellow},
      {"label": "지방", "value": 0.65, "color": Colors.green},
      {"label": "나트륨", "value": 0.9, "color": Colors.red},
      {"label": "식이섬유", "value": 0.6, "color": Colors.purple},
      {"label": "당류", "value": 0.5, "color": Colors.lightBlue},
      {"label": "콜레스테롤", "value": 0.85, "color": Colors.deepOrange},
    ];

    final scores = [
      {"day": "Monday", "value": 0.6},
      {"day": "Tuesday", "value": 0.3},
      {"day": "Wednesday", "value": 0.8},
      {"day": "Thursday", "value": 0.85},
      {"day": "Friday", "value": 0.4},
      {"day": "Saturday", "value": 0.2},
      {"day": "Sunday", "value": 0.5},
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 84, 239, 138),
            Color.fromARGB(255, 239, 186, 86),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dashboard',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {},
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTapDown: (_) => setState(() => _avatarScale = 0.8),
                          onTapUp: (_) {
                            setState(() => _avatarScale = 1.0);
                            _navigateWithFade(context, const Scoreboard());
                          },
                          onTapCancel: () => setState(() => _avatarScale = 1.0),
                          child: AnimatedScale(
                            scale: _avatarScale,
                            duration: const Duration(milliseconds: 100),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  AssetImage('assets/image/default_man.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: InkWell(
                  onTap: () => _navigateWithFade(context, const DailyStatus()),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Daily Status",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ...nutrients.map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["label"]! as String),
                                    const SizedBox(height: 4),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                          begin: 0.0,
                                          end: item["value"]! as double),
                                      duration:
                                          const Duration(milliseconds: 800),
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: Colors.grey[300],
                                          color: item["color"] as Color,
                                          minHeight: 10,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: InkWell(
                  onTap: () => _navigateWithFade(context, const Scoreboard()),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Weekly Score",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ...scores.map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        item["day"]! as String,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(
                                            begin: 0.0,
                                            end: item["value"]! as double),
                                        duration:
                                            const Duration(milliseconds: 800),
                                        builder: (context, value, child) {
                                          return LinearProgressIndicator(
                                            value: value,
                                            backgroundColor: Colors.grey[300],
                                            color: const Color.fromARGB(
                                                255, 0, 77, 59),
                                            minHeight: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          );
                                        },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
