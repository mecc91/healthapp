import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅
import 'dart:math'; // 랜덤 데이터

// --- 테마 색상 (scoreboard.dart와 동일하게 유지) ---
const Color primaryColor = Colors.teal;
const Color accentColor = Colors.redAccent; // 그래프 바 색상
// 그래프 컨테이너 배경색 정의
final Color graphBackgroundColor = Colors.grey.shade200;

// --- 임시 데이터 ---
// TODO: 실제 영양소 데이터를 로드하거나 전달받는 로직 구현 필요
final Map<String, List<Map<String, dynamic>>> nutrientData = {
  'Carbonhydrate': _generateSimulatedNutrientData(1),
  'Protein': _generateSimulatedNutrientData(2),
  'Fat': _generateSimulatedNutrientData(3),
  'Fiber': _generateSimulatedNutrientData(4),
  // 필요한 다른 영양소 추가
};

// 임시 영양소 데이터 생성 함수
List<Map<String, dynamic>> _generateSimulatedNutrientData(int seedOffset) {
  final random = Random(DateTime.now().millisecondsSinceEpoch + seedOffset);
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
  List<Map<String, dynamic>> weekData = [];
  for (int i = 0; i < 7; i++) {
    weekData.add({
      'day': dayNames[i],
      // 이미지와 유사한 범위의 값 생성 (예: 30 ~ 100)
      'value': random.nextInt(71) + 30,
    });
  }
  // 이미지의 'Carbonhydrate' 데이터와 유사하게 값 설정
  if (seedOffset == 1) { // 'Carbonhydrate' 데이터 시뮬레이션 시
    weekData[0]['value'] = 46;
    weekData[1]['value'] = 72;
    weekData[2]['value'] = 89;
    weekData[3]['value'] = 58;
    weekData[4]['value'] = 93;
    weekData[5]['value'] = 60;
    // --- 수정: Sunday 값도 이미지와 유사하게 설정 (오버플로우 재현 및 테스트용) ---
    // weekData[6]['value'] = random.nextInt(71) + 30;
    weekData[6]['value'] = 99; // 높은 값으로 설정하여 오버플로우 가능성 확인
  }
  return weekData;
}


class ScoreboardDetailScreen extends StatefulWidget {
  // 필요시 이전 화면에서 날짜 등의 데이터를 전달받을 수 있도록 생성자 수정
  const ScoreboardDetailScreen({super.key});

  @override
  State<ScoreboardDetailScreen> createState() => _ScoreboardDetailScreenState();
}

class _ScoreboardDetailScreenState extends State<ScoreboardDetailScreen> {
  // --- 상태 변수 ---
  List<bool> _isSelectedPeriod = [true, false, false, false]; // week, month, quater, year
  int _selectedBottomNavIndex = 0; // 하단 네비게이션 인덱스
  String _selectedNutrient = 'Carbonhydrate'; // 현재 선택된 영양소
  late DateTime currentWeekStartDate; // 현재 표시 주 시작일 (scoreboard.dart와 동기화 필요)
  List<Map<String, dynamic>> currentNutrientWeekData = []; // 현재 주의 선택된 영양소 데이터

