// models/daily_intake_model.dart

// 이 파일은 API 응답을 Dart 객체로 변환하기 위한 모델입니다.
// 실제 프로젝트에서는 lib/models/ 폴더 등에 위치시키는 것이 일반적입니다.

class DailyIntake {
  final int id;
  final DateTime day;
  final int energyKcal;
  final double proteinG;
  final double fatG;
  final double carbohydrateG;
  final double sugarsG;
  final double celluloseG;
  final double sodiumMg;
  final double cholesterolMg;
  final int score;
  // 'user' 필드는 스키마에 'any'로 되어 있어, 필요에 따라 구체적인 타입으로 정의하거나
  // Map<String, dynamic>으로 처리하거나, 이 모델에서는 생략할 수 있습니다.
  // Scoreboard에서는 주로 day와 score를 사용합니다.

  DailyIntake({
    required this.id,
    required this.day,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbohydrateG,
    required this.sugarsG,
    required this.celluloseG,
    required this.sodiumMg,
    required this.cholesterolMg,
    required this.score,
  });

  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    return DailyIntake(
      id: json['id'] as int,
      day: DateTime.parse(json['day'] as String), // API 날짜 형식이 ISO 8601 이라고 가정
      energyKcal: json['energyKcal'] as int? ?? 0, // API 응답에 필드가 없을 수 있으므로 null 처리
      proteinG: (json['proteinG'] as num? ?? 0).toDouble(),
      fatG: (json['fatG'] as num? ?? 0).toDouble(),
      carbohydrateG: (json['carbohydrateG'] as num? ?? 0).toDouble(),
      sugarsG: (json['sugarsG'] as num? ?? 0).toDouble(),
      celluloseG: (json['celluloseG'] as num? ?? 0).toDouble(),
      sodiumMg: (json['sodiumMg'] as num? ?? 0).toDouble(),
      cholesterolMg: (json['cholesterolMg'] as num? ?? 0).toDouble(),
      score: json['score'] as int? ?? 0, // 점수도 null일 수 있다면 처리
    );
  }
}
