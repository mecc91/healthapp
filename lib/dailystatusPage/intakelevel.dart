import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/dailystatus.dart';

// ignore: must_be_immutable
class IntakeLevel extends StatefulWidget {
  IntakeLevel(this._intake, {super.key}) {
    if (_intake.requiredintake < 50) {
      _totalBlocks = 12;
    } else if (_intake.requiredintake < 100) {
      _totalBlocks = 16;
    } else if (_intake.requiredintake < 500) {
      _totalBlocks = 20;
    } else {
      _totalBlocks = 24;
    }
    double ratio = _intake.intakeamount / _intake.requiredintake;
    _filledBlockNum = (ratio * _totalBlocks).round();
    if (ratio < 0.25) {
      _filledBlockColor = Colors.lightBlue;
    } else if (ratio < 0.5) {
      _filledBlockColor = Colors.lightGreen;
    } else if (ratio < 0.75) {
      _filledBlockColor = Colors.orange;
    } else {
      _filledBlockColor = Colors.red;
    }
  }


  final IntakeData _intake;

  int _totalBlocks = 0;
  int _filledBlockNum = 0;
  Color _filledBlockColor = Colors.white;

  @override
  State<IntakeLevel> createState() => _IntakeLevelState();
}

class _IntakeLevelState extends State<IntakeLevel> {
  // 섭취레벨 블럭세팅 
  final double _totalWidth = 300.0;

  //final double _emptyBlockNum;
  final double _baselineRatio = 0.8;

  final double _blockHeight = 24.0;

  final double _spacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final double blockWidth = (_totalWidth - (widget._totalBlocks - 1) * _spacing) /
        widget._totalBlocks;
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
                SizedBox(width: 25),
                Text(
                  widget._intake.nutrientname,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(
              width: _totalWidth,
              height: _blockHeight + 24 + 8, // 블럭 높이 + 수치 공간 확보
              child: Stack(
                children: [
                  // 블럭들
                  Positioned(
                    top: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        widget._totalBlocks,
                        (index) => Container(
                          width: blockWidth,
                          height: _blockHeight,
                          margin: EdgeInsets.only(
                            right: index == widget._totalBlocks - 1 ? 0 : _spacing,
                          ),
                          decoration: BoxDecoration(
                            color: index < widget._filledBlockNum
                                ? widget._filledBlockColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: index < widget._filledBlockNum
                                  ? widget._filledBlockColor
                                  : Colors.black26,
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
                    top: 10,
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
                    left: (widget._filledBlockNum * (blockWidth + _spacing) - blockWidth / 2) - 3,
                    top: _blockHeight + 4 + 8,
                    child: Text(
                      '${widget._filledBlockNum}/${widget._totalBlocks - (widget._totalBlocks / 5).round()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // 섭취량 텍스트 (채워진 끝 위치 기준)
                  Positioned(
                    top: -4,
                    child: Text(
                      '${widget._filledBlockNum}/${widget._totalBlocks - (widget._totalBlocks / 5).round()}',
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