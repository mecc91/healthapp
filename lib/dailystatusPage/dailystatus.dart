import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/intakelevel.dart';

class DailyStatus extends StatefulWidget {
  const DailyStatus({super.key});

  @override
  State<DailyStatus> createState() => _DailyStatusState();
}

class IntakeData {
  final String name;
  final int totalBlocks;
  final int emptyBlockNum;
  final int filledBlockNum;
  final Color color;
  const IntakeData(this.name, this.totalBlocks, this.emptyBlockNum, this.filledBlockNum, this.color);
}

class _DailyStatusState extends State<DailyStatus> {

  final List<IntakeData> _intakes = [
    IntakeData('탄수화물', 20, 0, 1, Color.fromARGB(255, 255, 152, 0)),
    IntakeData('단백질', 12, 0, 9, Color.fromARGB(255, 76, 175, 86)),
    IntakeData('지방', 16, 0, 11, Colors.lightGreen),
    IntakeData('나트륨', 20, 0, 12, Colors.orange),
    IntakeData('식이섬유', 14, 0, 10, Colors.green),
    IntakeData('당류', 10, 0, 8, Colors.red),
    IntakeData('콜레스테롤', 16, 0, 9, Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Status',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _intakes
              .map((nutrient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: IntakeLevel(nutrient: nutrient),
                  ))
              .toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

