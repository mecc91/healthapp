import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealGptService {
  Future<String> sendMealImage(File imageFile) async {
      String? userId;
      SharedPreferences pref = await SharedPreferences.getInstance();
      userId = pref.getString('userId');
      print('$userId로 식단사진 전송');
      final uri = Uri.parse("http://152.67.196.3:4912/users/$userId/meal-info");

      // Multipart request 생성
      final request = http.MultipartRequest("POST", uri);
      request.fields['intake_amount'] = '1';
      request.fields['diary'] = 'null';
      request.files.add(
             http.MultipartFile.fromBytes(
              'img',
              await imageFile.readAsBytes(),
              filename: basename(imageFile.path),
              contentType: MediaType('image', 'jpeg'), // 또는 'png'
          ),
      );
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
            final Map<String, dynamic> jsonData = json.decode(response.body);
            final String menu = await analyzeMeal(userId!, jsonData['id']);
            return "$menu,${jsonData['id']}";
          } else {
          return ("❌ 오류 상태 코드: ${response.statusCode} 응답 본문: ${response.body}");
        }
      } catch (e) {
        return ("⚠️ 요청 중 오류 발생: $e");
    }
  }

  Future<String> analyzeMeal(String userId, int mealId) async {
    final url = Uri.parse("http://152.67.196.3:4912/users/$userId/meal-info/$mealId/analyze");
    final response = await http.post(url);
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data[0];
      } else {
        return ("❌ 오류 상태 코드: ${response.statusCode} 응답 본문: ${response.body}");
      }
    } catch (e) {
      return ("⚠️ 지피티 요청 중 오류 발생: $e");
    }
  }

  Future<String> recordMeal(int mealId, int amount) async {
    String? userId;
    SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getString('userId');
    if (userId == 'null') {
      return "사용자를 식별할 수 없습니다";
    }
    final url = Uri.parse("http://152.67.196.3:4912/users/$userId/meal-info/$mealId")
      .replace(queryParameters: {
        'amount' : amount.toString(),
        'diary' : 'null',
    });
    final response = await http.patch(url);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return "식단기록 성공";
    } else {
      return ("⚠️ 식단기록 중 오류 발생: ${response.statusCode}, ${response.body}");
    }

  } 

  Future<String> deleteMeal(int mealId) async {
    String? userId;
    SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getString('userId');
    if (userId == 'null') {
      return "사용자를 식별할 수 없습니다";
    }
    final url = Uri.parse("http://152.67.196.3:4912/users/$userId/meal-info/$mealId");
    final response = await http.delete(url);
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return "식단삭제 성공";
    } else {
      return ("⚠️ 식단삭제 중 오류 발생: ${response.statusCode}, ${response.body}");
    }
  }

  Future<void> sendPing() async {
    final uri = Uri.parse("http://localhost:4912/ping");
    final request = http.Request("GET", uri);
    try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
            print("✅ 응답 성공: ${response.body}");
        } else {
            print("❌ 오류 상태 코드: ${response.statusCode}");
            print("응답 본문: ${response.body}");
        }
    } catch(e) {
        print("오청 중 오류 발생: $e");
    }
  }
}