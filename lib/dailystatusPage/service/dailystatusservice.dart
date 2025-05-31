import 'dart:convert';
import 'package:healthymeal/dailystatusPage/model/mealinfo.dart';
import 'package:http/http.dart' as http;

class DailyStatusService
{
  DailyStatusService({required this.baseUrl});

  final String baseUrl;
  //final String userId;
  //final String mealInfoId;

  Future<List<MealInfo>> fetchMeals() async {
    final url = Uri.parse('$baseUrl/users/userId/meal-info/mealInfoId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => MealInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    } 
  }
}
