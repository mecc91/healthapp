import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
import 'package:healthymeal/dashboardPage/dashboard.dart'; // ✅ Dashboard import

enum AppPage {
  scoreboard,
  dashboard,
  recommendation,
}

class CommonBottomNavigationBar extends StatelessWidget {
  final AppPage currentPage;
  final ImagePicker? imagePickerInstance;

  const CommonBottomNavigationBar({
    super.key,
    required this.currentPage,
    this.imagePickerInstance,
  });

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    switch (currentPage) {
      case AppPage.scoreboard:
        currentIndex = 0;
        break;
      case AppPage.dashboard:
        currentIndex = 1;
        break;
      case AppPage.recommendation:
        currentIndex = 2;
        break;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 40), label: 'Scoreboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 40), label: 'Dashboard'), // ✅ 변경
        BottomNavigationBarItem(
            icon: Icon(Icons.star_border, size: 40), label: 'Recommendation'),
      ],
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0: // Scoreboard
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ScoreboardScreen()),
              (route) => false,
            );
            break;
          case 1: // ✅ Dashboard로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
              (route) => false,
            );
            break;
          case 2: // Recommendation
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const MenuRecommendScreen()),
              (route) => false,
            );
            break;
        }
      },
    );
  }
}
