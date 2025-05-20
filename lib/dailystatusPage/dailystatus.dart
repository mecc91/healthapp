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

  // Sample meal list
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
      imagepath: 'assets/image/konggukbap.jpeg',
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
      imagepath: 'assets/image/chamchigimbap.jpeg',
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
      meals: ["맥치킨 모짜버거"],
      imagepath: 'assets/image/mcchickenmozza.jpg',
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
      imagepath: 'assets/image/blueberrymacaron.jpg',
    ),
  ];
  // API Request Service
  final DailyStatusService _dailyStatusService = DailyStatusService(baseUrl: "http://152.67.196.3:4912/foods");
  
  final List<IntakeData> _intakes = []; 
  final IntakeCriterion criterion = IntakeCriterion(130, 65, 70, 1500, 30, 65, 300);

  int currentMeal = -1;
  void setIntakeLevel(List<MealInfo> meals)
  {
    double totalcarbon=0; double totalprotein=0; double totalfat=0; double totalsodium=0; double totalcellulose=0; double totalsugar=0; double totalcholesterol=0;
    for (MealInfo meal in meals)
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

  // 선택된 식단기록 정보만 그래프로 시각화
  void setMealList(int index)
  {
    print("mealsetting to $index");
    if (index == -1)
    {
      setIntakeLevel(_meals);
      currentMeal = -1;
      return;
    }
    else
    {
      setIntakeLevel([_meals[index]]);
      currentMeal = index;
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    // API Request 로 _meals 초기화
    /*_dailyStatusService.fetchMeals().then((meals) {
      // _meals 정보 가져오기
      setState(() {
        _meals = meals;
      });
    });*/
    // _intakes 멤버 초기화
    setIntakeLevel(_meals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar
      appBar: AppBar(
        title: const Text('Daily Status',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // 본문 Container
      body: Container(
        // Container 배경
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            children: [
              // IntakeLevelBar Card 위젯 -> _intakes의 7가지 영양소 섭취현황 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _intakes
                    .map((intake) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: IntakeLevel(intake),
                        ))
                    .toList(),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 전체 식단기록정보 활성화
                    GestureDetector(
                      onTap: () => {setMealList(-1)},
                      child: Container(
                        width: 80,
                        height: 56,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: -1 == currentMeal ? Colors.deepOrangeAccent : Colors.black12,
                            width: 3.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "전체 식단",
                            style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Row(
                      // 기록된 식단정보 위젯들 표시 -> Clickable & 해당 식단에 대해서의 섭취량 표시
                      children: 
                        _meals.asMap().entries.map((meal) => 
                      Row(
                        children: [
                          // 기록된 식단정보 Clickable 위젯
                          GestureDetector(
                            onTap: () => {setMealList(meal.key)},
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: meal.key == currentMeal ? Colors.deepOrangeAccent : Colors.black12,
                                  width: 3.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 원형 이미지
                                  ClipOval(
                                    child: Image.asset(
                                      meal.value.imagepath,// 이미지 경로
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
                                        meal.value.meals[0],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        meal.value.mealtype,
                                        style: TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      )).toList(),
                    ),
                  ],
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

