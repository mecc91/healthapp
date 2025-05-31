import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;

  Future<bool> loginUser(String id, String password) async {
    final url = Uri.parse('http://152.67.196.3:4912/users/${id.trim()}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);

        final serverPassword = user['hashedPassword']?.toString().trim();
        final inputPassword = password.trim();

        print("✅ 서버 비밀번호: $serverPassword");
        print("✅ 입력 비밀번호: $inputPassword");

        return serverPassword == inputPassword;
      } else {
        print("❌ 서버 응답 코드: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('❌ 로그인 오류: $e');
      return false;
    }
  }

  Future<void> saveLoginId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id); // ✅ 로그인 ID 저장
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    final success = await loginUser(id, pw);

    setState(() => _isLoading = false);

    if (success) {
      await saveLoginId(id); // ✅ 로그인 ID 저장 호출
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("로그인 실패"),
          content: const Text("아이디 또는 비밀번호가 올바르지 않습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('로그인'),
                  ),
          ],
        ),
      ),
    );
  }
}
