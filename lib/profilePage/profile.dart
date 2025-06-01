import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청
import 'dart:convert'; // JSON 파싱
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 접근
import 'package:healthymeal/userquitPage/userquit.dart'; // 회원 탈퇴 페이지

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with RouteAware, TickerProviderStateMixin {
  // 영양 정보 선호도 (기본값 0.0, -0.5 ~ 0.5 범위)
  // TODO: 이 값들은 서버와 동기화되거나 로컬에 저장되어야 합니다.
  final Map<String, double> _nutritionPreferences = {
    '탄수화물': 0.0,
    '지방': 0.0,
    '단백질': 0.0,
    '식이섬유': 0.0,
    '당류': 0.0, // '당분'에서 '당류'로 변경 (일관성)
    '나트륨': 0.0,
  };

  Map<String, dynamic>? _userInfo; // 사용자 정보 (API로부터 로드)
  bool _isLoadingUserInfo = true; // 사용자 정보 로딩 상태
  String _userInfoError = ''; // 사용자 정보 로딩 오류 메시지

  // 애니메이션 컨트롤러
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeSectionController; // 영양 정보 섹션 페이드 애니메이션
  late Animation<double> _fadeSectionAnimation;

  bool _isNutritionExpanded = false; // 영양 정보 섹션 확장 여부

  // TODO: API 기본 URL은 상수로 관리하는 것이 좋습니다.
  final String _apiBaseUrl = 'http://152.67.196.3:4912';

  @override
  void initState() {
    super.initState();
    // 페이지 진입 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 애니메이션 속도 조정
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // 아래에서 약간 올라오는 효과
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 영양 정보 섹션 페이드 애니메이션 컨트롤러 초기화
    _fadeSectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeSectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeSectionController, curve: Curves.easeInOut),
    );

    // 위젯 빌드 후 애니메이션 시작 및 사용자 정보 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward(from: 0.0);
        _fetchUserInfo();
      }
    });
  }

  // 사용자 정보를 서버에서 가져오는 함수
  Future<void> _fetchUserInfo() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUserInfo = true;
      _userInfoError = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('userId');
      if (id == null) {
        throw Exception("로그인된 사용자 정보가 없습니다. 다시 로그인해주세요.");
      }

      final response = await http.get(Uri.parse('$_apiBaseUrl/users/$id'));

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _userInfo = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
          _isLoadingUserInfo = false;
        });
      } else {
        throw Exception('서버로부터 사용자 정보를 가져오는데 실패했습니다 (오류 코드: ${response.statusCode}).');
      }
    } catch (e) {
      print("사용자 정보 가져오기 실패: $e");
      if (mounted) {
        setState(() {
          _userInfoError = e.toString().replaceFirst("Exception: ", "");
          _isLoadingUserInfo = false;
        });
      }
    }
  }

  // 로그아웃 처리 함수
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // 저장된 사용자 ID 제거
    if (!mounted) return;
    // 로그인 화면으로 이동하고 이전 모든 화면 스택 제거
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // 회원 탈퇴를 위한 비밀번호 확인 및 탈퇴 페이지 이동 함수
  void _confirmPasswordAndNavigateToQuit() async {
    final TextEditingController pwController = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null) {
      _showErrorDialog("오류", "로그인 정보가 없어 회원 탈퇴를 진행할 수 없습니다.");
      return;
    }

    // 비밀번호 입력 다이얼로그 표시
    final String? inputPassword = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("비밀번호 확인"),
        content: TextField(
          controller: pwController,
          obscureText: true, // 비밀번호 가리기
          decoration: const InputDecoration(
            labelText: '비밀번호를 입력하세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // 취소
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, pwController.text.trim()); // 입력된 비밀번호 반환
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );

    if (inputPassword == null || inputPassword.isEmpty) return; // 비밀번호 입력 안 했으면 중단

    // 로딩 인디케이터 표시 (선택 사항)
    // setState(() => _isLoadingPasswordCheck = true);

    try {
      // 중요: 클라이언트에서 비밀번호를 직접 비교하는 것은 보안상 매우 취약합니다.
      //       반드시 서버에서 비밀번호를 검증해야 합니다.
      //       아래 코드는 데모용이며, 실제 환경에서는 서버 API를 호출하여 비밀번호를 검증해야 합니다.
      final response = await http.get(Uri.parse('$_apiBaseUrl/users/$id'));
      // setState(() => _isLoadingPasswordCheck = false);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final user = jsonDecode(utf8.decode(response.bodyBytes));
        final serverHashedPassword = user['hashedPassword']?.toString().trim();

        // TODO: 서버에서 비밀번호 검증 API를 호출하도록 변경해야 합니다.
        //       예: final bool isPasswordCorrect = await verifyPasswordOnServer(id, inputPassword);
        if (serverHashedPassword == inputPassword) { // 임시 클라이언트 측 비교
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserQuitPage()),
          );
        } else {
          _showErrorDialog("비밀번호 불일치", "입력하신 비밀번호가 올바르지 않습니다.");
        }
      } else {
        _showErrorDialog("오류", "사용자 정보 확인에 실패했습니다 (오류 코드: ${response.statusCode}).");
      }
    } catch (e) {
      // setState(() => _isLoadingPasswordCheck = false);
      if (mounted) {
        _showErrorDialog("네트워크 오류", "비밀번호 확인 중 오류가 발생했습니다: $e");
      }
    }
  }

  // 성별 코드('m' 또는 'f')를 한글 레이블로 변환
  String _getGenderLabel(String? genderCode) {
    if (genderCode == 'm') return '남성';
    if (genderCode == 'f') return '여성';
    return '알 수 없음';
  }

  // 오류 다이얼로그 표시 함수
  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
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
  void dispose() {
    _animationController.dispose();
    _fadeSectionController.dispose();
    super.dispose();
  }

  // 영양 정보 선호도 조절 슬라이더 위젯 빌드
  Widget _buildNutritionSlider(String label, double currentValue) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // 그림자 연하게
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
              width: 70, // 레이블 너비 고정
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(
            child: Slider(
              value: currentValue,
              min: -0.5, // 최소값 (-50%)
              max: 0.5, // 최대값 (+50%)
              divisions: 10, // 10단계로 조절 (0.1 단위)
              label: "${((1 + currentValue) * 100).toInt()}%", // 현재 값 퍼센트로 표시
              activeColor: Colors.teal, // 활성 슬라이더 색상
              inactiveColor: Colors.teal.withOpacity(0.3), // 비활성 슬라이더 색상
              onChanged: (newValue) {
                setState(() {
                  _nutritionPreferences[label] = newValue;
                });
              },
            ),
          ),
          SizedBox(
            width: 40, // 퍼센트 표시 너비
            child: Text(
              "${((1 + currentValue) * 100).toInt()}%",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 영양 정보 섹션 확장/축소 토글
  void _toggleNutritionSection() {
    setState(() {
      if (_isNutritionExpanded) {
        _fadeSectionController.reverse(); // 축소 애니메이션
        // 애니메이션 완료 후 _isNutritionExpanded 상태 변경 (SizeTransition이 즉시 사라지도록)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isNutritionExpanded = false;
            });
          }
        });
      } else {
        _isNutritionExpanded = true; // 먼저 확장 상태로 변경 (SizeTransition이 공간을 차지하도록)
        _fadeSectionController.forward(from: 0.0); // 확장 애니메이션
      }
    });
  }

  // TODO: 영양 정보 저장 로직 구현
  void _saveNutritionPreferences() {
    // _nutritionPreferences 맵에 있는 값을 서버로 전송하거나 로컬에 저장
    print("영양 정보 선호도 저장: $_nutritionPreferences");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("영양 정보 선호도가 (임시)저장되었습니다.")),
      );
    }
     _toggleNutritionSection(); // 저장 후 섹션 닫기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // 배경 그라데이션과 내용을 겹치기 위함
        children: [
          // 배경 그라데이션
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDE68A), Color(0xFFC8E6C9), Colors.white],
                stops: [0.0, 0.6, 1.0], // 색상 전환 지점 조정
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 상단 헤더 (뒤로가기 버튼, 타이틀)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8), // 상하 패딩 조정
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8), // 약간 투명한 배경
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2), // 그림자 위치 조정
                            )
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const Text("내 프로필",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 프로필 정보 카드
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: _isLoadingUserInfo
                            ? const Center(child: CircularProgressIndicator())
                            : _userInfoError.isNotEmpty
                                ? Center(child: Text(_userInfoError, style: const TextStyle(color: Colors.red)))
                                : Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 45, // 아바타 크기 조정
                                        // TODO: 실제 사용자 프로필 이미지 경로로 변경
                                        backgroundImage: const AssetImage('assets/image/default_man.png'),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("아이디: ${_userInfo!['id'] ?? '정보 없음'}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17)), // 폰트 크기 조정
                                            const SizedBox(height: 4),
                                            Text("생년월일: ${_userInfo!['birthday'] ?? '정보 없음'}", style: const TextStyle(fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Text("성별: ${_getGenderLabel(_userInfo!['gender'])}", style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                      const SizedBox(height: 24),

                      // 영양 정보 선호도 조절 토글 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(_isNutritionExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                          label: Text(
                            _isNutritionExpanded
                                ? "영양 정보 선호도 숨기기"
                                : "영양 정보 선호도 변경",
                            style: const TextStyle(fontSize: 15),
                          ),
                          onPressed: _toggleNutritionSection,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.teal.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // 버튼과 슬라이더 사이 간격

                      // 영양 정보 슬라이더 섹션 (애니메이션과 함께 표시/숨김)
                      SizeTransition(
                        sizeFactor: _fadeSectionAnimation, // 높이 애니메이션
                        axisAlignment: -1.0, // 위에서 아래로 확장
                        child: _isNutritionExpanded // _isNutritionExpanded가 true일 때만 내용 표시
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("각 영양소 섭취량 선호도 조절:",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const Text("(100% = 평균, 50% = 절반, 150% = 1.5배)",
                                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 12),
                                    ..._nutritionPreferences.entries.map(
                                        (entry) => _buildNutritionSlider(
                                            entry.key, entry.value)),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: _saveNutritionPreferences, // 저장 함수 호출
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text("선호도 저장"),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(), // 확장되지 않았을 때는 빈 공간
                      ),
                      const SizedBox(height: 32), // 버튼 그룹 위쪽 여백

                      // 로그아웃 버튼
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent, // 색상 변경
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

                      // 회원 탈퇴 버튼
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
                      const SizedBox(height: 20), // 하단 여백
                    ],
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
