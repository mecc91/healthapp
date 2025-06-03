// lib/dailystatusPage/model/mealinfo.dart

class MealInfo {
  // 영양 정보
  final double carbonhydrate_g;
  final double protein_g;
  final double fat_g;
  final double sodium_mg;
  final double cellulose_g;
  final double sugar_g;
  final double cholesterol_mg;

  // 식사 관련 메타데이터
  final DateTime intaketime;
  final String mealtype;
  final double intakeamount; // ✅ int → double 로 수정
  final List<String> meals;
  final String imagepath;

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
    required this.intakeamount, // ✅ double
    required this.meals,
    required this.imagepath,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      carbonhydrate_g: (json['carbonhydrate_g'] as num?)?.toDouble() ?? 0.0,
      protein_g: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      fat_g: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      sodium_mg: (json['sodium_mg'] as num?)?.toDouble() ?? 0.0,
      cellulose_g: (json['cellulose_g'] as num?)?.toDouble() ?? 0.0,
      sugar_g: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      cholesterol_mg: (json['cholesterol_mg'] as num?)?.toDouble() ?? 0.0,
      intaketime: DateTime.parse(
          json['intaketime'] as String? ?? DateTime.now().toIso8601String()),
      mealtype: json['mealtype'] as String? ?? 'Unknown',
      intakeamount: (json['intakeamount'] as num?)?.toDouble() ?? 1.0,
      meals: List<String>.from(json['meals'] as List<dynamic>? ?? []),
      imagepath: json['imagepath'] as String? ?? '',
    );
  }
}
