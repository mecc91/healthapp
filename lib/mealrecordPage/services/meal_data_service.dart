// lib/mealrecordPage/services/meal_data_service.dart
import 'dart:convert'; // JSON 인코딩/디코딩을 위해 필요
import 'dart:io'; // 파일 시스템 접근을 위해 필요
import 'package:path_provider/path_provider.dart'; // 애플리케이션 디렉토리 경로를 얻기 위해 필요

/// 식사 기록을 위한 데이터 클래스.
class MealRecordData {
  final String? imagePath; // 이미지 파일 경로 (선택 사항)
  final String menuName; // 메뉴 이름 (필수)
  final String? serving; // 섭취량 (예: "1인분", "200g") (선택 사항)
  final String? mealTime; // 식사 시간 (예: "아침", "점심", "저녁") (선택 사항)
  final String timestamp; // 기록 시간 (ISO 8601 형식의 문자열)
  final Map<String, double>? nutrients; // 영양 정보 (선택 사항, 추후 확장 가능)

  MealRecordData({
    this.imagePath,
    required this.menuName,
    this.serving,
    this.mealTime,
    required this.timestamp,
    this.nutrients,
  });

  // 객체를 JSON 맵으로 변환하는 메소드
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'menuName': menuName,
      'serving': serving,
      'time': mealTime, // JSON 키 일관성을 위해 'time' 사용 (기존 코드와 동일)
      'timestamp': timestamp,
      'nutrients': nutrients, // 제공되지 않으면 null
    };
  }

  // JSON 맵으로부터 객체를 생성하는 factory 생성자 (필요시 구현)
  // factory MealRecordData.fromJson(Map<String, dynamic> json) {
  //   return MealRecordData(
  //     imagePath: json['imagePath'],
  //     menuName: json['menuName'],
  //     serving: json['serving'],
  //     mealTime: json['time'],
  //     timestamp: json['timestamp'],
  //     nutrients: json['nutrients'] != null
  //         ? Map<String, double>.from(json['nutrients'])
  //         : null,
  //   );
  // }
}

class MealDataService {
  /// 식사 기록을 로컬 JSON 파일로 저장합니다.
  /// 저장된 파일의 경로를 반환합니다.
  Future<String> saveMealRecord(MealRecordData mealRecord) async {
    // MealRecordData 객체를 JSON 문자열로 인코딩
    final String jsonData = jsonEncode(mealRecord.toJson());
    try {
      // 애플리케이션의 문서 디렉토리 경로를 가져옴
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      // 타임스탬프를 사용하여 고유한 파일 이름 생성 (덮어쓰기 방지)
      final fileName = 'meal_data_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('$path/$fileName');

      // JSON 데이터를 파일에 씀
      await file.writeAsString(jsonData);
      print('✅ 식사 기록 저장 완료: ${file.path}');
      return file.path; // 저장된 파일 경로 반환
    } catch (e) {
      print('❌ 식사 기록 저장 중 오류 발생: $e');
      // 사용자 정의 예외를 throw 하거나 상태 객체를 반환하는 것을 고려
      throw Exception('식사 기록 저장 실패: $e');
    }
  }

  // 선택 사항: 저장된 모든 식사 기록을 불러오는 메소드 (여기서는 구현되지 않음)
  // Future<List<MealRecordData>> loadMealRecords() async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final path = directory.path;
  //     final List<MealRecordData> records = [];
  //     final dir = Directory(path);
  //     final List<FileSystemEntity> entities = await dir.list().toList();
  //
  //     for (FileSystemEntity entity in entities) {
  //       if (entity is File && entity.path.endsWith('.json') && entity.path.contains('meal_data_')) {
  //         final String jsonData = await entity.readAsString();
  //         records.add(MealRecordData.fromJson(jsonDecode(jsonData)));
  //       }
  //     }
  //     return records;
  //   } catch (e) {
  //     print('Error loading meal records: $e');
  //     return [];
  //   }
  // }

  // 선택 사항: 특정 식사 기록을 삭제하는 메소드 (여기서는 구현되지 않음)
  // Future<void> deleteMealRecord(String filePath) async {
  //   try {
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       await file.delete();
  //       print('Meal record deleted: $filePath');
  //     }
  //   } catch (e) {
  //     print('Error deleting meal record: $e');
  //     throw Exception('Failed to delete meal record: $e');
  //   }
  // }
}
