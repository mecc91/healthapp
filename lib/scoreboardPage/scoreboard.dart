import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // _picker 사용을 위해 필요
// import 'package:healthymeal/mealrecordPage/mealrecord.dart'; // _takePicture에서 사용 (CommonBottomNavBar로 이동 가능)
// import 'package:healthymeal/recommendationPage/recommendation.dart'; // BottomNavBar에서 사용 (CommonBottomNavBar로 이동 가능)
import '../nutrientintakePage/nutrientintake.dart'; // 상세 보기 버튼에서 사용

// 분리된 위젯 및 서비스 import
import 'widgets/scoreboard_period_toggle.dart';
import 'widgets/average_score_display.dart';
import 'widgets/weekly_score_chart.dart';
import 'widgets/score_comment_display.dart';
import 'services/scoreboard_data_service.dart';
// import 'scoreboard_constants.dart'; // 각 위젯에서 이미 import 하고 있음
import '../../widgets/common_bottom_navigation_bar.dart'; // 공통 BottomNavBar

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final List<bool> _isSelectedToggle = [true, false, false, false]; // 주/월/분기/년 선택 상태

  late ScoreboardDataService _dataService;
  List<Map<String, dynamic>> _currentWeekChartData = [];
  double _currentAverageScore = 0;
  String _currentDateRangeFormatted = "";

  // ImagePicker 인스턴스는 CommonBottomNavigationBar로 전달하거나,
  // _takePicture 로직 전체를 CommonBottomNavigationBar 또는 별도 서비스로 옮길 수 있습니다.
  // 여기서는 CommonBottomNavigationBar에 ImagePicker 인스턴스를 전달하는 방식을 택하겠습니다.
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _dataService = ScoreboardDataService();
    _loadDataForDate(_dataService.currentWeekStartDate);
  }

  void _loadDataForDate(DateTime startDate) {
    setState(() {
      _currentWeekChartData = _dataService.getSimulatedWeekData(startDate);
      _currentAverageScore = _dataService.calculateAverageScore(_currentWeekChartData);
      _currentDateRangeFormatted = _dataService.formatDateRange(startDate);
    });
  }

  // _takePicture 로직은 CommonBottomNavigationBar로 옮겨졌으므로 여기서는 제거합니다.
  // 만약 다른 곳(AppBar 등)에서 카메라 기능이 필요하다면 남겨두거나 별도 서비스로 분리합니다.

  void _handleWeekChangeRequest(int weeksToAdd) {
    final result = _dataService.changeWeek(weeksToAdd);
    final DateTime newDisplayDate = result['newDate'];
    final String? snackBarMessage = result['snackBarMessage'];
    final bool dateActuallyChanged = result['dateChanged'];

    if (mounted && snackBarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage), duration: const Duration(seconds: 1)),
      );
    }

    // 날짜가 실제로 변경되었거나, UI에 표시되는 날짜가 서비스의 현재 날짜와 다르면 데이터 다시 로드
    if (dateActuallyChanged || _currentDateRangeFormatted != _dataService.formatDateRange(newDisplayDate)) {
        _loadDataForDate(newDisplayDate);
    }
  }

  void _onPeriodToggleChanged(int index) {
    // 현재는 'week'만 제대로 지원. 다른 기간 선택 시 UI 업데이트 및 데이터 로드 로직 필요.
    setState(() {
      for (int i = 0; i < _isSelectedToggle.length; i++) {
        _isSelectedToggle[i] = (i == index);
      }
    });

    if (index == 0) { // 'week' 선택됨
      _loadDataForDate(_dataService.currentWeekStartDate); // 현재 서비스의 주간 데이터 다시 로드
    } else {
      // TODO: 월, 분기, 년 단위 데이터 로딩 및 표시 로직 구현
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('월, 분기, 년 단위 표시는 아직 구현되지 않았습니다.')),
        );
      }
      // 임시로 차트 데이터 비우기
      setState(() {
        _currentWeekChartData = [];
        _currentAverageScore = 0;
        String periodName = "";
        if (index == 1) {
          periodName = "월간";
        } else if (index == 2) {
          periodName = "분기별";
        } else if (index == 3) {
          periodName = "연간";
        }
        _currentDateRangeFormatted = "$periodName 데이터 (미구현)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이전/다음 주 이동 가능 여부는 서비스의 날짜 경계를 기준으로 판단
    final bool canGoBack = _dataService.currentWeekStartDate.isAfter(_dataService.oldestWeekStartDate);
    final bool canGoForward = _dataService.currentWeekStartDate.isBefore(_dataService.newestWeekStartDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scoreboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 전체 화면 좌우 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreboardPeriodToggle(
              isSelected: _isSelectedToggle,
              onPressed: _onPeriodToggleChanged,
            ),
            const SizedBox(height: 16),
            AverageScoreDisplay(
              averageScore: _currentAverageScore,
              dateRangeFormatted: _currentDateRangeFormatted,
              onDetailPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NutrientIntakeScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded( // 그래프 영역이 남은 공간을 최대한 활용하도록 Expanded 사용
              flex: 6, // 다른 Flexible 위젯과의 공간 비율 조정
              child: WeeklyScoreChart(
                weekData: _currentWeekChartData,
                onChangeWeek: _handleWeekChangeRequest,
                canGoBack: canGoBack,
                canGoForward: canGoForward,
              ),
            ),
            const SizedBox(height: 10),
            const ScoreCommentDisplay(), // 분리된 코멘트 위젯 사용
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigationBar(
        currentPage: AppPage.scoreboard, // 현재 페이지가 Scoreboard임을 알림
        imagePickerInstance: _picker, // 카메라 기능 사용을 위해 ImagePicker 인스턴스 전달
      ),
    );
  }
}