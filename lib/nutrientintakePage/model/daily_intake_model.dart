// lib/nutrientintakePage/models/daily_intake_model.dart

// kNutrientApiFieldMap을 사용하기 위해 constants 파일을 import 합니다.
import '../nutrient_intake_constants.dart';

class DailyIntake {
  final String id;
  final DateTime day;
  final int? energyKcal;
  final double? proteinG;
  final double? fatG;
  final double? carbohydrateG;
  final double? sugarsG;
  final double? celluloseG; // 섬유질
  final double? sodiumMg;
  final double? cholesterolMg;
  final int score; // 이 값을 그래프에 사용

  DailyIntake({
    required this.id,
    required this.day,
    this.energyKcal,
    this.proteinG,
    this.fatG,
    this.carbohydrateG,
    this.sugarsG,
    this.celluloseG,
    this.sodiumMg,
    this.cholesterolMg,
    required this.score,
  });

  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    return DailyIntake(
      // API 응답의 ID 타입이 불확실하면 (숫자 또는 문자열), 안전하게 문자열로 처리
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      day: DateTime.parse(json['day'] as String),
      energyKcal: json['energyKcal'] as int?,
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      carbohydrateG: (json['carbohydrateG'] as num?)?.toDouble(),
      sugarsG: (json['sugarsG'] as num?)?.toDouble(),
      celluloseG: (json['celluloseG'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
      cholesterolMg: (json['cholesterolMg'] as num?)?.toDouble(),
      score: json['score'] as int? ?? 0, // score가 null이면 0으로 처리
    );
  }

  // 특정 영양소 값을 가져오는 헬퍼 메소드
  double? getNutrientValue(String nutrientKey) {
    final fieldName = kNutrientApiFieldMap[nutrientKey];
    if (fieldName == null) return null;

    switch (fieldName) {
      case 'proteinG':
        return proteinG;
      case 'fatG':
        return fatG;
      case 'carbohydrateG':
        return carbohydrateG;
      case 'celluloseG':
        return celluloseG;
      // 다른 영양소 필드가 필요하면 여기에 추가
      // 예: case 'energyKcal': return energyKcal?.toDouble();
      default:
        return null;
    }
  }
}
