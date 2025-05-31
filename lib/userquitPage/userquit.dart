import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserQuitPage extends StatefulWidget {
  const UserQuitPage({super.key});

  @override
  State<UserQuitPage> createState() => _UserQuitPageState();
}

class _UserQuitPageState extends State<UserQuitPage> {
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null) {
      _showDialog("오류", "로그인 정보가 없습니다.");
      return;
    }

    final confirmed = await _confirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.delete(
        Uri.parse('http://152.67.196.3:4912/users/$id'),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await prefs.remove('userId');
        if (!mounted) return;
<<<<<<< HEAD
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
=======

        // ✅ 탈퇴 완료 다이얼로그 → 확인 누르면 로그인으로 이동
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("탈퇴 완료"),
            content: const Text("회원 탈퇴가 정상적으로 처리되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
>>>>>>> week14_kimjiwoo
      } else {
        _showDialog("탈퇴 실패", "서버 오류 (코드 ${response.statusCode})");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showDialog("에러", "네트워크 오류가 발생했습니다: $e");
    }
  }

  Future<bool> _confirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("정말 탈퇴하시겠습니까?"),
            content: const Text("회원 정보가 삭제되며 복구할 수 없습니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("탈퇴"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원 탈퇴")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "정말 탈퇴하시겠습니까?\n삭제 후 복구할 수 없습니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text("회원 탈퇴"),
                  ),
          ],
        ),
      ),
    );
  }
}
