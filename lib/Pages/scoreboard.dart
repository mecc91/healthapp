import 'package:flutter/material.dart';

// 기본 테마 색상 정의 (이미지의 청록색 계열)
const Color primaryColor = Colors.teal;
const Color accentColor = Colors.redAccent; // 막대 그래프 색상
// IconButton의 가로 크기와 유사하게 맞추기 위한 값 (iconSize + 패딩 고려)
const double arrowButtonHorizontalSpace = 48.0;

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScoreboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// StatefulWidget으로 변경
class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  // ToggleButtons 상태 관리
  List<bool> _isSelected = [true, false, false, false];

  // BottomNavigationBar 상태 관리
  int _selectedIndex = 0;

  // 주간 데이터 (변경 없음)
  final List<Map<String, dynamic>> weekData = const [
    {'day': 'Mon', 'value': 46},
    {'day': 'Tue', 'value': 72},
    {'day': 'Wed', 'value': 89},
    {'day': 'Thu', 'value': 58},
    {'day': 'Fri', 'value': 37},
    {'day': 'Sat', 'value': 93},
    {'day': 'Sun', 'value': 60},
  ];

  // 컨테이너 높이에 따라 막대 최대 높이 계산
  double calculateMaxBarHeight(double containerHeight) {
    const double verticalPaddingAndLabelsHeight = 80.0;
    double calculatedHeight = containerHeight - verticalPaddingAndLabelsHeight;
    return calculatedHeight > 50 ? calculatedHeight : 50.0;
  }

  // 값에 따른 막대 높이 계산 (maxBarHeight 인자 추가)
  double calculateBarHeight(int value, double maxBarHeight) {
     final maxValue = weekData.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);
     if (maxValue <= 0 || maxBarHeight <= 0) return 0; // 0 또는 음수 방지
     return (value / maxValue) * maxBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double graphContainerHeight = screenSize.height * 0.45;
    final double maxBarHeight = calculateMaxBarHeight(graphContainerHeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scoreboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        // 전체적인 좌우 패딩은 유지
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center( // ToggleButtons 가운데 정렬
              child: ToggleButtons(
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = false;
                    }
                    _isSelected[index] = true;
                  });
                  // TODO: 선택된 기간 데이터 로딩
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
            ),
            const SizedBox(height: 20),

            // --- 수정: avr 텍스트 좌우에 그래프 화살표만큼 간격 추가 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: arrowButtonHorizontalSpace),
              child: const Text(
                "avr",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const SizedBox(height: 2),

            // --- 수정: 점수/날짜와 detail 버튼 영역 좌우에 그래프 화살표만큼 간격 추가 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: arrowButtonHorizontalSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text.rich(
                        TextSpan(
                          // 기본 스타일 (65에 적용됨)
                           style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                          children: [
                            const TextSpan(text: '65'),
                            // --- 수정: point 텍스트 색상 변경 (별도 색상 지정 제거) ---
                            const TextSpan(
                              text: ' point',
                              // color: Colors.black54 제거 -> 기본 스타일 상속 (검은색)
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal), // 크기, 굵기만 별도 지정
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "March 30th ~ April 6th",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                       // TODO: 상세 보기 화면 이동 로직
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor, side: const BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8.0),
                       ),
                    ),
                    child: const Text("detail"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 그래프와 화살표 Row (변경 없음)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 36.0,
                  padding: EdgeInsets.zero, // 패딩 최소화 시도
                  constraints: const BoxConstraints(), // 제약 조건 최소화 시도
                  onPressed: () { /* TODO */ },
                  color: Colors.grey,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    height: graphContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekData.map((dayData) {
                        final barHeight = calculateBarHeight(dayData['value'], maxBarHeight);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${dayData['value']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                            Text(
                              dayData['day'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                              )
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
                  padding: EdgeInsets.zero, // 패딩 최소화 시도
                  constraints: const BoxConstraints(), // 제약 조건 최소화 시도
                  onPressed: () { /* TODO */ },
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- 수정: 결과 텍스트 스타일 및 간격 조정 ---
            Text.rich(
              TextSpan(
                // 기본 스타일 (볼드, 크기 증가)
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                children: const [
                  TextSpan(text: "Good results ", style: TextStyle(color: Colors.green)),
                  // 나머지 텍스트는 기본 스타일(검은색, 볼드, 크기 15) 상속
                  TextSpan(text: "in protein, dietary fiber, and fat intake!"),
                ],
              ),
            ),
            // --- 수정: 두 문장 사이 간격 조정 ---
            const SizedBox(height: 10), // 간격 조정 (예: 10)
            Text.rich(
              TextSpan(
                // 기본 스타일 (볼드, 크기 증가)
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                children: const [
                  TextSpan(text: "Careful ", style: TextStyle(color: Colors.red)),
                   // 나머지 텍스트는 기본 스타일(검은색, 볼드, 크기 15) 상속
                  TextSpan(text: "about carbohydrate, cholesterol, and sodium intake!"),
                ],
              ),
            ),
            const SizedBox(height: 20), // 하단 여백
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() { _selectedIndex = index; });
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
