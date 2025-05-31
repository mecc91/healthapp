import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MealGptService {
    Future<String> sendMealImage(File imageFile) async {
        final uri = Uri.parse("http://localhost:4912/gptmeal");

        // Multipart request 생성
        final request = http.MultipartRequest("POST", uri)
        ..files.add(
                await http.MultipartFile.fromPath(
                'image',
                imageFile.path,
                contentType: MediaType('image', 'jpeg'), // 또는 'png'
            ),
        );

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ("✅ 응답 성공: ${response.body}");
    } else {
      return ("❌ 오류 상태 코드: ${response.statusCode} 응답 본문: ${response.body}");
    }
  } catch (e) {
    return ("⚠️ 요청 중 오류 발생: $e");
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