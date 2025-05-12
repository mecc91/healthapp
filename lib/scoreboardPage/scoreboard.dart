import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가
import 'dart:math'; // 랜덤 데이터 생성을 위해 추가
// import 'dart:io'; // Required for _takePicture -> MealRecord if needed // 필요시 활성화
import 'package:image_picker/image_picker.dart'; // Required for _takePicture
import 'package:healthymeal/mealrecordPage/mealrecord.dart'; // For MealRecord page
import 'package:healthymeal/recommendationPage/recommendation.dart'; // For Recommendation page
import '../nutrientintakePage/nutrientintake.dart'; // 상세 화면 import 추가

// 기본 테마 색상 정의
const Color primaryColor = Colors.teal;
const Color accentColor = Colors.redAccent;

// --- 데이터 시뮬레이션 설정 ---
const int weeksOfDataBeforeToday = 4;
const int weeksOfDataAfterToday = 0;

class Scoreboard extends StatefulWidget {
  const Scoreboard({super.key});

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  List<bool> _isSelectedToggle = [true, false, false, false];

  late DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  List<Map<String, dynamic>> currentWeekData = [];
  double currentAverageScore = 0;

  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealRecord(initialImageFile: pickedFile),
          ),
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

  @override
  void initState() {
    super.initState();
    _initializeDatesAndData();
  }

  void _initializeDatesAndData() {
    final now = DateTime.now();
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: weeksOfDataAfterToday * 7));
    _loadWeekData(currentWeekStartDate);
  }

  void _loadWeekData(DateTime startDate) {
    setState(() {
      currentWeekStartDate = startDate;
      currentWeekData = _getSimulatedWeekData(startDate);
      currentAverageScore = _calculateAverageScore(currentWeekData);
    });
  }

  List<Map<String, dynamic>> _getSimulatedWeekData(DateTime startDate) {
    final random = Random(startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay);
    List<Map<String, dynamic>> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add({
        'day': dayNames[i],
        'value': random.nextInt(71) + 30, // 30 ~ 100 사이의 점수
      });
    }
    return weekData;
  }

  double _calculateAverageScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final totalScore = data.map((d) => d['value'] as int).reduce((a, b) => a + b);
    return totalScore / data.length;
  }

  String _formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    String formatWithSuffix(DateTime date) {
      String day = DateFormat('d').format(date);
      String suffix = 'th';
      if (day.endsWith('1') && !day.endsWith('11')) suffix = 'st';
      else if (day.endsWith('2') && !day.endsWith('12')) suffix = 'nd';
      else if (day.endsWith('3') && !day.endsWith('13')) suffix = 'rd';
      return "${DateFormat('MMMM').format(date)} ${day}${suffix}";
    }
    return "${formatWithSuffix(startDate)} ~ ${formatWithSuffix(endDate)}";
  }

  void _changeWeek(int weeksToAdd) {
    final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));

    if (targetStartDate.isBefore(oldestWeekStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('더 이상 이전 데이터가 없습니다.'),
            duration: Duration(seconds: 1)),
      );
      return;
    }
    if (targetStartDate.isAfter(newestWeekStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('더 이상 다음 데이터가 없습니다.'),
            duration: Duration(seconds: 1)),
      );
      return;
    }
    _loadWeekData(targetStartDate);
  }

  double calculateBarHeight(int value, double heightFor100PointBar, int referenceMaxValue) {
    if (value <= 0 || referenceMaxValue <= 0 || heightFor100PointBar <= 0) return 0;
    double calculatedHeight = (value / referenceMaxValue.toDouble()) * heightFor100PointBar;
    return max(0, calculatedHeight);
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = currentWeekStartDate.isAfter(oldestWeekStartDate);
    final bool canGoForward = currentWeekStartDate.isBefore(newestWeekStartDate);

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
            Center(
              child: ToggleButtons(
                isSelected: _isSelectedToggle,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelectedToggle.length; i++) {
                      _isSelectedToggle[i] = false;
                    }
                    _isSelectedToggle[index] = true;
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                selectedColor: Colors.white,
                color: Colors.black54,
                fillColor: primaryColor,
                borderColor: Colors.grey.shade300,
                selectedBorderColor: primaryColor,
                constraints:
                    const BoxConstraints(minHeight: 35.0, minWidth: 60.0),
                children: const [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("week")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("month")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("quater")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("year")),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding( // "avr" 점수 섹션 패딩
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("avr", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich( // Widget 1 in Column
                            TextSpan(
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                              children: [
                                TextSpan(text: currentAverageScore.toStringAsFixed(0)),
                                const TextSpan(
                                  text: ' point',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ), // Text.rich 끝
                          const SizedBox(height: 4), // Text.rich의 형제 위젯
                          Text( // Text.rich의 형제 위젯
                              _formatDateRange(currentWeekStartDate),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NutrientIntake()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor, side: const BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: const Text("detail"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 6, // 그래프 영역 flex 값
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 100) {
                    if (canGoBack) _changeWeek(-1);
                  } else if (details.primaryVelocity! < -100) {
                    if (canGoForward) _changeWeek(1);
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeightForGraphContainer = constraints.maxHeight;
                    final double availableWidthForGraphContainer = constraints.maxWidth;

                    const double valueTextFontSize = 9.0;
                    const double dayTextFontSize = 9.0;
                    const double textLineHeightApproximation = valueTextFontSize * 1.7;
                    const double topSizedBoxHeight = 1.0;
                    const double bottomSizedBoxHeight = 1.0;
                    const double graphContainerVerticalPadding = 8.0 * 2;
                    const double iconButtonEffectiveWidth = 36.0;
                    const double horizontalPaddingForBarArea = 5.0 * 2;

                    final double heightFor100PointBarVisual = availableHeightForGraphContainer -
                        (textLineHeightApproximation * 2) -
                        topSizedBoxHeight -
                        bottomSizedBoxHeight -
                        graphContainerVerticalPadding;
                    
                    final double barDisplayAreaWidth = availableWidthForGraphContainer -
                                                  (iconButtonEffectiveWidth * 2) -
                                                  horizontalPaddingForBarArea;

                    final double barWidth = barDisplayAreaWidth / (currentWeekData.length * 1.8);

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            iconSize: 36.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: canGoBack ? () => _changeWeek(-1) : null,
                            color: canGoBack ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: currentWeekData.map((dayData) {
                                  final barHeightValue = calculateBarHeight(
                                      dayData['value'],
                                      heightFor100PointBarVisual > 0 ? heightFor100PointBarVisual : 0,
                                      100
                                  );
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${dayData['value']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: valueTextFontSize)
                                      ),
                                      const SizedBox(height: topSizedBoxHeight),
                                      Container(
                                        height: barHeightValue,
                                        width: barWidth > 0 ? barWidth : 0,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: bottomSizedBoxHeight),
                                      Text(
                                        dayData['day'],
                                        style: const TextStyle(fontSize: dayTextFontSize, fontWeight: FontWeight.bold)
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            iconSize: 36.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: canGoForward ? () => _changeWeek(1) : null,
                            color: canGoForward ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              flex: 1, // 코멘트 영역 flex 값
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: ListView( 
                  shrinkWrap: true,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
                        children: const [
                          TextSpan(text: "이번 주는 전반적으로 양호한 점수를 기록했습니다. 특히 "),
                          TextSpan(text: "단백질과 식이섬유 ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          TextSpan(text: "섭취가 잘 이루어졌습니다. "),
                        ],
                      ),
                       textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
                        children: const [
                          TextSpan(text: "다만, "),
                          TextSpan(text: "탄수화물과 나트륨 ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          TextSpan(text: "섭취량에 조금 더 주의가 필요해 보입니다. 다음 주에는 균형 잡힌 식단을 유지해 보세요!"),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 40), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 40), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 40), label: ''),
        ],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // 현재 화면
          } else if (index == 1) {
            _takePicture();
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Recommendation()),
            );
          }
        },
      ),
    );
  }
}