  // 요일 이름
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // TODO: scoreboard.dart에서 현재 날짜 정보를 받아오도록 수정 필요
    // 임시로 오늘 기준 현재 주 설정
    final now = DateTime.now();
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    _loadNutrientData(); // 초기 영양소 데이터 로드
  }

  // 선택된 영양소 데이터 로드
  void _loadNutrientData() {
    setState(() {
      // TODO: 날짜 변경 로직과 연동 필요
      currentNutrientWeekData = nutrientData[_selectedNutrient] ?? _generateSimulatedNutrientData(0);
    });
  }

  // 날짜 범위 포맷팅 (scoreboard.dart와 동일 로직)
  String _formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    final formatter = DateFormat('MMMM d');
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

  // 주 변경 로직 구현 (_changeWeek from scoreboard.dart 참고)
  void _changeWeek(int weeksToAdd) {
      print("Changing week by $weeksToAdd"); // 로그 추가
       final now = DateTime.now();
       const int weeksOfDataBeforeToday = 4;
       const int weeksOfDataAfterToday = 0;

       final currentMonday = now.subtract(Duration(days: now.weekday - 1));
       final oldestWeekStartDate = currentMonday.subtract(Duration(days: weeksOfDataBeforeToday * 7));
       final newestWeekStartDate = currentMonday.add(Duration(days: weeksOfDataAfterToday * 7));

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
       _loadNutrientData(); // 변경된 주에 대한 데이터 로드
  }

  // --- 수정: 막대 높이 계산 로직 변경 ---
  // 사용 가능한 전체 높이에서 막대가 차지할 수 있는 최대 높이를 계산
  double calculateMaxPossibleBarHeight(double availableHeight) {
    // 상하 패딩과 텍스트 라벨을 위한 공간을 제외한 높이 계산
    // 예: 전체 높이의 75% 정도를 최대 막대 높이로 사용
    const double barHeightRatio = 0.75;
    // 최소 높이 보장
    final calculatedHeight = availableHeight * barHeightRatio;
    return calculatedHeight > 10 ? calculatedHeight : 10.0;
  }

  // 실제 막대 높이 계산
  double calculateBarHeight(int value, double maxPossibleBarHeight, int maxValueInWeek) {
    if (value <= 0 || maxValueInWeek <= 0 || maxPossibleBarHeight <= 0) {
      return 0; // 값이 0 이하거나 최대값이 0 이하, 또는 최대 막대 높이가 0 이하면 높이 0
    }
    // (현재 값 / 주간 최대값) * 최대 가능 막대 높이
    return (value / maxValueInWeek) * maxPossibleBarHeight;
  }
  // --- 수정 끝 ---


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 그래프 컨테이너 높이를 화면 높이의 1/2로 설정
    final double graphAreaHeight = screenSize.height * 0.5;

    // 주 이동 가능 여부 확인 로직
    final now = DateTime.now();
    const int weeksOfDataBeforeToday = 4;
    const int weeksOfDataAfterToday = 0;
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final oldestWeekStartDate = currentMonday.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    final newestWeekStartDate = currentMonday.add(Duration(days: weeksOfDataAfterToday * 7));

    final bool canGoBack = currentWeekStartDate.isAfter(oldestWeekStartDate);
    final bool canGoForward = currentWeekStartDate.isBefore(newestWeekStartDate);

    // --- 추가: 현재 주 데이터의 최대값 미리 계산 ---
    final int maxValueInCurrentWeek = currentNutrientWeekData.isEmpty
        ? 1 // 데이터 없으면 기본값 1
        : currentNutrientWeekData.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);


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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬 위주
          children: [
            // --- 기간 선택 토글 버튼 ---
            ToggleButtons(
              isSelected: _isSelectedPeriod,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _isSelectedPeriod.length; i++) {
                    _isSelectedPeriod[i] = (i == index);
                  }
                  // TODO: week 외 다른 기간 선택 시 로직 구현
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              selectedColor: Colors.white,
              color: Colors.black54,
              fillColor: primaryColor, // scoreboard.dart와 동일 색상
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
            const SizedBox(height: 10),

            // --- 날짜 범위 표시 ---
            Text(
              _formatDateRange(currentWeekStartDate),
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // --- 영양소 선택 버튼 ---
            OutlinedButton(
              onPressed: () {
                // TODO: 영양소 선택 기능 구현 (팝업, 드롭다운 등)
                final nutrients = nutrientData.keys.toList();
                int currentIndex = nutrients.indexOf(_selectedNutrient);
                int nextIndex = (currentIndex + 1) % nutrients.length;
                setState(() {
                  _selectedNutrient = nutrients[nextIndex];
                });
                _loadNutrientData();
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Selected: $_selectedNutrient'), duration: Duration(seconds: 1)),
                 );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade600, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(
                _selectedNutrient,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 그래프 영역을 감싸는 컨테이너
            Container(
              height: graphAreaHeight, // 화면 높이의 1/2
              decoration: BoxDecoration(
                color: graphBackgroundColor, // 연회색 배경
                borderRadius: BorderRadius.circular(16), // 둥근 모서리
              ),
              // --- 수정: 내부 패딩 조정 ---
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0), // 상하 패딩 줄이고 좌우 제거
              child: Row( // 화살표 + 그래프 영역 Row
                crossAxisAlignment: CrossAxisAlignment.center, // 화살표 버튼 세로 중앙 정렬
                children: [
                  // 왼쪽 화살표
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 36.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: canGoBack ? () => _changeWeek(-1) : null,
                    color: canGoBack ? Colors.grey : Colors.grey.shade300,
                  ),
                  // 그래프 컨테이너 (Expanded)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 컨테이너의 실제 높이를 기준으로 maxBarHeight 계산
                        final double availableHeight = constraints.maxHeight;
                        // --- 수정: 새로운 함수 사용 ---
                        final double maxPossibleBarHeight = calculateMaxPossibleBarHeight(availableHeight);

                        return Container( // 그래프 바들을 담는 내부 컨테이너 (배경색 없음)
                          // --- 수정: 내부 패딩 조정 ---
                          padding: const EdgeInsets.symmetric(horizontal: 5.0), // 좌우 패딩 약간 추가
                          child: Row( // 막대 그래프 Row
                            crossAxisAlignment: CrossAxisAlignment.end, // 컬럼들을 아래쪽 기준으로 정렬
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: currentNutrientWeekData.map((dayData) {
                              // --- 수정: 새로운 함수 사용 및 최대값 전달 ---
                              final barHeight = calculateBarHeight(
                                dayData['value'],
                                maxPossibleBarHeight,
                                maxValueInCurrentWeek // 현재 주의 최대값 전달
                              );
                              return Column( // 각 막대 + 라벨 Column
                                mainAxisAlignment: MainAxisAlignment.end, // 내부 요소들을 아래쪽 기준으로 정렬
                                children: [
                                  Text(
                                    "${dayData['value']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: barHeight < 0 ? 0 : barHeight, // 음수 방지
                                    width: 20, // 막대 너비
                                    decoration: BoxDecoration(
                                      color: accentColor, // 막대 색상
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayData['day'],
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      }
                    ),
                  ),
                  // 오른쪽 화살표
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 36.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: canGoForward ? () => _changeWeek(1) : null,
                    color: canGoForward ? Colors.grey : Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 요약 텍스트 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  children: [
                    const TextSpan(text: "The current nutrient intake shows an "),
                    TextSpan(
                      text: "imbalance",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                    ),
                    const TextSpan(text: ", with excessive consumption of carbohydrates and insufficient intake of essential vitamins and minerals. Protein levels are generally adequate, but fiber and..."),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Flexible(child: SizedBox(height: 20)), // 하단 공간 확보
          ],
        ),
      ),

      // --- 하단 네비게이션 바 (scoreboard.dart와 동일) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (int index) {
          setState(() { _selectedBottomNavIndex = index; });
          // TODO: 각 탭 기능 구현 (필요시 페이지 이동)
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
