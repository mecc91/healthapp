import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
// import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
// import 'package:healthymeal/dashboardPage/dashboard.dart'; // 필요시 활성화
import 'package:healthymeal/underconstructionPage/underconstruction.dart';
import 'package:healthymeal/mealdiaryPage/meal_diary_screen.dart';

// 현재 페이지를 나타내는 enum (탭 인덱스 관리용)
enum AppPage { scoreboard, cameraTrigger, recommendation, dashboard } // 'cameraTrigger'는 탭을 의미

class CommonBottomNavigationBar extends StatelessWidget {
  final AppPage currentPage;
  // 카메라 기능을 위해 ImagePicker 인스턴스를 받을 수 있도록 함 (선택적)
  // 또는 ImagePicker 로직을 이 위젯 내부나 별도 서비스로 관리 가능
  final ImagePicker? imagePickerInstance;

  const CommonBottomNavigationBar({
    super.key,
    required this.currentPage,
    this.imagePickerInstance,
  });

  Future<void> _triggerCameraAction(BuildContext context) async {
    final picker = imagePickerInstance ?? ImagePicker(); // 없으면 새로 생성
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealRecord(initialImageFile: pickedFile),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 촬영이 취소되었거나 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    switch (currentPage) {
      case AppPage.scoreboard:
        currentIndex = 0;
        break;
      case AppPage.cameraTrigger: // 카메라 탭은 특정 페이지가 아님
        currentIndex = 1;
        break;
      case AppPage.recommendation:
        currentIndex = 2;
        break;
      case AppPage.dashboard:
        // Dashboard의 BottomNavBar 인덱스에 따라 설정 (예: Dashboard가 첫번째 탭이면 0)
        // 이 예제에서는 Scoreboard, Camera, Recommendation만 다룸
        break;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.black, // 테마 색상 사용 권장
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 40), label: 'Scoreboard'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 40), label: 'Camera'),
        BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 40), label: 'Recommendation'),
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        // 현재 페이지와 같은 탭을 눌렀을 때 (카메라 제외) 아무 작업 안 함
        if (index == currentIndex && index != 1) {
            // Scoreboard 화면에서 Scoreboard 탭을 누른 경우, Dashboard로 돌아가는 로직 등
            // 특별한 동작이 필요하면 여기에 추가. 현재는 아무것도 안함.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDiaryScreen(
                  // Pass the specific date you want to show, e.g., 2025-04-02
                  displayDate: DateTime(2025, 4, 2),
                ),
              ),
            );
            return;
          }

        switch (index) {
          case 0: // Scoreboard
            if (currentPage != AppPage.scoreboard) {
                 // ScoreboardScreen으로 이동 (기존 스택을 모두 지우고 푸시)
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ScoreboardScreen()),
                    (Route<dynamic> route) => false,
                );
            }
            break;
          case 1: // Camera Action
            _triggerCameraAction(context);
            break;
          case 2: // Recommendation
            if (currentPage != AppPage.recommendation) {
                // Recommendation 페이지로 이동
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Underconstruction()),
                );
            }
            break;
        }
      },
    );
  }
}