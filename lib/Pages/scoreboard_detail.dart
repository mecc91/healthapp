import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅
import 'dart:math'; // 랜덤 데이터

// --- 테마 색상 (scoreboard.dart와 동일하게 유지) ---
const Color primaryColor = Colors.teal;
const Color accentColor = Colors.redAccent; // 그래프 바 색상
// 그래프 컨테이너 배경색 정의
final Color graphBackgroundColor = Colors.grey.shade200;

// --- 데이터 시뮬레이션 설정 (scoreboard.dart와 동일하게 유지) ---
const int weeksOfDataBeforeToday = 4;
const int weeksOfDataAfterToday = 0; // 미래 데이터 없음

// --- 임시 데이터 ---
// TODO: 실제 영양소 데이터를 로드하거나 전달받는 로직 구현 필요
// --- 수정: 데이터 구조 변경 없음, 생성 함수에서 날짜 사용 ---
final List<String> nutrientKeys = ['Carbonhydrate', 'Protein', 'Fat', 'Fiber']; // 영양소 순서 정의

// 임시 영양소 데이터 생성 함수 (주차별 일관성 유지)
List<Map<String, dynamic>> _generateSimulatedNutrientData(String nutrient, DateTime startDate) {
  // 영양소 이름과 시작 날짜를 조합하여 고유 시드 생성
  final seed = nutrient.hashCode ^ startDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  final random = Random(seed);
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
  List<Map<String, dynamic>> weekData = [];
  for (int i = 0; i < 7; i++) {
    weekData.add({
      'day': dayNames[i],
      // 값 범위 유지
      'value': random.nextInt(71) + 30,
    });
  }
  // 특정 영양소/주에 대한 값 고정 (필요시)
  // if (nutrient == 'Carbonhydrate' && startDate == someSpecificDate) { ... }
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
  // --- 수정: nutrientKeys 사용 ---
  int _selectedNutrientIndex = 0; // 현재 선택된 영양소 인덱스
  late DateTime currentWeekStartDate; // 현재 표시 주 시작일
  // --- 추가: 주 경계 날짜 ---
  late DateTime oldestWeekStartDate;
  late DateTime newestWeekStartDate;
  List<Map<String, dynamic>> currentNutrientWeekData = []; // 현재 주의 선택된 영양소 데이터

  // 요일 이름
  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _initializeDates(); // 날짜 초기화
    _loadNutrientData(); // 초기 영양소 데이터 로드
  }

  // --- 추가: 날짜 초기화 함수 ---
  void _initializeDates() {
    final now = DateTime.now();
    // 현재 주의 월요일 계산
    currentWeekStartDate = now.subtract(Duration(days: now.weekday - 1));
    // 가장 오래된 주와 최신 주 계산
    oldestWeekStartDate = currentWeekStartDate.subtract(Duration(days: weeksOfDataBeforeToday * 7));
    newestWeekStartDate = currentWeekStartDate.add(Duration(days: weeksOfDataAfterToday * 7)); // 현재 주가 최신
  }

  // 선택된 영양소 데이터 로드
  void _loadNutrientData() {
    setState(() {
      String selectedNutrient = nutrientKeys[_selectedNutrientIndex];
      // --- 수정: _generateSimulatedNutrientData 호출 시 nutrient와 startDate 전달 ---
      currentNutrientWeekData = _generateSimulatedNutrientData(selectedNutrient, currentWeekStartDate);
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

  // 주 변경 로직 구현 (scoreboard.dart 참고 및 경계 확인 강화)
  void _changeWeek(int weeksToAdd) {
      // --- 추가: 'week' 탭이 아닐 경우 주 변경 방지 ---
      if (!_isSelectedPeriod[0]) return;

      final targetStartDate = currentWeekStartDate.add(Duration(days: weeksToAdd * 7));

      // 경계 확인 (isBefore는 같은 날짜면 false 반환)
      if (targetStartDate.isBefore(oldestWeekStartDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('더 이상 이전 데이터가 없습니다.'), duration: Duration(seconds: 1)),
        );
        return;
      }
      // isAfter는 같은 날짜면 false 반환
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

  // --- 추가: 영양소 변경 로직 ---
  void _changeNutrient(int indexOffset) {
      setState(() {
          _selectedNutrientIndex = (_selectedNutrientIndex + indexOffset + nutrientKeys.length) % nutrientKeys.length;
      });
      _loadNutrientData(); // 변경된 영양소 데이터 로드
      // 선택된 영양소 이름 표시 (옵션)
      // ScaffoldMessenger.of(context).showSnackBar(
      //    SnackBar(content: Text('Selected: ${nutrientKeys[_selectedNutrientIndex]}'), duration: Duration(seconds: 1)),
      // );
  }

  // 사용 가능한 전체 높이에서 막대가 차지할 수 있는 최대 높이를 계산
  double calculateMaxPossibleBarHeight(double availableHeight) {
    const double barHeightRatio = 0.75;
    final calculatedHeight = availableHeight * barHeightRatio;
    return calculatedHeight > 10 ? calculatedHeight : 10.0;
  }

  // 실제 막대 높이 계산
  double calculateBarHeight(int value, double maxPossibleBarHeight, int maxValueInWeek) {
    if (value <= 0 || maxValueInWeek <= 0 || maxPossibleBarHeight <= 0) {
      return 0;
    }
    return (value / maxValueInWeek) * maxPossibleBarHeight;
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 그래프 컨테이너 높이를 화면 높이의 1/2로 설정
    final double graphAreaHeight = screenSize.height * 0.5;
    // 버튼 너비 계산에 필요한 값
    const double horizontalBodyPadding = 16.0 * 2; // 좌우 패딩 합
    const double iconButtonApproxWidth = 48.0 * 2; // 양쪽 아이콘 버튼 너비 추정치 합
    final double graphContainerInnerWidth = screenSize.width - horizontalBodyPadding - iconButtonApproxWidth;
    final double buttonHorizontalMargin = (screenSize.width - graphContainerInnerWidth) / 2;
    final double targetButtonWidth = screenSize.width - buttonHorizontalMargin;


    // 주 이동 가능 여부 확인 로직 (initState에서 계산된 값 사용)
    final bool canGoBack = currentWeekStartDate.isAfter(oldestWeekStartDate);
    final bool canGoForward = currentWeekStartDate.isBefore(newestWeekStartDate);

    // 현재 주 데이터의 최대값 미리 계산
    final int maxValueInCurrentWeek = currentNutrientWeekData.isEmpty
        ? 1
        : currentNutrientWeekData.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);

    // 현재 선택된 영양소 이름
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
            const SizedBox(height: 10),

            // --- 날짜 범위 표시 ---
            // --- 수정: 'week' 탭 선택 시에만 표시 (옵션) ---
            if (_isSelectedPeriod[0])
              Text(
                _formatDateRange(currentWeekStartDate),
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            // TODO: 다른 기간 탭 선택 시 해당 기간 표시 로직 추가
            const SizedBox(height: 15),

            // --- 영양소 선택 버튼 ---
            SizedBox(
              width: targetButtonWidth, // 계산된 너비 적용
              child: OutlinedButton(
                onPressed: () {
                  // 버튼 클릭 시 영양소 변경 (스와이프와 동일 기능)
                  _changeNutrient(1); // 다음 영양소로 변경
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade600, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  // --- 수정: 상태 변수에서 영양소 이름 가져오기 ---
                  selectedNutrientName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 수정: GestureDetector 추가 ---
            GestureDetector(
              onHorizontalDragEnd: (details) {
                // week 탭이 선택되었을 때만 좌우 스와이프 처리
                if (_isSelectedPeriod[0]) {
                  // 오른쪽으로 스와이프 (velocity > 0) -> 이전 주
                  if (details.primaryVelocity! > 100) {
                    _changeWeek(-1);
                  }
                  // 왼쪽으로 스와이프 (velocity < 0) -> 다음 주
                  else if (details.primaryVelocity! < -100) {
                    _changeWeek(1);
                  }
                }
              },
              onVerticalDragEnd: (details) {
                 // 아래로 스와이프 (velocity > 0) -> 다음 영양소
                 if (details.primaryVelocity! > 200) { // 임계값 조절 가능
                    _changeNutrient(1);
                 }
                 // 위로 스와이프 (velocity < 0) -> 이전 영양소
                 else if (details.primaryVelocity! < -200) { // 임계값 조절 가능
                    _changeNutrient(-1);
                 }
              },
              child: Container( // 그래프 영역을 감싸는 컨테이너
                height: graphAreaHeight, // 화면 높이의 1/2
                decoration: BoxDecoration(
                  color: graphBackgroundColor, // 연회색 배경
                  borderRadius: BorderRadius.circular(16), // 둥근 모서리
                ),
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                child: Row( // 화살표 + 그래프 영역 Row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 왼쪽 화살표
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 36.0,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      // --- 수정: week 탭 활성화 및 이동 가능 여부 동시 체크 ---
                      onPressed: _isSelectedPeriod[0] && canGoBack ? () => _changeWeek(-1) : null,
                      color: _isSelectedPeriod[0] && canGoBack ? Colors.grey : Colors.grey.shade300,
                    ),
                    // 그래프 컨테이너 (Expanded)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double availableHeight = constraints.maxHeight;
                          final double maxPossibleBarHeight = calculateMaxPossibleBarHeight(availableHeight);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: currentNutrientWeekData.map((dayData) {
                                final barHeight = calculateBarHeight(
                                  dayData['value'],
                                  maxPossibleBarHeight,
                                  maxValueInCurrentWeek
                                );
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${dayData['value']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: barHeight < 0 ? 0 : barHeight,
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
                      // --- 수정: week 탭 활성화 및 이동 가능 여부 동시 체크 ---
                      onPressed: _isSelectedPeriod[0] && canGoForward ? () => _changeWeek(1) : null,
                      color: _isSelectedPeriod[0] && canGoForward ? Colors.grey : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ), // GestureDetector 끝
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
