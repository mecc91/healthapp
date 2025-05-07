import 'package:flutter/material.dart';
import 'dart:io'; // File 클래스 사용
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // image_picker 패키지 임포트
// import 'package:http/http.dart' as http; // 실제 API 호출 시 필요

// main 함수와 MyApp 클래스 제거됨

// 음식 기록 화면 위젯 (StatefulWidget)
class MealRecord extends StatefulWidget {
  // 카메라 관련 코드가 생성자에 있었다면 제거됨
  const MealRecord({super.key}); // 기본 생성자 유지

  @override
  State<MealRecord> createState() => _MealRecordState();
}

// FoodRecordScreen 위젯의 상태 관리 클래스
class _MealRecordState extends State<MealRecord> {
  // CameraController 및 관련 Future 제거
  final ImagePicker _picker = ImagePicker(); // ImagePicker 인스턴스 생성
  XFile? _pickedImageFile; // 선택/촬영된 이미지 파일

  String? _selectedServing = '1'; // 선택된 서빙 수량 (기본값 '1')
  String? _selectedTime = 'Breakfast'; // 선택된 식사 시간 (기본값 'Breakfast')
  final List<String> _servingOptions = ['1', '2', '3', '4', '5']; // 서빙 수량 옵션
  final List<String> _timeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack']; // 식사 시간 옵션

