import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
// import 'dart:io'; // Required for _takePicture -> MealRecord if needed // 필요시 주석 해제
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/mealrecordPage/mealrecord.dart';
import 'package:healthymeal/recommendationPage/recommendation.dart';
import 'package:healthymeal/scoreboardPage/scoreboard.dart';

const Color primaryColor = Colors.teal;
const Color graphAccentColor = Colors.redAccent;
final Color graphBackgroundColor = Colors.grey.shade200;

const int weeksOfDataBeforeToday = 4;
const int weeksOfDataAfterToday = 0;

final List<String> nutrientKeys = ['Carbohydrate', 'Protein', 'Fat', 'Fiber'];

List<Map<String, dynamic>> _generateSimulatedNutrientData(String nutrient, DateTime startDate) {
  final seed = nutrient.hashCode ^ startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  final random = Random(seed);
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
  List<Map<String, dynamic>> weekData = [];
  for (int i = 0; i < 7; i++) {
    weekData.add({
      'day': dayNames[i],
      'value': random.nextInt(71) + 30, // 30 ~ 100
    });
  }
  return weekData;
}

class NutrientIntake extends StatefulWidget {
  const NutrientIntake({super.key});

  @override
  State<NutrientIntake> createState() => _NutrientIntakeState();
}

class _NutrientIntakeState extends State<NutrientIntake> {
  List<bool> _isSelectedPeriod = [true, false, false, false];
  int _selectedNutrientIndex = 0;
  late DateTime currentWeekStartDate;
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  List<Map<String, dynamic>> currentNutrientWeekData = [];

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
    _initializeDates();
    _loadNutrientData();
  }

  void _initializeDates() {
    final now = DateTime.now();
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: weeksOfDataAfterToday * 7));
  }

  void _loadNutrientData() {
    setState(() {
      String selectedNutrient = nutrientKeys[_selectedNutrientIndex];
      currentNutrientWeekData = _generateSimulatedNutrientData(selectedNutrient, currentWeekStartDate);
    });
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
      if (!_isSelectedPeriod[0]) return;
      final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));

      if (targetStartDate.isBefore(oldestWeekStartDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('더 이상 이전 데이터가 없습니다.'), duration: Duration(seconds: 1)),
        );
        return;
      }
      if (targetStartDate.isAfter(newestWeekStartDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('더 이상 다음 데이터가 없습니다.'), duration: Duration(seconds: 1)),
        );
        return;
      }
       setState(() {
            currentWeekStartDate = targetStartDate;
       });
       _loadNutrientData();
  }

  void _changeNutrient(int indexOffset) {
      setState(() {
          _selectedNutrientIndex = (_selectedNutrientIndex + indexOffset + nutrientKeys.length) % nutrientKeys.length;
      });
      _loadNutrientData();
  }

  // 막대 높이 계산 함수: (현재 값 / 주간 최대값) * 표시 가능한 최대 막대 높이
  double calculateBarHeight(int value, double maxVisualBarHeight, int maxValueInWeek) {
    if (value <= 0 || maxValueInWeek <= 0 || maxVisualBarHeight <= 0) {
      return 0;
    }
    double calculatedHeight = (value / maxValueInWeek.toDouble()) * maxVisualBarHeight;
    return max(0, calculatedHeight); // 음수 방지
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double targetButtonWidth = screenSize.width - (16.0 * 2) ;

    final bool canGoBack = currentWeekStartDate.isAfter(oldestWeekStartDate);
    final bool canGoForward = currentWeekStartDate.isBefore(newestWeekStartDate);

    final int maxValueInCurrentWeek = currentNutrientWeekData.isEmpty
        ? 100 // 데이터 없을 시 기본 최대값 (0으로 나누는 것 방지)
        : currentNutrientWeekData.map((d) => d['value'] as int).fold(0, (max, current) => current > max ? current : max);

    String selectedNutrientName = nutrientKeys[_selectedNutrientIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Intake data", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToggleButtons(
              isSelected: _isSelectedPeriod,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _isSelectedPeriod.length; i++) {
                    _isSelectedPeriod[i] = (i == index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              selectedColor: Colors.white,
              color: Colors.black54,
              fillColor: primaryColor,
              borderColor: Colors.grey.shade300,
              selectedBorderColor: primaryColor,
              constraints: const BoxConstraints(minHeight: 35.0, minWidth: 60.0),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text("week")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text("month")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text("quater")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text("year")),
              ],
            ),
            const SizedBox(height: 8),
            if (_isSelectedPeriod[0])
              Text(
                _formatDateRange(currentWeekStartDate),
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: targetButtonWidth,
              child: OutlinedButton(
                onPressed: () {
                  _changeNutrient(1);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade600, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  selectedNutrientName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded( // 그래프 영역
              flex: 6, // scoreboard와 유사하게 공간 비율 할당 (늘림)
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (_isSelectedPeriod[0]) {
                    if (details.primaryVelocity! > 100) {
                      if (canGoBack) _changeWeek(-1);
                    } else if (details.primaryVelocity! < -100) {
                      if (canGoForward) _changeWeek(1);
                    }
                  }
                },
                onVerticalDragEnd: (details) {
                   if (details.primaryVelocity! > 200) {
                      _changeNutrient(1);
                   } else if (details.primaryVelocity! < -200) {
                      _changeNutrient(-1);
                   }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeightForGraphContainer = constraints.maxHeight;
                    final double availableWidthForGraphContainer = constraints.maxWidth;

                    // 그래프 요소들의 예상 높이 및 패딩 (scoreboard와 유사하게 조정)
                    const double valueTextFontSize = 9.0;
                    const double dayTextFontSize = 9.0;
                    const double textLineHeightApproximation = valueTextFontSize * 1.7; // 폰트 높이 근사치 (여유있게)

                    const double topSizedBoxHeight = 1.0;
                    const double bottomSizedBoxHeight = 1.0;
                    
                    // 그래프 컨테이너 자체의 상하 패딩 (Container의 padding 속성 값과 일치)
                    const double graphContainerVerticalPadding = 5.0 * 2; // 현재 Container padding: EdgeInsets.symmetric(vertical: 5.0)

                    // 실제 막대가 사용할 수 있는 최대 높이 계산
                    // (텍스트 + 간격 + 막대) 전체 Column이 LayoutBuilder의 높이 제약 내에 있도록
                    final double maxVisualBarHeight = availableHeightForGraphContainer -
                        (textLineHeightApproximation * 2) -
                        topSizedBoxHeight -
                        bottomSizedBoxHeight -
                        graphContainerVerticalPadding;
                    
                    // 막대 너비 계산
                    // (전체 너비 - 좌우 화살표 버튼 너비 추정치) / (막대 개수 * 비율)
                    // 화살표 버튼이 그래프 컨테이너 밖에 있으므로, availableWidthForGraphContainer는 순수 그래프 영역 너비
                    final double barWidth = availableWidthForGraphContainer / (currentNutrientWeekData.length * 3.0); // 막대 너비 비율 조정

                    return Container(
                      decoration: BoxDecoration(
                        color: graphBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0), // 좌우 패딩은 IconButton으로 처리되므로 0
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            iconSize: 36.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _isSelectedPeriod[0] && canGoBack ? () => _changeWeek(-1) : null,
                            color: _isSelectedPeriod[0] && canGoBack ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Container( // 실제 그래프 바들이 그려지는 영역
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: currentNutrientWeekData.map((dayData) {
                                  final barHeightValue = calculateBarHeight(
                                    dayData['value'],
                                    maxVisualBarHeight > 0 ? maxVisualBarHeight : 0, // 계산된 최대 표시 가능 막대 높이
                                    maxValueInCurrentWeek // 해당 주의 실제 최대값
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
                                        width: barWidth,
                                        decoration: BoxDecoration(
                                          color: graphAccentColor,
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
                            onPressed: _isSelectedPeriod[0] && canGoForward ? () => _changeWeek(1) : null,
                            color: _isSelectedPeriod[0] && canGoForward ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
            const SizedBox(height: 10), // 그래프와 코멘트 사이 간격 조정
            Flexible( // 코멘트 영역
              flex: 1, // scoreboard와 유사하게 공간 비율 할당 (줄임)
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                          children: [
                            TextSpan(text: "현재 선택된 '${nutrientKeys[_selectedNutrientIndex]}' 섭취량은 "),
                            TextSpan(
                              text: "다소 부족한 편", // 예시 텍스트, 실제 데이터 기반으로 변경
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                            ),
                            const TextSpan(text: "입니다. 주간 평균 섭취량을 확인하고 식단 조절에 참고하세요. 특정 요일에 섭취량이 낮은 경향이 보입니다."),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Scoreboard()),
                (Route<dynamic> route) => false,
            );
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
