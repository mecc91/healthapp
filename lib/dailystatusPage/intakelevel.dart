import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';

class IntakeLevel extends StatelessWidget {
  IntakeLevel({super.key, required IntakeData intake}) 
    : _intake = intake, 
    _totalBlocks = intake.requiredintake > 500 ? 20 : 12,
    _filledBlockNum = 4,
    _emptyBlockNum = 0;

  final IntakeData _intake;

  // 섭취레벨 블럭세팅 
  final double _totalWidth = 300.0;
  final int _totalBlocks;
  final int _filledBlockNum;
  final int _emptyBlockNum;
  // 섭취기준선 위치비율
  final double _baselineRatio = 0.8;
  final double _blockHeight = 24.0;
  final double _spacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final double blockWidth = (_totalWidth - (_totalBlocks - 1) * _spacing) /
        _totalBlocks;
    final double baselineLeft = _totalWidth * _baselineRatio;

    return Card(
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 23),
                Text(
                  _intake.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: _totalWidth,
              height: _blockHeight + 24 + 8, // 블럭 높이 + 수치 공간 확보
              child: Stack(
                children: [
                  // 블럭들
                  Positioned(
                    top: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        _totalBlocks,
                        (index) => Container(
                          width: blockWidth,
                          height: _blockHeight,
                          margin: EdgeInsets.only(
                            right: index == _totalBlocks - 1 ? 0 : _spacing,
                          ),
                          decoration: BoxDecoration(
                            color: index < _filledBlockNum
                                ? _intake.color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: index < _filledBlockNum
                                  ? _intake.color
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 기준선
                  Positioned(
                    left: baselineLeft - 2,
                    top: 8,
                    bottom: 24,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 수치 텍스트 (채워진 끝 위치 기준)
                  Positioned(
                    left: (_filledBlockNum * (blockWidth + _spacing) - blockWidth / 2) - 3,
                    top: _blockHeight + 4 + 6,
                    child: Text(
                      '$_filledBlockNum/$_totalBlocks',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}