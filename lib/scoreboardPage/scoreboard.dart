import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가
import 'dart:math'; // 랜덤 데이터 생성을 위해 추가
import '../nutrientintakePage/nutrientintake.dart'; // 상세 화면 import 추가

// 기본 테마 색상 정의
const Color primaryColor = Colors.teal;
const Color accentColor = Color.fromRGBO(255, 82, 82, 1);
const double arrowButtonHorizontalSpace = 48.0;

// --- 데이터 시뮬레이션 설정 ---
// 오늘 날짜 기준 몇 주 전/후 데이터까지 생성할지 설정
const int weeksOfDataBeforeToday = 4;
const int weeksOfDataAfterToday = 0; // 미래 데이터는 없다고 가정

class Scoreboard extends StatefulWidget {
  const Scoreboard({super.key});

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  List<bool> _isSelected = [true, false, false, false];
  int _selectedIndex = 0;

  // --- 상태 변수 추가 ---
  late DateTime currentWeekStartDate; // 현재 표시 중인 주의 시작일 (월요일 기준)
  late DateTime oldestWeekStartDate; // 표시 가능한 가장 오래된 주의 시작일
  late DateTime newestWeekStartDate; // 표시 가능한 가장 최신 주의 시작일
  List<Map<String, dynamic>> currentWeekData = []; // 현재 주의 데이터
  double currentAverageScore = 0; // 현재 주의 평균 점수

