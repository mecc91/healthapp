import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';

class IntakeLevel extends StatelessWidget {
  const IntakeLevel({super.key, required IntakeData nutrient}) : _nutrient = nutrient;

  final IntakeData _nutrient;

  final double _totalWidth = 300.0;
  // 섭취기준선 위치비율
  final double _baselineRatio = 0.8;
  final double _blockHeight = 24.0;
  final double _spacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final double blockWidth = (_totalWidth - (_nutrient.totalBlocks - 1) * _spacing) /
        _nutrient.totalBlocks;
    final double baselineLeft = _totalWidth * _baselineRatio;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
                  _nutrient.name,
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
                        _nutrient.totalBlocks,
                        (index) => Container(
                          width: blockWidth,
                          height: _blockHeight,
                          margin: EdgeInsets.only(
                            right: index == _nutrient.totalBlocks - 1 ? 0 : _spacing,
                          ),
                          decoration: BoxDecoration(
                            color: index < _nutrient.filledBlockNum
                                ? _nutrient.color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: index < _nutrient.filledBlockNum
                                  ? _nutrient.color
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
                    left: (_nutrient.filledBlockNum * (blockWidth + _spacing) - blockWidth / 2) - 3,
                    top: _blockHeight + 4 + 6,
                    child: Text(
                      '${_nutrient.filledBlockNum}/${_nutrient.totalBlocks}',
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