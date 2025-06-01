import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthymeal/userquitPage/userquit.dart'; // ✅ 추가

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with RouteAware, TickerProviderStateMixin {
  final Map<String, double> _nutritionPreferences = {
    '탄수화물': 0.0,
    '지방': 0.0,
    '단백질': 0.0,
    '식이섬유': 0.0,
    '당분': 0.0,
    '나트륨': 0.0,
  };

  Map<String, dynamic>? _userInfo;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeSectionController;
  late Animation<double> _fadeSectionAnimation;

  bool _isNutritionExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeSectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeSectionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeSectionController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0);
        fetchUserInfo();
      }
    });
  }

  Future<void> fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('userId');
      if (id == null) throw Exception("로그인된 사용자 정보가 없습니다.");

      final response =
          await http.get(Uri.parse('http://152.67.196.3:4912/users/$id'));

      if (response.statusCode == 200) {
        setState(() {
          _userInfo = json.decode(response.body);
        });
      } else {
        throw Exception('서버 응답 오류');
      }
    } catch (e) {
      print("유저 정보 가져오기 실패: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _confirmPasswordAndNavigateToQuit() async {
    final TextEditingController pwController = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("비밀번호 확인"),
        content: TextField(
          controller: pwController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '비밀번호',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final response = await http
                  .get(Uri.parse('http://152.67.196.3:4912/users/$id'));
              if (response.statusCode == 200) {
                final user = jsonDecode(response.body);
                final serverPw = user['hashedPassword'].toString().trim();
                final inputPw = pwController.text.trim();

                if (serverPw == inputPw) {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserQuitPage()),
                  );
                } else {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("비밀번호 불일치"),
                      content: Text("비밀번호가 올바르지 않습니다."),
                    ),
                  );
                }
              }
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  String getGenderLabel(String gender) {
    return gender == 'm' ? '남성' : '여성';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeSectionController.dispose();
    super.dispose();
  }

  Widget _buildSlider(String label, double value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(fontSize: 14))),
          Expanded(
            child: Slider(
              value: value,
              min: -0.5,
              max: 0.5,
              divisions: 10,
              label: "${((1 + value) * 100).toInt()}%",
              onChanged: (newValue) {
                setState(() {
                  _nutritionPreferences[label] = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNutritionSection() {
    setState(() {
      if (_isNutritionExpanded) {
        _fadeSectionController.reverse();
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isNutritionExpanded = false;
          });
        });
      } else {
        _isNutritionExpanded = true;
        _fadeSectionController.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDE68A), Color(0xFFC8E6C9), Colors.white],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const Text("Profile",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Profile Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage('assets/image/default_man.png'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _userInfo == null
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("아이디: ${_userInfo!['id']}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          Text(
                                              "생년월일: ${_userInfo!['birthday']}"),
                                          Text(
                                              "성별: ${getGenderLabel(_userInfo!['gender'])}"),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nutrition Toggle
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _toggleNutritionSection,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _isNutritionExpanded
                                  ? "Hide nutrition info"
                                  : "Change nutrition info",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nutrition Sliders
                        SizeTransition(
                          sizeFactor: _fadeSectionAnimation,
                          axisAlignment: -1.0,
                          child: _isNutritionExpanded
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("1 Portion Info: average"),
                                      const SizedBox(height: 12),
                                      ..._nutritionPreferences.entries.map(
                                          (entry) => _buildSlider(
                                              entry.key, entry.value)),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: _toggleNutritionSection,
                                          child: const Text("Save"),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 32),

                        // Logout Button
                        ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("로그아웃",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        const SizedBox(height: 12),

                        // Delete Account Button
                        ElevatedButton(
                          onPressed: _confirmPasswordAndNavigateToQuit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("회원 탈퇴",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
