import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/intakelevel.dart';
import 'package:healthymeal/dailystatusPage/model/mealinfo.dart';

class DailyStatus extends StatefulWidget {
  const DailyStatus({super.key});

  @override
  State<DailyStatus> createState() => _DailyStatusState();
}

class IntakeCriterion {
  const IntakeCriterion(this.carbonhydrateCriterion, this.proteinCriterion, this.fatCriterion, this.sodiumCriterion, this.celluloseCriterion, this.sugarCriterion, this.cholesterolCriterion);
  final double carbonhydrateCriterion;
  final double proteinCriterion;
  final double fatCriterion;
  final double sodiumCriterion;
  final double celluloseCriterion;
  final double sugarCriterion;
  final double cholesterolCriterion;
}

class IntakeData {
  final String nutrientname;
  final String intakeunit;
  final double requiredintake;
  final double intakeamount;
  IntakeData(this.nutrientname, this.requiredintake, this.intakeamount, this.intakeunit);
}

class _DailyStatusState extends State<DailyStatus> {

  final List<MealInfo> _meals = [
    MealInfo(10.93, 1.45, 0.24, 172, 1.2, 0, 0, 
      intaketime: DateTime(2025, 05, 12, 07, 30), 
      mealtype: "Breakfast",
      intakeamount: 1, 
      meals: ["콩나물 국밥"],
    ),
    MealInfo(20.26, 7, 7.22, 335, 1.8, 0.71, 33.45,
      intaketime: DateTime(2025, 05, 12, 12, 15),
      mealtype: "Lunch",
      intakeamount: 1,
      meals: ["참치 김밥"],
    ),
    MealInfo(25.94, 10.58, 12.29, 595, 0, 6.14, 18.43,
      intaketime: DateTime(2025, 05, 12, 18, 20),
      mealtype: "Dinner",
      intakeamount: 1,
      meals: ["맥치킨 모짜렐라 버거"],
    ),
    MealInfo(50, 4.17, 20.83, 42, 0, 41.67, 20.83,
      intaketime: DateTime(2025, 05, 12, 20, 32),
      mealtype: "Snack",
      intakeamount: 1,
      meals: ["블루베리 마카롱"],
    ),
  ];

  final List<IntakeData> _intakes = [];
  final IntakeCriterion criterion = IntakeCriterion(130, 65, 70, 1500, 30, 65, 300);

  void setIntakeLevel()
  {
    double totalcarbon=0; double totalprotein=0; double totalfat=0; double totalsodium=0; double totalcellulose=0; double totalsugar=0; double totalcholesterol=0;
    for (MealInfo meal in _meals)
    {
      totalcarbon += meal.carbonhydrate_g;
      totalprotein += meal.protein_g;
      totalfat += meal.fat_g;
      totalsodium += meal.sodium_mg;
      totalcellulose += meal.cellulose_g;
      totalsugar += meal.sugar_g;
      totalcholesterol += meal.cholesterol_mg;
    }
    setState(() {
      _intakes.clear();
      _intakes.add(IntakeData("탄수화물", criterion.carbonhydrateCriterion, totalcarbon, "g"));
      _intakes.add(IntakeData("단백질", criterion.proteinCriterion, totalprotein, "g"));
      _intakes.add(IntakeData("지방", criterion.fatCriterion, totalfat, "g"));
      _intakes.add(IntakeData("나트륨", criterion.sodiumCriterion, totalsodium, "mg"));
      _intakes.add(IntakeData("식이섬유", criterion.celluloseCriterion, totalcellulose, "g"));
      _intakes.add(IntakeData("당류", criterion.sugarCriterion, totalsugar, "g"));
      _intakes.add(IntakeData("콜레스테롤", criterion.cholesterolCriterion, totalcholesterol, "mg"));
    });
  }

  @override
  void initState() {
    super.initState();
    // _intakes 멤버 초기화
    setIntakeLevel();
  }

  @override
  Widget build(BuildContext context) {
    print("dailystatus build");
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
      body: Container(
        decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE68A), // 밝은 Amber (보통)
                  Color(0xFFC8E6C9), // 연한 Green (양호)
                  Colors.white,
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _intakes
                .map((intake) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: IntakeLevel(intake),
                    ))
                .toList(),
          ),
        ),
      ),
      //backgroundColor: Colors.white70,
    );
  }
}

