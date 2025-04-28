import 'package:flutter/material.dart';
import 'dart:io'; // File 클래스 사용
import 'dart:math';
import 'package:camera/camera.dart'; // camera 패키지 임포트
import 'package:path_provider/path_provider.dart'; // path_provider 패키지 임포트
import 'package:path/path.dart' show join; // path 패키지의 join 함수 임포트
// import 'package:http/http.dart' as http; // 실제 API 호출 시 필요

// 앱의 시작점인 main 함수
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

// 메인 애플리케이션 위젯
class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Record',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      home: FoodRecordScreen(camera: camera),
    );
  }
}

// 음식 기록 화면 위젯
class FoodRecordScreen extends StatefulWidget {
  final CameraDescription camera;
  const FoodRecordScreen({super.key, required this.camera});

  @override
  State<FoodRecordScreen> createState() => _FoodRecordScreenState();
}

// FoodRecordScreen 위젯의 상태 관리 클래스
class _FoodRecordScreenState extends State<FoodRecordScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImageFile;

  String? _selectedServing = '1';
  String? _selectedTime = 'Breakfast';
  final List<String> _servingOptions = ['1', '2', '3', '4', '5'];
  final List<String> _timeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  // --- 메뉴 관련 상태 변수 추가 ---
  String _menuName = ''; // 분석/수정된 메뉴 이름
  bool _isAnalyzingMenu = false; // GPT 분석 중 로딩 상태
  bool _isEditingMenu = false; // 메뉴 이름 직접 수정 모드 상태
  final TextEditingController _menuNameController = TextEditingController(); // 메뉴 이름 TextField 컨트롤러

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    _menuNameController.text = _menuName; // 초기 컨트롤러 텍스트 설정
  }

  @override
  void dispose() {
    _controller.dispose();
    _menuNameController.dispose(); // 컨트롤러 dispose 추가
    super.dispose();
  }

  // --- GPT API 호출 시뮬레이션 함수 ---
  Future<void> _analyzeImageWithGPT(String imagePath) async {
    setState(() {
      _isAnalyzingMenu = true; // 분석 시작, 로딩 상태 true
      _menuName = ''; // 이전 메뉴 이름 초기화
      _isEditingMenu = false; // 편집 모드 해제
    });

    try {
      // !!! 중요: 실제 GPT API 호출 로직 구현 필요 !!!
      // 예시: http.post(...) 또는 dio.post(...) 사용하여 이미지 파일을 API 엔드포인트로 전송
      // 여기서는 2초 지연으로 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // --- 시뮬레이션 결과 ---
      // 실제로는 API 응답에서 메뉴 이름을 파싱해야 함
      final String analyzedMenuName = "오므라이스 (분석됨)"; // GPT 분석 결과 예시

      setState(() {
        _menuName = analyzedMenuName; // 상태 업데이트
        _menuNameController.text = _menuName; // 컨트롤러 텍스트도 업데이트
        _isAnalyzingMenu = false; // 분석 완료, 로딩 상태 false
      });

    } catch (e) {
      print('GPT 분석 오류 (시뮬레이션): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식 이름 분석 중 오류 발생: $e')),
      );
      setState(() {
        _menuName = "분석 실패"; // 오류 발생 시
        _menuNameController.text = _menuName;
        _isAnalyzingMenu = false; // 분석 완료 (실패), 로딩 상태 false
      });
    }
  }

  // 사진 촬영 및 데이터 처리 함수
  Future<void> _takePictureAndConfirm() async {
    if (_isAnalyzingMenu) return; // 분석 중에는 촬영 방지
    if (_capturedImageFile != null) {
      // 이미 사진이 있고, 메뉴 이름도 있으면 백엔드 전송 로직 수행
      if (_menuName.isNotEmpty && _menuName != "분석 실패" && _menuName != "분석 중...") {
          // --- 백엔드 전송 준비 ---
          print('--- 데이터 전송 준비 ---');
          print('Image Path: ${_capturedImageFile?.path}');
          print('Menu: $_menuName'); // 분석/수정된 메뉴 이름 사용
          print('Serving: $_selectedServing');
          print('Time: $_selectedTime');
          print('----------------------');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터가 준비되었습니다. (백엔드 전송 구현 필요)')),
          );
          // TODO: 실제 백엔드 전송 로직 구현 (http, dio 등 사용)
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('메뉴 이름 분석이 완료되지 않았거나 실패했습니다.')),
         );
      }
      return; // 이미 처리했으므로 함수 종료
    }


    // --- 사진 촬영 및 분석 시작 ---
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedImageFile = image; // 촬영된 이미지 저장
        _menuName = "분석 중..."; // 분석 시작 메시지
        _menuNameController.text = _menuName;
      });

      // 촬영된 이미지로 GPT 분석 시작
      await _analyzeImageWithGPT(image.path);

    } catch (e) {
      print('사진 촬영 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 중 오류 발생: $e')),
      );
      setState(() {
         _menuName = ""; // 촬영 실패 시 메뉴 이름 초기화
         _menuNameController.text = _menuName;
      });
    }
  }

  // 사진 다시 찍기 함수
  void _retakePicture() {
    if (_isAnalyzingMenu) return; // 분석 중에는 다시 찍기 방지
    setState(() {
      _capturedImageFile = null; // 캡처된 이미지 초기화
      _menuName = ''; // 메뉴 이름 초기화
      _menuNameController.text = '';
      _isEditingMenu = false; // 편집 모드 해제
    });
  }

  // 메뉴 편집 모드 토글 및 저장 함수
  void _toggleEditMenu() {
    if (_isAnalyzingMenu) return; // 분석 중에는 편집 불가

    setState(() {
      if (_isEditingMenu) {
        // 편집 모드 -> 저장 및 보기 모드로 전환
        _menuName = _menuNameController.text.trim(); // TextField 값 저장
        if (_menuName.isEmpty){
           // 사용자가 빈 값으로 저장 시 분석 실패 상태로 간주하거나 기본값 설정 가능
           _menuName = "메뉴 이름 없음";
           _menuNameController.text = _menuName;
        }
        _isEditingMenu = false;
      } else {
        // 보기 모드 -> 편집 모드로 전환
        // 분석 실패 또는 이름이 없는 경우에만 편집 모드 진입 허용 (선택적)
        // if (_menuName == "분석 실패" || _menuName.isEmpty || _menuName == "메뉴 이름 없음") {
           _isEditingMenu = true;
        // } else {
        //    ScaffoldMessenger.of(context).showSnackBar(
        //      SnackBar(content: Text('분석된 메뉴 이름이 있습니다.')),
        //    );
        // }
      }
    });
  }


  // 대시보드로 돌아가기 함수
  void _goToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = max(16.0, screenSize.width * 0.04);
    final imageAreaHeight = screenSize.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Record',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // === 상단 영역 (카메라 프리뷰 또는 캡처된 이미지) ===
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === 이미지/카메라 영역 ===
                    Center(
                      child: Container(
                        height: imageAreaHeight,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                           color: Colors.black,
                           borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: _capturedImageFile == null
                            ? FutureBuilder<void>(
                                future: _initializeControllerFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return OverflowBox(
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: imageAreaHeight * _controller.value.aspectRatio,
                                          height: imageAreaHeight,
                                          child: CameraPreview(_controller),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                     return Center(child: Text('카메라 오류: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                                  }
                                  else {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                },
                              )
                            : Image.file(
                                File(_capturedImageFile!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: imageAreaHeight,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // === 메뉴 섹션 ===
                    const Text(
                      'Menu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // TextField 높이 고려 패딩 조절
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[100]?.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded( // 텍스트 또는 TextField가 공간 차지하도록
                            child: Center( // 내부 컨텐츠 중앙 정렬
                              child: _isAnalyzingMenu
                                  ? const SizedBox( // 로딩 인디케이터
                                      height: 24, // 적절한 높이 지정
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.0),
                                    )
                                  : _isEditingMenu
                                      ? TextField( // 편집 모드일 때 TextField
                                          controller: _menuNameController,
                                          textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            isDense: true, // 높이 줄이기
                                            hintText: '메뉴 이름을 입력하세요',
                                            border: InputBorder.none, // 기본 테두리 제거
                                            contentPadding: EdgeInsets.symmetric(vertical: 8.0) // 내부 패딩 조절
                                          ),
                                          // autofocus: true, // 필요시 자동 포커스
                                        )
                                      : Text( // 보기 모드일 때 Text
                                          _menuName.isEmpty && _capturedImageFile == null ? '사진 촬영 후 분석됩니다' : _menuName,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                            ),
                          ),
                          // 편집 토글 버튼 (아이콘 변경)
                          IconButton(
                            icon: Icon(
                              _isEditingMenu ? Icons.check : Icons.refresh, // 편집 중이면 체크, 아니면 리프레시
                              color: Colors.black54
                            ),
                            onPressed: _toggleEditMenu, // 편집 모드 토글 함수 연결
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === 하단 고정 영역 ===
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 16.0,
              bottom: 20.0,
            ),
            child: Column(
              children: [
                // === 서빙 수량 및 시간 섹션 ===
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Serving',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[100]?.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedServing,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                items: _servingOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(child: Text(value)),
                                  );
                                }).toList(),
                                // 사진 촬영/분석 중이 아닐 때만 변경 가능
                                onChanged: _capturedImageFile == null && !_isAnalyzingMenu ? (newValue) {
                                  setState(() {
                                    _selectedServing = newValue;
                                  });
                                } : null, // 비활성화 조건
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[100]?.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTime,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                items: _timeOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(child: Text(value)),
                                  );
                                }).toList(),
                                // 사진 촬영/분석 중이 아닐 때만 변경 가능
                                onChanged: _capturedImageFile == null && !_isAnalyzingMenu ? (newValue) {
                                   setState(() {
                                     _selectedTime = newValue;
                                   });
                                } : null, // 비활성화 조건
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // === 하단 버튼 섹션 ===
                Row(
                  children: [
                    // --- 다시 찍기 버튼 ---
                    OutlinedButton(
                      onPressed: _retakePicture,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange, backgroundColor: Colors.orange.shade50,
                        side: BorderSide(color: Colors.orange.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                      ),
                      child: const Icon(Icons.camera_alt_outlined, size: 24),
                    ),
                    const SizedBox(width: 16.0),

                    // --- 확인 버튼 (사진 촬영 또는 데이터 준비 완료) ---
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _takePictureAndConfirm, // 사진 촬영 또는 데이터 전송 준비
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          // 버튼 텍스트 변경 (사진 없으면 '촬영/분석', 있으면 '저장하기')
                          _capturedImageFile == null ? '촬영 & 분석' : '저장하기',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // --- 삭제 버튼 (대시보드로 이동) ---
                    OutlinedButton(
                      onPressed: _goToDashboard,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700, backgroundColor: Colors.grey.shade200,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                         padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                      ),
                      child: const Icon(Icons.delete_outline, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
