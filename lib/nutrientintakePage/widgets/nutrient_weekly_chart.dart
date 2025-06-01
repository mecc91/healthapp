// lib/nutrientintakePage/widgets/nutrient_weekly_chart.dart
import 'package:flutter/material.dart';
import '../nutrient_intake_constants.dart'; // 상수 (색상, 텍스트 크기 등)
import '../services/nutrient_intake_data_service.dart'; // NutrientIntakeDataService.calculateBarHeight

class NutrientWeeklyChart extends StatefulWidget {
  final List<Map<String, dynamic>> weekData; // 주간 데이터 (각 항목은 {'day': String, 'value': int score, 'date': DateTime})
  final Function(int) onChangeWeek; // 주 변경 콜백 (weeksToAdd)
  final Function(int) onChangeNutrientViaSwipe; // (코멘트용) 영양소 변경 콜백 (indexOffset)
  final bool canGoBack; // 이전 주로 이동 가능 여부
  final bool canGoForward; // 다음 주로 이동 가능 여부
  final bool isWeekPeriodSelected; // 현재 주간 보기가 활성화되어 있는지 여부

  const NutrientWeeklyChart({
    super.key,
    required this.weekData,
    required this.onChangeWeek,
    required this.onChangeNutrientViaSwipe,
    required this.canGoBack,
    required this.canGoForward,
    required this.isWeekPeriodSelected,
  });

  @override
  State<NutrientWeeklyChart> createState() => _NutrientWeeklyChartState();
}

