import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart'; // 주석 해제 및 MenuRecommendScreen import
import 'package:healthymeal/scoreboardPage/scoreboard.dart';
// import 'package:healthymeal/dashboardPage/dashboard.dart'; // 필요시 활성화
import 'package:healthymeal/underconstructionPage/underconstruction.dart'; // Underconstruction도 유지 (다른 곳에서 사용될 수 있음)
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
      case AppPage.cameraTrigger: // 카메라 탭은 특정 페이지가 아님 (선택된 상태로 표시되지 않도록 조정 가능)
        // 카메라 탭 자체가 선택된 상태로 유지될 필요가 없다면,
        // currentIndex를 다른 값으로 유지하거나, 카메라 액션 후 이전 페이지 인덱스로 돌아가는 로직 추가 가능
        // 여기서는 일단 currentPage가 cameraTrigger일 경우 특정 인덱스를 갖도록 하지 않음.
        // 일반적으로 카메라 버튼은 '액션'을 트리거하고 특정 '페이지'로 머무르지 않으므로,
        // currentPage에 cameraTrigger를 전달하는 대신, 실제 표시될 페이지의 enum 값을 전달하는 것이 좋습니다.
        // 예를 들어, 카메라 사용 후 MealRecord 페이지로 갔다면, MealRecord 페이지가 currentPage가 될 수 있습니다.
        // 이 예제에서는 recommendation 페이지에서 호출되므로, recommendation이 활성화됩니다.
        if (currentPage == AppPage.recommendation) {
          currentIndex = 2;
        } else if (currentPage == AppPage.scoreboard) {
          currentIndex = 0;
        }
        // dashboard 등 다른 페이지에서의 카메라 사용도 고려 필요
        break;
      case AppPage.recommendation:
        currentIndex = 2;
        break;
      case AppPage.dashboard:
        // Dashboard의 BottomNavBar 인덱스에 따라 설정
        // 예: Dashboard가 네 번째 탭이라면 currentIndex = 3 (0-indexed)
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
        // 단, recommendation 탭은 현재 페이지여도 다시 누르면 MenuRecommendScreen으로 이동 (새로고침 효과 또는 상태 초기화 필요시)
        if (index == currentIndex && index != 1 && index != 2) { // recommendation (index 2) 제외
            // Scoreboard 화면에서 Scoreboard 탭을 누른 경우, Dashboard로 돌아가는 로직 등
            // 특별한 동작이 필요하면 여기에 추가.
            // 예시: Dashboard (MealDiaryScreen)로 이동
            if (index == 0 && currentPage == AppPage.scoreboard) { // Scoreboard 탭을 Scoreboard 화면에서 누른 경우
                 Navigator.pushAndRemoveUntil( // 예시: Dashboard로 이동하고 이전 기록 지우기
                    context,
                    MaterialPageRoute(builder: (context) => MealDiaryScreen(displayDate: DateTime.now())), // 현재 날짜로 Diary 보기
                    (Route<dynamic> route) => false,
                );
                return;
            }
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
            } else {
              // 이미 Scoreboard 페이지일 때 Scoreboard 탭을 누르면 Dashboard로 이동 (예시 동작)
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MealDiaryScreen(displayDate: DateTime.now())),
                  (Route<dynamic> route) => false,
              );
            }
            break;
          case 1: // Camera Action
            _triggerCameraAction(context);
            break;
          case 2: // Recommendation
            if (currentPage != AppPage.recommendation) {
                // Recommendation 페이지 (MenuRecommendScreen)로 이동
                // 기존 스택을 지우고 푸시하거나, 단순 푸시할지 결정
                Navigator.pushAndRemoveUntil( // 다른 페이지에서 추천 탭을 누르면 MenuRecommendScreen으로 이동하고 이전 기록 지우기
                    context,
                    MaterialPageRoute(builder: (context) => const MenuRecommendScreen()),
                     (Route<dynamic> route) => false, // 모든 이전 라우트 제거
                );
            } else {
              // 이미 Recommendation 페이지일 때 다시 탭하면 아무것도 안 하거나, 새로고침 로직 추가 가능
              // 여기서는 아무 작업 안 함 (또는 최상단으로 스크롤 등)
            }
            break;
        }
      },
    );
  }
}
