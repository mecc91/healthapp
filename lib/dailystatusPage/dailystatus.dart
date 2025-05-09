import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/intakelevel.dart';

class DailyStatus extends StatefulWidget {
  const DailyStatus({super.key});

  @override
  State<DailyStatus> createState() => _DailyStatusState();
}

class IntakeData {
  final String name;
  final int requiredintake;
  final int intakeamount;
  final Color color;
  const IntakeData(this.name, this.requiredintake, this.intakeamount, this.color);
}

class _DailyStatusState extends State<DailyStatus> {

  final List<IntakeData> _intakes = [
    IntakeData('탄수화물', 500, 300, Color.fromARGB(255, 255, 152, 0)),
    IntakeData('단백질', 200, 150, Color.fromARGB(255, 76, 175, 86)),
    IntakeData('지방', 50, 24, Colors.lightGreen),
    IntakeData('나트륨', 1000, 780, Colors.orange),
    IntakeData('식이섬유', 80, 30, Colors.green),
    IntakeData('당류', 45, 24, Colors.red),
    IntakeData('콜레스테롤', 98, 29, Colors.blue),
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
              .map((intake) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: IntakeLevel(intake: intake),
                  ))
              .toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