  // --- 메뉴 관련 상태 변수 추가 ---
  String _menuName = ''; // 분석/수정된 메뉴 이름
  bool _isAnalyzingMenu = false; // GPT 분석 중 로딩 상태
  bool _isEditingMenu = false; // 메뉴 이름 직접 수정 모드 상태
  final TextEditingController _menuNameController = TextEditingController(); // 메뉴 이름 TextField 컨트롤러

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러 초기화 제거
    _menuNameController.text = _menuName; // 초기 컨트롤러 텍스트 설정
  }

  @override
  void dispose() {
    // 카메라 컨트롤러 dispose 제거
    _menuNameController.dispose(); // 메뉴 이름 컨트롤러 dispose 추가
    super.dispose();
  }

  // --- 이미지 선택 함수 (갤러리 또는 카메라) ---
  Future<void> _pickImage(ImageSource source) async {
     if (_isAnalyzingMenu) return; // 분석 중에는 이미지 선택 방지

     try {
       final XFile? pickedFile = await _picker.pickImage(
         source: source,
         imageQuality: 80, // 이미지 품질 설정 (0-100)
         maxWidth: 1000, // 최대 너비 설정 (선택적)
       );

       if (pickedFile != null) {
         // 위젯이 마운트된 상태인지 확인 후 상태 업데이트
         if (!mounted) return;
         setState(() {
           _pickedImageFile = pickedFile; // 선택된 이미지 저장
           _menuName = "분석 중..."; // 분석 시작 메시지
           _menuNameController.text = _menuName;
           _isEditingMenu = false; // 편집 모드 해제
         });
         // 선택된 이미지로 GPT 분석 시작
         await _analyzeImageWithGPT(pickedFile.path);
       } else {
         print('이미지가 선택되지 않았습니다.');
       }
     } catch (e) {
       print('이미지 선택 오류: $e');
       // 위젯이 마운트된 상태인지 확인 후 스낵바 표시
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('이미지를 가져오는 중 오류 발생: $e')),
       );
       setState(() {
         _menuName = ""; // 오류 시 메뉴 이름 초기화
         _menuNameController.text = _menuName;
       });
     }
   }


  // --- GPT API 호출 시뮬레이션 함수 (기존과 동일) ---
  Future<void> _analyzeImageWithGPT(String imagePath) async {
    setState(() {
      _isAnalyzingMenu = true; // 분석 시작, 로딩 상태 true
      // _menuName = '분석 중...'; // 이미 _pickImage에서 설정됨
      // _menuNameController.text = _menuName;
      _isEditingMenu = false; // 편집 모드 해제
    });

    try {
      // !!! 중요: 실제 GPT API 호출 로직 구현 필요 !!!
      await Future.delayed(const Duration(seconds: 2)); // 2초 지연 시뮬레이션
      final String analyzedMenuName = "오므라이스 (분석됨)"; // GPT 분석 결과 예시

      if (!mounted) return;
      setState(() {
        _menuName = analyzedMenuName;
        _menuNameController.text = _menuName;
        _isAnalyzingMenu = false; // 분석 완료
      });

    } catch (e) {
      print('GPT 분석 오류 (시뮬레이션): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음식 이름 분석 중 오류 발생: $e')),
      );
      setState(() {
        _menuName = "분석 실패";
        _menuNameController.text = _menuName;
        _isAnalyzingMenu = false;
      });
    }
  }

  // --- 데이터 저장 함수 (기존 _takePictureAndConfirm 역할 일부) ---
  Future<void> _saveData() async {
    if (_isAnalyzingMenu) return; // 분석 중에는 저장 방지
    if (_pickedImageFile == null) { // 이미지가 없으면 저장 불가
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('먼저 음식 사진을 선택해주세요.')),
       );
       return;
    }

    // 메뉴 이름 유효성 검사
    if (_menuName.isNotEmpty && _menuName != "분석 실패" && _menuName != "분석 중...") {
        // --- 백엔드 전송 준비 ---
        print('--- 데이터 전송 준비 ---');
        print('Image Path: ${_pickedImageFile?.path}');
        print('Menu: $_menuName');
        print('Serving: $_selectedServing');
        print('Time: $_selectedTime');
        print('----------------------');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터가 준비되었습니다. (백엔드 전송 구현 필요)')),
        );
        // TODO: 실제 백엔드 전송 로직 구현

        // 예시: 전송 후 초기 상태로 돌아가기 또는 이전 화면으로 돌아가기
        // _clearSelection();
        if(mounted) Navigator.of(context).pop(); // 저장 후 이전 화면(대시보드)으로 돌아가기

    } else {
       // 메뉴 이름이 유효하지 않을 경우 사용자에게 알림
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('메뉴 이름 분석이 완료되지 않았거나 실패했습니다. 확인 또는 수정 후 저장해주세요.')),
       );
    }
  }

  // --- 선택 초기화 함수 (기존 _retakePicture 역할) ---
  void _clearSelection() {
    if (_isAnalyzingMenu) return; // 분석 중에는 초기화 방지
    setState(() {
      _pickedImageFile = null; // 선택된 이미지 초기화
      _menuName = ''; // 메뉴 이름 초기화
      _menuNameController.text = ''; // 컨트롤러 텍스트 초기화
      _isEditingMenu = false; // 편집 모드 해제
      // 드롭다운 기본값으로 리셋 (선택적)
      // _selectedServing = '1';
      // _selectedTime = 'Breakfast';
    });
  }

  // 메뉴 편집 모드 토글 및 저장 함수 (기존과 동일)
  void _toggleEditMenu() {
    if (_isAnalyzingMenu) return; // 분석 중에는 편집 불가

    setState(() {
      if (_isEditingMenu) {
        // 편집 모드 -> 저장 및 보기 모드로 전환
        _menuName = _menuNameController.text.trim(); // TextField 값 저장 (양 끝 공백 제거)
        if (_menuName.isEmpty){
           _menuName = "메뉴 이름 없음"; // 비어있으면 기본값 설정
           _menuNameController.text = _menuName;
        }
        _isEditingMenu = false; // 보기 모드로 전환
      } else {
        // 보기 모드 -> 편집 모드로 전환
        // 이미지가 선택되었을 때만 편집 가능하도록 수정 (초기 상태에서는 편집 버튼 안 보이게 함)
        if (_pickedImageFile != null) {
           _isEditingMenu = true;
           // TextField에 현재 메뉴 이름으로 포커스 (선택적)
           // FocusScope.of(context).requestFocus(FocusNode()); // 포커스 필요 시
        }
      }
    });
  }


  // 대시보드로 돌아가기 함수 (이제 취소 버튼 역할)
  void _cancelAndGoBack() {
    // 단순히 현재 화면을 닫아 이전 화면(대시보드)으로 돌아감
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // 화면 크기 정보
    final horizontalPadding = max(16.0, screenSize.width * 0.04);
    // 이미지 영역 높이 조절 (카메라 프리뷰보다 작게 설정 가능)
    final imageAreaHeight = screenSize.height * 0.4; // 높이 40%로 조절

    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // 뒤로가기 버튼 (자동으로 생성되지만 명시적으로 추가해도 무방)
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelAndGoBack, // 취소 함수 연결
        ),
        title: const Text(
          'Record', // 앱 바 제목
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // 제목 중앙 정렬
         backgroundColor: Colors.white, // AppBar 배경색 통일
         foregroundColor: Colors.black, // AppBar 전경색 통일
         elevation: 0, // AppBar 그림자 제거
      ),
      body: Column( // 세로 방향 레이아웃
        children: [
          // === 상단 영역 (선택된 이미지 또는 이미지 선택 버튼) ===
          Expanded( // 남은 공간을 모두 차지
            child: SingleChildScrollView( // 내용이 길어지면 스크롤 가능하도록
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0), // 좌우, 상하 패딩
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯들을 왼쪽 정렬
                  children: [
                    // === 이미지 선택/표시 영역 ===
                    Center( // 가운데 정렬
                      child: Container(
                        height: imageAreaHeight, // 조절된 높이
                        width: double.infinity, // 너비 최대로
                        clipBehavior: Clip.antiAlias, // 내용이 넘칠 경우 잘라내기
                        decoration: BoxDecoration( // 컨테이너 스타일
                           color: Colors.grey[200], // 배경색
                           borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                           border: Border.all(color: Colors.grey.shade300) // 테두리 추가
                        ),
                        child: _pickedImageFile == null // 선택된 이미지가 없으면
                            ? Center( // 이미지 선택 버튼 표시
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 50, color: Colors.grey[600]),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.photo_camera),
                                          label: const Text('카메라'),
                                          onPressed: () => _pickImage(ImageSource.camera),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              foregroundColor: Colors.white, // 텍스트 색상 추가
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 패딩 조절
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.photo_library),
                                          label: const Text('갤러리'),
                                          onPressed: () => _pickImage(ImageSource.gallery),
                                           style: ElevatedButton.styleFrom(
                                               backgroundColor: Colors.indigo,
                                               foregroundColor: Colors.white, // 텍스트 색상 추가
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 패딩 조절
                                           ),
                                        ),
                                      ],
                                    ),
                                     const SizedBox(height: 8),
                                     Text(
                                       '음식 사진을 추가하세요',
                                       style: TextStyle(color: Colors.grey[700])
                                     ),
                                  ],
                                ),
                              )
                            : Image.file( // 선택된 이미지가 있으면 파일로부터 이미지 표시
                                File(_pickedImageFile!.path), // 이미지 파일 경로
                                fit: BoxFit.cover, // 비율 유지하며 컨테이너 채우기
                                width: double.infinity, // 너비 최대로
                                height: imageAreaHeight, // 고정 높이
                              ),
                      ),
                    ),
                    const SizedBox(height: 24.0), // 섹션 간 간격

                    // === 메뉴 섹션 (기존과 거의 동일) ===
                    const Text(
                      'Menu', // 섹션 제목
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0), // 제목과 내용 간 간격
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 내부 패딩
                      decoration: BoxDecoration( // 컨테이너 스타일
                        color: Colors.lightGreen[100]?.withOpacity(0.6), // 연한 녹색 배경 (투명도 조절)
                        borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
                      ),
                      child: Row( // 가로 방향 레이아웃
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                        crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
                        children: [
                          Expanded( // 텍스트 또는 TextField가 남은 공간 차지하도록
                            child: Center( // 내부 컨텐츠 중앙 정렬
                              child: _isAnalyzingMenu // 분석 중 상태 확인
                                  ? const SizedBox( // 로딩 인디케이터
                                      height: 24, width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.teal), // 색상 추가
                                    )
                                  : _isEditingMenu // 편집 모드 상태 확인
                                      ? TextField( // 편집 모드일 때 TextField 표시
                                          controller: _menuNameController,
                                          textAlign: TextAlign.center,
                                          autofocus: true, // 편집 모드 시작 시 자동 포커스
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            isDense: true, hintText: '메뉴 이름을 입력하세요',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 8.0)
                                          ),
                                          onSubmitted: (_) => _toggleEditMenu(), // 엔터 키로 저장
                                        )
                                      : Text( // 보기 모드일 때 Text 표시
                                          _menuName.isEmpty && _pickedImageFile == null
                                              ? '사진 선택 후 분석됩니다' // 초기 상태
                                              : _menuName.isEmpty && _pickedImageFile != null && !_isAnalyzingMenu
                                                  ? '메뉴 이름 없음' // 분석 후 이름 없는 경우 또는 직접 입력하지 않은 경우
                                                  : _menuName, // 분석된/수정된 이름
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                            ),
                          ),
                          // 편집/저장 토글 버튼
                          // 이미지가 있고, 분석 중이 아닐 때만 표시
                          if (_pickedImageFile != null && !_isAnalyzingMenu)
                             IconButton(
                               icon: Icon(_isEditingMenu ? Icons.check_circle_outline : Icons.edit_note, // 아이콘 변경
                                          color: _isEditingMenu ? Colors.teal : Colors.black54), // 저장 아이콘 색상 변경
                               onPressed: _toggleEditMenu,
                               tooltip: _isEditingMenu ? '저장' : '수정',
                               constraints: const BoxConstraints(), padding: EdgeInsets.zero,
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
          Padding( // 하단 영역 패딩
            padding: EdgeInsets.only(
              left: horizontalPadding, right: horizontalPadding,
              top: 16.0, bottom: max(16.0, MediaQuery.of(context).padding.bottom + 8.0), // 하단 안전 영역 고려
            ),
            child: Column( // 세로 방향 레이아웃
              children: [
                // === 서빙 수량 및 시간 섹션 (드롭다운 비활성화 로직 수정) ===
                Row( // 가로 방향 레이아웃
                  children: [
                    Expanded( // Serving
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Serving', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[100]?.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedServing, isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                items: _servingOptions.map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Center(child: Text(value)));
                                }).toList(),
                                // 분석 중에는 비활성화
                                onChanged: _isAnalyzingMenu ? null : (newValue) {
                                  setState(() { _selectedServing = newValue; });
                                },
                                // 비활성화 시 힌트 텍스트 표시 (선택적)
                                disabledHint: Center(child: Text(_selectedServing ?? '', style: TextStyle(color: Colors.grey[600]))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded( // Time
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[100]?.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTime, isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                items: _timeOptions.map((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Center(child: Text(value)));
                                }).toList(),
                                // 분석 중에는 비활성화
                                onChanged: _isAnalyzingMenu ? null : (newValue) {
                                   setState(() { _selectedTime = newValue; });
                                },
                                // 비활성화 시 힌트 텍스트 표시 (선택적)
                                disabledHint: Center(child: Text(_selectedTime ?? '', style: TextStyle(color: Colors.grey[600]))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0), // 섹션 간 간격

                // === 하단 버튼 섹션 (버튼 역할 및 활성화/비활성화 로직 변경) ===
                Row( // 가로 방향 레이아웃
                  children: [
                    // --- 초기화/다시 선택 버튼 ---
                    // 이미지가 있을 때만 초기화 가능, 분석 중에는 비활성화
                    Tooltip(
                      message: '초기화',
                      child: OutlinedButton(
                        onPressed: _pickedImageFile != null && !_isAnalyzingMenu ? _clearSelection : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange, backgroundColor: Colors.orange.shade50,
                          side: BorderSide(color: Colors.orange.shade200),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ).copyWith( // 비활성화 스타일
                           foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey : Colors.orange),
                           backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey.shade200 : Colors.orange.shade50),
                           side: WidgetStateProperty.resolveWith<BorderSide?>((states) => states.contains(WidgetState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.orange.shade200)),
                        ),
                        child: Icon(Icons.refresh, size: 24), // 아이콘 고정
                      ),
                    ),
                    const SizedBox(width: 16.0), // 버튼 간 간격

                    // --- 저장하기 버튼 ---
                    Expanded( // 남은 공간 차지
                      child: ElevatedButton(
                        // 분석 중이 아니고, 이미지가 있고, 메뉴 이름이 유효할 때만 활성화
                        onPressed: !_isAnalyzingMenu && _pickedImageFile != null && _menuName.isNotEmpty && _menuName != "분석 실패" && _menuName != "분석 중..."
                            ? _saveData
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          disabledBackgroundColor: Colors.orange.shade200,
                          disabledForegroundColor: Colors.white70,
                        ),
                        child: const Text(
                          '저장하기', // 버튼 텍스트 고정
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0), // 버튼 간 간격

                    // --- 취소 버튼 (이전 화면으로 돌아가기) ---
                    Tooltip(
                      message: '취소',
                      child: OutlinedButton(
                        onPressed: _cancelAndGoBack, // 항상 활성화
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700, backgroundColor: Colors.grey.shade200,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.cancel_outlined, size: 24), // 아이콘 변경
                      ),
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