class _NutrientWeeklyChartState extends State<NutrientWeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // 애니메이션 컨트롤러
  late Animation<double> _fadeAnimation; // Fade-in 애니메이션
  late Animation<Offset> _slideAnimation; // Slide-up 애니메이션

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 애니메이션 지속 시간
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // 아래에서 약간 위로 슬라이드
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 위젯이 빌드된 후 애니메이션 시작 (데이터가 있을 때만)
    if (widget.weekData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0.0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant NutrientWeeklyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // weekData가 변경되면 (특히, 비어있다가 데이터가 생기거나, 데이터 내용이 변경될 때)
    // 애니메이션을 다시 시작하여 새로운 데이터를 부드럽게 표시합니다.
    // List<Map>의 경우 참조 비교만으로는 내부 값 변경을 감지하기 어려우므로,
    // 상위 위젯에서 새로운 List 객체를 전달해야 애니메이션이 효과적으로 트리거됩니다.
    if (oldWidget.weekData != widget.weekData) {
      if (mounted) {
        _controller.reset(); // 애니메이션 상태 초기화
        if (widget.weekData.isNotEmpty) { // 새로운 데이터가 있을 경우에만 애니메이션 실행
          _controller.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 주 데이터에서 최대 점수 값을 찾음. 바 높이 계산에 사용.
    // DailyIntake.score의 최대값을 100으로 가정할 수도 있음.
    final int maxValueInPeriod = widget.weekData.isEmpty
        ? 100 // 데이터가 없으면 기본 최대 점수 100으로 가정
        : widget.weekData
            .map((d) => d['value'] as int? ?? 0) // 'value'는 DailyIntake.score, null이면 0
            .reduce((a, b) => a > b ? a : b); // 최대값 찾기
    
    // maxValueInPeriod가 0 이하인 경우 나눗셈 오류 방지를 위해 100으로 보정
    final int effectiveMaxValue = maxValueInPeriod > 0 ? maxValueInPeriod : 100;

    return GestureDetector(
      // 가로 스와이프로 주 변경
      onHorizontalDragEnd: (details) {
        if (widget.isWeekPeriodSelected && details.primaryVelocity != null) {
          if (details.primaryVelocity! > 100 && widget.canGoBack) { // 오른쪽으로 스와이프 (이전 주)
            widget.onChangeWeek(-1);
          } else if (details.primaryVelocity! < -100 && widget.canGoForward) { // 왼쪽으로 스와이프 (다음 주)
            widget.onChangeWeek(1);
          }
        }
      },
      // 세로 스와이프로 (코멘트용) 영양소 변경
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 200) { // 아래로 스와이프 (다음 영양소)
            widget.onChangeNutrientViaSwipe(1);
          } else if (details.primaryVelocity! < -200) { // 위로 스와이프 (이전 영양소)
            widget.onChangeNutrientViaSwipe(-1);
          }
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder( // 사용 가능한 공간에 맞춰 차트 크기 조절
            builder: (context, constraints) {
              // 바의 최대 높이 계산 (컨테이너 높이 - 상하 텍스트 공간 - 여백)
              final double maxBarHeight = constraints.maxHeight -
                  (kGraphTextLineHeightApproximation * 2) - // 상단 점수 텍스트 + 하단 요일 텍스트
                  kGraphTopSizedBoxHeight -
                  kGraphBottomSizedBoxHeight -
                  kGraphContainerVerticalPadding; // 컨테이너 자체의 상하 패딩

              // 각 바의 너비 계산 (사용 가능한 너비 / (데이터 개수 * 비율))
              // 비율을 조정하여 바 사이의 간격 조절 가능
              final double barWidth = widget.weekData.isEmpty
                  ? 0
                  : (constraints.maxWidth - (36 * 2) - 16) / (widget.weekData.length * 1.5); // 버튼 너비와 내부 패딩 고려, 바 간격 조절


              return Container(
                decoration: BoxDecoration(
                  color: kNutrientIntakeGraphBackgroundColor, // 그래프 배경색
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: kGraphContainerVerticalPadding / 2, horizontal: 8.0), // 컨테이너 내부 패딩 (좌우 추가)
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
                  children: [
                    // 이전 주 이동 버튼
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 32.0, // 아이콘 크기 조절
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // 버튼 크기 최소화
                      onPressed: widget.isWeekPeriodSelected && widget.canGoBack
                          ? () => widget.onChangeWeek(-1)
                          : null, // 이동 불가 시 비활성화
                      color: widget.isWeekPeriodSelected && widget.canGoBack
                          ? Colors.grey.shade700 // 활성 색상
                          : Colors.grey.shade300, // 비활성 색상
                    ),
                    // 주간 바 차트 영역
                    Expanded(
                      child: widget.weekData.isEmpty
                          ? const Center(child: Text("표시할 데이터가 없습니다.", style: TextStyle(color: Colors.grey))) // 데이터 없을 시 메시지
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround, // 바들을 균등 간격으로 배치
                              crossAxisAlignment: CrossAxisAlignment.end, // 바들을 아래쪽 기준으로 정렬
                              children: widget.weekData.asMap().entries.map((entry) {
                                // final int index = entry.key; // 인덱스 (필요시 사용)
                                final Map<String, dynamic> data = entry.value; // {'day': String, 'value': int score, 'date': DateTime}
                                final int scoreValue = data['value'] as int? ?? 0; // null이면 0
                                final String dayName = data['day'] as String? ?? ''; // null이면 빈 문자열

                                // 실제 바 높이 계산
                                final barHeight =
                                    NutrientIntakeDataService.calculateBarHeight(
                                  scoreValue,
                                  maxBarHeight > 0 ? maxBarHeight : 1, // maxBarHeight가 0 이하가 되지 않도록 보정
                                  effectiveMaxValue, // 해당 주의 유효 최대 점수
                                );

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end, // 아래쪽 기준으로 정렬
                                  children: [
                                    // 점수 텍스트
                                    Text(
                                      "$scoreValue",
                                      style: const TextStyle(
                                        fontSize: kGraphValueTextFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54, // 점수 텍스트 색상
                                      ),
                                    ),
                                    const SizedBox(height: kGraphTopSizedBoxHeight), // 바 위쪽 여백
                                    // 애니메이션 적용된 바
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: barHeight < 0 ? 0 : barHeight), // 높이가 음수가 되지 않도록
                                      duration: const Duration(milliseconds: 500), // 바 높이 변경 애니메이션
                                      curve: Curves.easeOutCubic, // 부드러운 애니메이션 곡선
                                      builder: (context, animatedHeight, child) {
                                        return Container(
                                          height: animatedHeight,
                                          width: barWidth > 0 ? barWidth : 10, // 최소 너비 보장
                                          decoration: BoxDecoration(
                                            color: kNutrientIntakeGraphAccentColor, // 바 색상
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6), // 바 상단 모서리 둥글게
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: kGraphBottomSizedBoxHeight), // 바 아래쪽 여백
                                    // 요일 텍스트
                                    Text(
                                      dayName,
                                      style: const TextStyle(
                                        fontSize: kGraphDayTextFontSize,
                                        fontWeight: FontWeight.w500, // 요일 텍스트 두께 조절
                                        color: Colors.black87, // 요일 텍스트 색상
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                    // 다음 주 이동 버튼
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 32.0, // 아이콘 크기 조절
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed:
                          widget.isWeekPeriodSelected && widget.canGoForward
                              ? () => widget.onChangeWeek(1)
                              : null,
                      color: widget.isWeekPeriodSelected && widget.canGoForward
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
