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
    _filledBlockNum = (ratio * (_totalBlocks - (_totalBlocks / 5).round())).round();
    if (ratio < 0.5) {
      _filledBlockColor = Colors.lightBlue;
    } else if (ratio < 0.8) {
      _filledBlockColor = Colors.lightGreen;
    } else if (ratio < 0.9) {
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
    final double intakeLevel = (widget._filledBlockNum * (blockWidth + _spacing) - blockWidth / 2);

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
                // 영양소 텍스트
                Text(
                  widget._intake.nutrientname,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 5),
                // 섭취량 텍스트
                Text(
                  '${widget._intake.intakeamount.round()}${widget._intake.intakeunit} 섭취',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(
              width: _totalWidth,
              height: _blockHeight + 24 + 8, // 블럭 높이 + 수치 공간 확보
              child: Stack(
                children: [
                  // 가로막대 그래프
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: _blockHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black26, width: 2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget._totalBlocks == 0
                            ? 0
                            : widget._filledBlockNum / widget._totalBlocks,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget._filledBlockColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 기준선
                  Positioned(
                    left: baselineLeft - 2,
                    top: 12,
                    bottom: 20,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 섭취기준 텍스트 (채워진 끝 위치 기준)
                  Positioned(
                    left: baselineLeft - 14,
                    top : -4,
                    child: Text(
                      '${widget._intake.requiredintake.round()}${widget._intake.intakeunit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // 수치 텍스트 (채워진 끝 위치 기준)
                  Positioned(
                    //left: (widget._filledBlockNum * (blockWidth + _spacing) - blockWidth / 2) - 4,
                    //left: 0,
                    //left: (widget._filledBlockNum * (blockWidth + _spacing) - blockWidth / 2),
                    left: 
                      intakeLevel <= 5 ? 0
                        : intakeLevel < 265 ? intakeLevel - 5 : 265,
                    top: _blockHeight + 4 + 10,
                    child: Text(
                      '${((widget._filledBlockNum)/(widget._totalBlocks - (widget._totalBlocks / 5).round())*100).round()}%',
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