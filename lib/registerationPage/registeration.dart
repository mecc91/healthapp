import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  DateTime? _selectedDate; // 선택된 생년월일
  String _gender = 'm'; // 선택된 성별 (기본값: 남자)
  bool _isLoading = false; // 로딩 상태

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _idController.dispose(); // 컨트롤러 해제
    _pwController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 사용자 회원가입 처리
  Future<void> registerUser() async {
    final id = _idController.text.trim();
    final password = _pwController.text.trim();
    // 생년월일을 'yyyy-MM-dd' 형식의 문자열로 변환
    final birthday = _selectedDate?.toIso8601String().split('T').first;

    // 필수 입력 필드 검증
    if (id.isEmpty || password.isEmpty || birthday == null) {
      if (mounted) {
        // 위젯이 여전히 마운트되어 있는지 확인
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("입력 오류"),
            content: const Text("모든 필드를 입력해주세요."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
      return;
    }

    // API 요청을 위한 URI 및 데이터 준비
    // 실제 API 엔드포인트로 수정 필요
    final uri = Uri.parse('http://152.67.196.3:4912/users');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'id': id,
      // 중요: 클라이언트에서 비밀번호를 직접 해싱하는 것은 권장되지 않습니다.
      //       서버에서 비밀번호를 받아 안전하게 해싱하고 저장해야 합니다.
      //       여기서는 'hashedPassword' 필드명으로 일반 텍스트 비밀번호를 보내고 있습니다.
      'hashedPassword': password,
      'birthday': birthday,
      'gender': _gender,
    });

    setState(() => _isLoading = true); // 로딩 상태 시작

    try {
      final response = await http.post(uri, headers: headers, body: body);
      setState(() => _isLoading = false); // 로딩 상태 종료

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 회원가입 성공
        if (mounted) {
          // 위젯이 여전히 마운트되어 있는지 확인
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("회원가입 성공"),
              content: const Text("이제 로그인할 수 있습니다."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 회원가입 화면 닫고 로그인 화면으로 돌아가기
                  },
                  child: const Text("확인"),
                )
              ],
            ),
          );
        }
      } else {
        // 회원가입 실패 (서버 오류 등)
        if (mounted) {
          // 위젯이 여전히 마운트되어 있는지 확인
          throw Exception(
              '회원가입 실패: ${response.statusCode}, 응답: ${response.body}');
        }
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      print("회원가입 오류: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        // 위젯이 여전히 마운트되어 있는지 확인
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("에러"),
            content: Text(e
                .toString()
                .replaceFirst("Exception: ", "")), // "Exception: " 부분 제거
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
    }
  }

  // DatePicker를 사용하여 생년월일 선택
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now, // 이전에 선택한 날짜가 있으면 그 날짜, 없으면 오늘
      firstDate: DateTime(1900), // 선택 가능한 가장 이른 날짜
      lastDate: now, // 선택 가능한 가장 늦은 날짜 (오늘)
      helpText: '생년월일 선택',
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
      builder: (context, child) {
        // DatePicker 테마 커스터마이징 (선택 사항)
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // 선택된 날짜 및 헤더 배경색
              onPrimary: Colors.white, // 헤더 텍스트 색상
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar 추가
        title:
            const Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // 배경 그라데이션과 어울리도록 투명 처리
        elevation: 0, // 그림자 제거
        leading: IconButton(
          // 뒤로가기 버튼
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          // 배경 그라데이션
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFDE68A), // 밝은 노란색
                Color(0xFFC8E6C9), // 연한 녹색
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              // 내용이 길어질 경우 스크롤 가능하도록
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95), // 약간 투명한 흰색 배경
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // 연한 그림자
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이디 입력 필드
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 비밀번호 입력 필드
                    TextField(
                      controller: _pwController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 생년월일 선택 필드
                    GestureDetector(
                      onTap: _pickDate, // 탭하면 DatePicker 표시
                      child: AbsorbPointer(
                        // TextField 직접 입력 방지
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '생년월일',
                            hintText: '날짜를 선택해주세요', // 초기 힌트 텍스트
                            border: const OutlineInputBorder(),
                            prefixIcon:
                                const Icon(Icons.calendar_today_outlined),
                          ),
                          // 선택된 날짜를 'yyyy-MM-dd' 형식으로 표시
                          controller: TextEditingController(
                              text: _selectedDate == null
                                  ? ''
                                  : _selectedDate!
                                      .toIso8601String()
                                      .split('T')
                                      .first),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 성별 선택 라디오 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("성별: ", style: TextStyle(fontSize: 16)),
                        Radio<String>(
                          value: 'm',
                          groupValue: _gender,
                          onChanged: (value) =>
                              setState(() => _gender = value!),
                        ),
                        const Text("남자"),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'f',
                          groupValue: _gender,
                          onChanged: (value) =>
                              setState(() => _gender = value!),
                        ),
                        const Text("여자"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 로딩 중이거나 회원가입 버튼 표시
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              minimumSize:
                                  const Size.fromHeight(48), // 버튼 높이 조절
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("회원가입",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
