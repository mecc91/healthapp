import 'package:flutter/material.dart';
import 'package:healthymeal/dailystatusPage/intakelevel.dart';
import 'package:healthymeal/dailystatusPage/model/mealinfo.dart';
import 'package:healthymeal/dailystatusPage/service/dailystatusservice.dart';

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
    MealInfo(
      carbonhydrate_g: 10.93,
      protein_g: 1.45,
      fat_g: 0.24,
      sodium_mg: 172,
      cellulose_g: 1.2,
      sugar_g: 0,
      cholesterol_mg: 0,
      intaketime: DateTime(2025, 05, 12, 07, 30),
      mealtype: "Breakfast",
      intakeamount: 1, 
      meals: ["콩나물 국밥"],
    ),
    MealInfo(
      carbonhydrate_g: 20.26, 
      protein_g: 7, 
      fat_g: 7.22, 
      sodium_mg: 335,
      cellulose_g: 1.8,
      sugar_g: 0.71,
      cholesterol_mg: 33.45,
      intaketime: DateTime(2025, 05, 12, 12, 15),
      mealtype: "Lunch",
      intakeamount: 1,
      meals: ["참치 김밥"],
    ),
    MealInfo(
      carbonhydrate_g: 25.94,
      protein_g: 10.58,
      fat_g: 12.29,
      sodium_mg: 595,
      cellulose_g: 0,
      sugar_g: 6.14,
      cholesterol_mg: 18.43,
      intaketime: DateTime(2025, 05, 12, 18, 20),
      mealtype: "Dinner",
      intakeamount: 1,
      meals: ["맥치킨 모짜렐라 버거"],
    ),
    MealInfo(
      carbonhydrate_g: 50,
      protein_g: 4.17,
      fat_g: 20.83,
      sodium_mg: 42,
      cellulose_g: 0,
      sugar_g: 41.67,
      cholesterol_mg: 20.83,
      intaketime: DateTime(2025, 05, 12, 20, 32),
      mealtype: "Snack",
      intakeamount: 1,
      meals: ["블루베리 마카롱"],
    ),
  ];
  // API Request Service
  final DailyStatusService _dailyStatusService = DailyStatusService(baseUrl: "http://152.67.196.3:4912/foods");
  
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
    // API Request 로 _meals 초기화
    /*_dailyStatusService.fetchMeals().then((meals) {
      setState(() {
        _meals = meals;
      });
    });*/
    // _intakes 멤버 초기화
    setIntakeLevel();
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _intakes
                    .map((intake) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: IntakeLevel(intake),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _meals.map((meal) => Row(
                    children: [
                      GestureDetector(
                        onTap: () => {print("clicked!")},
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            children: [
                              // 원형 이미지
                              ClipOval(
                                child: Image.asset(
                                  'assets/image/bibimbap.jpg',// 이미지 경로
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // 텍스트 정보
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.meals[0],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    meal.mealtype,
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  )).toList(),
                  /*[
                    GestureDetector(
                      onTap: () => {print("clicked!")},
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            // 원형 이미지
                            ClipOval(
                              child: Image.asset(
                                'assets/image/bibimbap.jpg',// 이미지 경로
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 텍스트 정보
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '아침식사',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '참나물',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),             
                  ],*/
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      //backgroundColor: Colors.white70,
    );
  }
}