  // 요일 이름 매핑 (데이터 생성 시 사용)
  final List<String> dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _initializeDatesAndData();
  }

  // 날짜 및 초기 데이터 설정
  void _initializeDatesAndData() {
    final now = DateTime.now();
    // 현재 주의 월요일 계산
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    // 가장 오래된 주와 최신 주 계산
    oldestWeekStartDate = currentWeekStartDate
        .subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate
        .subtract(Duration(days: -weeksOfDataAfterToday * 7));

    // 초기 데이터 로드
    _loadWeekData(currentWeekStartDate);
  }

  // 특정 주의 데이터 로드 (시뮬레이션)
  void _loadWeekData(DateTime startDate) {
    setState(() {
      currentWeekStartDate = startDate;
      currentWeekData = _getSimulatedWeekData(startDate);
      currentAverageScore = _calculateAverageScore(currentWeekData);
    });
  }

  // 주간 데이터 시뮬레이션 함수
  List<Map<String, dynamic>> _getSimulatedWeekData(DateTime startDate) {
    // startDate를 기반으로 고유한 랜덤 시드를 생성하여 매번 같은 주에 대해 동일한 데이터 생성
    final random =
        Random(startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay);
    List<Map<String, dynamic>> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add({
        'day': dayNames[i],
        'value': random.nextInt(71) + 30, // 30 ~ 100 사이의 랜덤 점수
      });
    }
    return weekData;
  }

  // 평균 점수 계산
  double _calculateAverageScore(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    final totalScore =
        data.map((d) => d['value'] as int).reduce((a, b) => a + b);
    return totalScore / data.length;
  }

  // 날짜 범위 포맷팅
  String _formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    // 예: April 28 ~ May 4
    final formatter = DateFormat('MMMM d'); // 'th' 등 서수 표현은 intl 기본 기능 아님
    return "${formatter.format(startDate)} ~ ${formatter.format(endDate)}";
  }

  // 이전/다음 주로 변경하는 로직
  void _changeWeek(int weeksToAdd) {
    final targetStartDate =
        currentWeekStartDate.add(Duration(days: weeksToAdd * 7));

    // 경계 확인
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

    // 데이터 로드
    _loadWeekData(targetStartDate);
  }

  // 컨테이너 높이에 따라 막대 최대 높이 계산
  double calculateMaxBarHeight(double containerHeight) {
    const double verticalPaddingAndLabelsHeight = 80.0;
    double calculatedHeight = containerHeight - verticalPaddingAndLabelsHeight;
    return calculatedHeight > 50 ? calculatedHeight : 50.0;
  }

  // 값에 따른 막대 높이 계산 (maxBarHeight 인자 추가)
  double calculateBarHeight(int value, double maxBarHeight) {
    // 현재 주 데이터의 최대값 찾기
    if (currentWeekData.isEmpty) return 0;
    // 데이터가 모두 0 이하일 경우 maxValue가 0이 될 수 있으므로 기본값 1 설정
    final maxValue = currentWeekData
        .map((d) => d['value'] as int)
        .reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0 || maxBarHeight <= 0)
      return 0; // 0 또는 음수 방지, 최대값이 0이하일 때 높이 0 반환
    return (value / maxValue) * maxBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double graphContainerHeight = screenSize.height * 0.45;
    final double maxBarHeight = calculateMaxBarHeight(graphContainerHeight);

    // 버튼 활성화 상태 결정
    final bool canGoBack = currentWeekStartDate.isAfter(oldestWeekStartDate);
    final bool canGoForward =
        currentWeekStartDate.isBefore(newestWeekStartDate);

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // ToggleButtons
              child: ToggleButtons(
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = false;
                    }
                    _isSelected[index] = true;
                    // TODO: 다른 탭(month, quater, year) 기능 구현 시 로직 추가
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
            const SizedBox(height: 20),

            // --- avr, 점수, 날짜, detail 버튼 영역 ---
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: arrowButtonHorizontalSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("avr",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              // 평균 점수 표시
                              TextSpan(
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                children: [
                                  // 평균 점수를 반올림하여 정수로 표시
                                  TextSpan(
                                      text: currentAverageScore
                                          .toStringAsFixed(0)),
                                  const TextSpan(
                                    text: ' point',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                // 날짜 범위 표시
                                _formatDateRange(currentWeekStartDate),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        OutlinedButton(
                          // --- 수정된 부분 ---
                          onPressed: () {
                            // ScoreboardDetailScreen으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NutrientIntake()),
                            );
                          },
                          // --- 여기까지 ---
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: const Text("detail"),
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 20),

            // --- 그래프 영역 (스와이프 감지 추가) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 왼쪽 화살표 버튼 (활성화/비활성화)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  // 이전 주로 갈 수 없으면 onPressed 비활성화 (null)
                  onPressed: canGoBack ? () => _changeWeek(-1) : null,
                  // 비활성화 시 색상 변경
                  color: canGoBack ? Colors.grey : Colors.grey.shade300,
                ),
                // GestureDetector로 스와이프 감지 영역 확장
                Expanded(
                  child: GestureDetector(
                    // 스와이프 종료 시 호출
                    onHorizontalDragEnd: (details) {
                      // 스와이프 속도 및 방향 확인
                      // --- 수정: 스와이프 방향 반전 ---
                      if (details.primaryVelocity! > 100) {
                        // 오른쪽 스와이프 (속도 임계값 조절 가능)
                        _changeWeek(-1); // 이전 주 (스와이프 방향에 맞춰 수정)
                      } else if (details.primaryVelocity! < -100) {
                        // 왼쪽 스와이프
                        _changeWeek(1); // 다음 주 (스와이프 방향에 맞춰 수정)
                      }
                    },
                    child: Container(
                      // 그래프 컨테이너
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      height: graphContainerHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        // 막대 그래프
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: currentWeekData.map((dayData) {
                          final barHeight = calculateBarHeight(
                              dayData['value'], maxBarHeight);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("${dayData['value']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              Container(
                                height: barHeight,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(dayData['day'],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // 오른쪽 화살표 버튼 (활성화/비활성화)
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  // 다음 주로 갈 수 없으면 onPressed 비활성화 (null)
                  onPressed: canGoForward ? () => _changeWeek(1) : null,
                  // 비활성화 시 색상 변경
                  color: canGoForward ? Colors.grey : Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- 결과 텍스트 ---
            Text.rich(
              TextSpan(
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                children: const [
                  TextSpan(
                      text: "Good results ",
                      style: TextStyle(color: Colors.green)),
                  TextSpan(text: "in protein, dietary fiber, and fat intake!"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                children: const [
                  TextSpan(
                      text: "Careful ", style: TextStyle(color: Colors.red)),
                  TextSpan(
                      text:
                          "about carbohydrate, cholesterol, and sodium intake!"),
                ],
              ),
            ),
            const SizedBox(height: 20), // 하단 여백
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 하단 네비게이션 바
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: 각 탭 기능 구현
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: ''),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
