import 'dart:convert'; // JSON 디코딩을 위해
import 'package:healthymeal/dailystatusPage/model/mealinfo.dart'; // 식사 정보 모델
import 'package:http/http.dart' as http; // HTTP 요청

class DailyStatusService {
  final String baseUrl; // API 기본 URL
  // final String userId; // 특정 사용자의 데이터를 가져오기 위한 ID (현재 미사용)
  // final String date; // 특정 날짜의 데이터를 가져오기 위한 날짜 문자열 (현재 미사용, 예: 'yyyy-MM-dd')

  // 생성자에서 baseUrl을 필수로 받도록 수정
  DailyStatusService({required this.baseUrl});

  // 특정 사용자의 특정 날짜 또는 특정 식사 정보를 가져오는 함수 (API 설계에 따라 수정 필요)
  // 현재는 userId와 mealInfoId가 URL 경로에 하드코딩된 형태로 되어 있어 실제 동작하지 않을 가능성이 높습니다.
  Future<List<MealInfo>> fetchMeals({String? userId, String? date}) async {
    // TODO: API 엔드포인트 및 파라미터 전달 방식을 실제 API 스펙에 맞게 수정해야 합니다.
    // 예시: 특정 사용자의 특정 날짜 식사 목록을 가져오는 경우
    // final url = Uri.parse('$baseUrl/users/${userId ?? "defaultUser"}/meal-info?date=${date ?? "today"}');
    // 아래 URL은 제공된 코드의 형식을 따르지만, 실제 API와 다를 수 있습니다.
    final String effectiveUserId = userId ?? "userId"; // userId가 null이면 "userId" 문자열 사용 (실제로는 오류 처리 또는 기본값 사용)
    final String effectiveMealInfoId = "mealInfoId"; // 이 부분도 동적으로 받아야 함

    final url = Uri.parse('$baseUrl/users/$effectiveUserId/meal-info/$effectiveMealInfoId');
    print('일일 상태 서비스 - 데이터 요청 URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 한글 깨짐 방지
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => MealInfo.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        // 서버에서 오류 응답을 받은 경우
        print('식사 정보 로드 실패 - 상태 코드: ${response.statusCode}, 응답: ${response.body}');
        throw Exception('식사 정보를 불러오는데 실패했습니다 (상태 코드: ${response.statusCode})');
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 발생 시
      print('식사 정보 로드 중 예외 발생: $e');
      throw Exception('식사 정보 로드 중 오류 발생: $e');
    }
  }
}
