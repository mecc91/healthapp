import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';

class IntakeLevel extends StatefulWidget {
  final IntakeData _intake;

  const IntakeLevel(this._intake, {super.key});

  @override
  State<IntakeLevel> createState() => _IntakeLevelState();
}

class _IntakeLevelState extends State<IntakeLevel>
    with SingleTickerProviderStateMixin {
  final double _totalWidth = 300.0;
  final double _blockHeight = 24.0;

  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  /*
  late Animation<double> _fadeAnimation;  
  late Animation<Offset> _slideAnimation; 
  */
  Color barColor = Colors.black;
  void barColorSelector(double ratio)
  {
    setState(() {
      if (ratio <= 0.4) {
        barColor = const Color(0xFFFFA726); // 강한 빨강 (매우 부족)
      } else if (ratio <= 0.8) {
        barColor = const Color(0xFF43A047); // 진한 주황 (부족)
      } else if (ratio <= 1.2) {
        barColor = const Color(0xFF1E88E5); // 진한 초록 (적정)
      } else if (ratio <= 1.6) {
        barColor = const Color(0xFFFB8C00); // 오렌지 (초과)
      } else {
        barColor = const Color(0xFFD32F2F); // 다크레드 (많이 초과)
      }
    });
  }

  @override
  void initState() {
    super.initState();
    double ratio = widget._intake.intakeamount / widget._intake.requiredintake;
    barColorSelector(ratio);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(begin: 0, end: ratio).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    /*
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  // _intake 값 변경시마다 애니메이션 재실행
  @override
  void didUpdateWidget(covariant IntakeLevel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // intake 데이터가 바뀌었을 때만 재애니메이션
    if (widget._intake != oldWidget._intake) {
      // update 애니메이션 end 값
      double ratio = widget._intake.intakeamount / widget._intake.requiredintake;
      _fillAnimation = Tween<double>(begin: 0, end: ratio).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      barColorSelector(ratio);
      _controller.forward(from: 0); // 애니메이션 재시작
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double center = _totalWidth / 2;
    final double maxRatio = 2.0; // 최대 200%까지 표현

    return /*SlideTransition(
      position: _slideAnimation,
      /*child: FadeTransition(
        opacity: _fadeAnimation,*/
        child: */Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상단 영양소 / 섭취량 텍스트
                Row(
                  children: [
                    const SizedBox(width: 25),
                    Text(
                      widget._intake.nutrientname,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget._intake.intakeamount.round()}${widget._intake.intakeunit}',
                      style: TextStyle(
                        color: barColor,
                          fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      ' 섭취',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(
                  width: _totalWidth,
                  height: _blockHeight + 24 + 4,
                  child: Stack(
                    children: [
                      // 기준선
                      Positioned(
                        left: center - 2,
                        top: 12,
                        bottom: 20,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // 바 배경
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 12,
                        child: Container(
                          height: _blockHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black26, width: 2),
                          ),
                        ),
                      ),
                      // 채워지는 바
                      AnimatedBuilder(
                        animation: _fillAnimation,
                        builder: (context, child) {
                          final double ratio = _fillAnimation.value;
                          final double barWidth =
                              (ratio.clamp(0.0, maxRatio)) * center;
                          return Positioned(
                            left: 0,
                            top: 12,
                            child: Container(
                              width: barWidth,
                              height: _blockHeight,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                      // 기준 섭취량 텍스트
                      Positioned(
                        left: center - 20,
                        top: -4,
                        child: Text(
                          '${widget._intake.requiredintake.round()}${widget._intake.intakeunit}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      // 퍼센트 텍스트
                      AnimatedBuilder(
                        animation: _fillAnimation,
                        builder: (context, child) {
                          final double ratio = _fillAnimation.value;
                          final double barWidth =
                              (ratio.clamp(0.0, maxRatio)) * center;
                          final double textLeft =
                              barWidth < 20 ? barWidth + 4 : barWidth - 20;

                          return Positioned(
                            left: textLeft,
                            top: _blockHeight + 10,
                            child: Text(
                              '${(ratio * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
//    );
    //)
  }
}
