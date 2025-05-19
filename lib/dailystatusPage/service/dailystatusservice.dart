import 'dart:convert';
import 'package:healthymeal/dailystatusPage/model/mealinfo.dart';
import 'package:http/http.dart' as http;

class DailyStatusService
{
  DailyStatusService({required this.baseUrl});

  final String baseUrl;

  Future<List<MealInfo>> fetchMeals() async {
    final url = Uri.parse('$baseUrl/foods');  // 실제 엔드포인트에 맞게 수정
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => MealInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    } 
  }
}
