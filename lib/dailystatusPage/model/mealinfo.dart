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
    // 숫자 타입 필드는 안전하게 num으로 받고 toDouble() 또는 toInt()로 변환
    // API 응답에 해당 필드가 없을 경우를 대비하여 null 체크 및 기본값 설정 고려
    return MealInfo(
      carbonhydrate_g: (json['carbonhydrate_g'] as num?)?.toDouble() ?? 0.0,
      protein_g: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      fat_g: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      sodium_mg: (json['sodium_mg'] as num?)?.toDouble() ?? 0.0,
      cellulose_g: (json['cellulose_g'] as num?)?.toDouble() ?? 0.0,
      sugar_g: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      cholesterol_mg: (json['cholesterol_mg'] as num?)?.toDouble() ?? 0.0,
      // 날짜/시간 문자열을 DateTime 객체로 파싱
      intaketime: DateTime.parse(json['intaketime'] as String? ?? DateTime.now().toIso8601String()),
      mealtype: json['mealtype'] as String? ?? 'Unknown', // 기본값 설정
      intakeamount: json['intakeamount'] as int? ?? 1, // 기본값 설정
      // 문자열 리스트로 변환 (API 응답이 List<dynamic>일 수 있으므로 캐스팅)
      meals: List<String>.from(json['meals'] as List<dynamic>? ?? []),
      imagepath: json['imagepath'] as String? ?? '', // 기본값 설정
    );
  }

  // MealInfo 객체를 JSON으로 변환하는 메소드 (필요시 구현)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'carbonhydrate_g': carbonhydrate_g,
  //     'protein_g': protein_g,
  //     'fat_g': fat_g,
  //     'sodium_mg': sodium_mg,
  //     'cellulose_g': cellulose_g,
  //     'sugar_g': sugar_g,
  //     'cholesterol_mg': cholesterol_mg,
  //     'intaketime': intaketime.toIso8601String(),
  //     'mealtype': mealtype,
  //     'intakeamount': intakeamount,
  //     'meals': meals,
  //     'imagepath': imagepath,
  //   };
  // }
}
