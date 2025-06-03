// lib/dailystatusPage/model/mealinfo.dart

// 이 모델 클래스는 특정 식사에 대한 상세 영양 정보 및 관련 메타데이터를 나타냅니다.
class MealInfo {
  // 영양 정보 (그램 또는 밀리그램 단위)
  final double carbonhydrate_g; // 탄수화물 (g)
  final double protein_g;       // 단백질 (g)
  final double fat_g;           // 지방 (g)
  final double sodium_mg;       // 나트륨 (mg)
  final double cellulose_g;     // 식이섬유 (g)
  final double sugar_g;         // 당류 (g)
  final double cholesterol_mg;  // 콜레스테롤 (mg)

  // 식사 관련 메타데이터
  final DateTime intaketime; // 섭취 시간
  final String mealtype;     // 식사 유형 (예: "Breakfast", "Lunch", "Dinner", "Snack")
  final int intakeamount;    // 섭취량 (단위는 API 스펙 또는 사용 방식에 따라 다를 수 있음, 예: 인분, 그램)
  final List<String> meals;  // 식사 메뉴 이름 목록 (예: ["콩나물 국밥"])
  final String imagepath;    // 음식 이미지 경로 (로컬 에셋 또는 네트워크 URL)

  MealInfo({
    required this.carbonhydrate_g,
    required this.protein_g,
    required this.fat_g,
    required this.sodium_mg,
    required this.cellulose_g,
    required this.sugar_g,
    required this.cholesterol_mg,
    required this.intaketime,
    required this.mealtype,
    required this.intakeamount,
    required this.meals,
    required this.imagepath,
  });

  // JSON 데이터로부터 MealInfo 객체를 생성하는 factory 생성자
  factory MealInfo.fromJson(Map<String, dynamic> json) {
    // json 으로부터 전달받는 data 정리
    double totalCarbon=0, totalProtein=0, totalFat=0, totalSodium=0, totalCellulose=0, totalSugar=0, totalCholesterol=0;
    final List<String> menuNames = [];
    // 메뉴 이미지 불러오기
    final String imageBaseUrl = 'http://152.67.196.3:4912/uploads/';
    final String imagePath = (json['imgPath'] as String? ?? '');
    final menus = json['mealInfoFoodLinks'] as List<dynamic>;
    final double menuLength = menus.length.toDouble();
    for(var data in menus) {
      final menu = data['food'];
      //print("menu : $menu & $menuLength");
      menu['carbohydrateG'] == null ? totalCarbon += 0 :
      totalCarbon += ((menu['carbohydrateG'] as num).toDouble() / menuLength);
      //print(totalCarbon);
       menu['proteinG'] == null ? totalProtein += 0 :
      totalProtein += ((menu['proteinG'] as num).toDouble() / menuLength);
      //print(totalProtein);
       menu['fatG'] == null ? totalFat += 0 :
      totalFat += ((menu['fatG'] as num).toDouble() / menuLength);
      //print(totalFat);
       menu['sodiumMg'] == null ? totalSodium += 0 :
      totalSodium += ((menu['sodiumMg'] as num).toDouble() / menuLength);
      //print(totalSodium);
       menu['celluloseG'] == null ? totalCellulose += 0 :
      totalCellulose += ((menu['celluloseG'] as num).toDouble() / menuLength);
      //print(totalCellulose);
       menu['sugarsG'] == null ? totalSugar += 0 :
      totalSugar += ((menu['sugarsG'] as num).toDouble() / menuLength);
      //print(totalSugar);
       menu['cholesterolMg'] == null ? totalCholesterol += 0 :
      totalCholesterol += ((menu['cholesterolMg'] as num).toDouble() / menuLength);
      //print(totalCholesterol);
      menuNames.add(menu['name'] as String);
    }
    //print(json['intakeAmount']);
    return MealInfo(
      carbonhydrate_g: totalCarbon,
      protein_g: totalProtein,
      fat_g: totalFat,
      sodium_mg: totalSodium,
      cellulose_g: totalCellulose,
      sugar_g: totalSugar,
      cholesterol_mg: totalCholesterol,
      // 날짜/시간 문자열을 DateTime 객체로 파싱
      intaketime: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      mealtype: "식사",
      intakeamount: json['intakeAmount'] == null ? 1 : ((json['intakeAmount']) as num).toInt(), // 기본값 설정
      // 문자열 리스트로 변환 (API 응답이 List<dynamic>일 수 있으므로 캐스팅)
      meals: menuNames,
      imagepath: imageBaseUrl + imagePath,
    );
  }
}
