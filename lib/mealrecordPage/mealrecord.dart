import 'package:flutter/material.dart';
import 'dart:io'; // File 클래스 사용
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // image_picker 패키지 임포트
import 'dart:convert'; // For JSON encoding
import 'package:path_provider/path_provider.dart'; // To get local path

// 음식 기록 화면 위젯 (StatefulWidget)
class MealRecord extends StatefulWidget {
  final XFile? initialImageFile; // Dashboard로부터 이미지를 받기 위한 파라미터

  const MealRecord({super.key, this.initialImageFile}); // 생성자 수정

  @override
  State<MealRecord> createState() => _MealRecordState();
}

// FoodRecordScreen 위젯의 상태 관리 클래스
class _MealRecordState extends State<MealRecord> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile; // 선택/촬영된 이미지 파일

  String? _selectedServing = '1';
  String? _selectedTime = 'Breakfast';
  final List<String> _servingOptions = ['1', '2', '3', '4', '5'];
  final List<String> _timeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  String _menuName = '';
  bool _isAnalyzingMenu = false;
  bool _isEditingMenu = false;
  final TextEditingController _menuNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _menuNameController.text = _menuName;

    if (widget.initialImageFile != null) {
      // 위젯이 빌드된 후에 setState를 호출하도록 함
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // 위젯이 여전히 마운트되어 있는지 확인
          setState(() {
            _pickedImageFile = widget.initialImageFile;
            _menuName = "분석 중..."; // 분석 시작 메시지
            _menuNameController.text = _menuName;
            _isEditingMenu = false; // 편집 모드 해제
          });
          // 전달받은 이미지로 GPT 분석 시작
          if (_pickedImageFile != null) { // null 체크 추가
            _analyzeImageWithGPT(_pickedImageFile!.path);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
     if (_isAnalyzingMenu) return;

     try {
       final XFile? pickedFile = await _picker.pickImage(
         source: source,
         imageQuality: 80,
         maxWidth: 1000,
       );

       if (pickedFile != null) {
         if (!mounted) return;
         setState(() {
           _pickedImageFile = pickedFile;
           _menuName = "분석 중...";
           _menuNameController.text = _menuName;
           _isEditingMenu = false;
         });
         await _analyzeImageWithGPT(pickedFile.path);
       } else {
         print('이미지가 선택되지 않았습니다.');
       }
     } catch (e) {
       print('이미지 선택 오류: $e');
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('이미지를 가져오는 중 오류 발생: $e')),
       );
       setState(() {
         _menuName = "";
         _menuNameController.text = _menuName;
         // 분석 중 상태도 초기화
         _isAnalyzingMenu = false;
       });
     }
   }


  Future<void> _analyzeImageWithGPT(String imagePath) async {
    // imagePath가 null이거나 비어있는 경우를 대비 (실제로는 _pickedImageFile.path에서 오므로 null 가능성은 낮음)
    if (imagePath.isEmpty) {
      if (mounted) {
        setState(() {
          _menuName = "이미지 경로 없음";
          _menuNameController.text = _menuName;
          _isAnalyzingMenu = false;
        });
      }
      return;
    }

    setState(() {
      _isAnalyzingMenu = true;
      // _menuName = '분석 중...'; // 이미 _pickImage 또는 initState에서 설정됨
      // _menuNameController.text = _menuName;
      _isEditingMenu = false;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션
      final String analyzedMenuName = "오므라이스 (분석됨)";

      if (!mounted) return;
      setState(() {
        _menuName = analyzedMenuName;
        _menuNameController.text = _menuName;
        _isAnalyzingMenu = false;
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

  Future<void> _saveData() async {
    if (_isAnalyzingMenu) return;
    if (_pickedImageFile == null) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('먼저 음식 사진을 선택해주세요.')),
       );
       return;
    }

    if (_menuName.isNotEmpty && _menuName != "분석 실패" && _menuName != "분석 중..." && _menuName != "이미지 경로 없음" && _menuName != "이미지 없음") {
        // 데이터 객체 생성
        Map<String, dynamic> mealDataObject = {
          'imagePath': _pickedImageFile?.path,
          'menuName': _menuName,
          'serving': _selectedServing,
          'time': _selectedTime,
          'timestamp': DateTime.now().toIso8601String(), // 데이터 생성 시각 추가 (선택 사항)
        };

        // 객체를 JSON 문자열로 변환
        String jsonData = jsonEncode(mealDataObject);

        try {
          // 로컬 경로 가져오기
          final directory = await getApplicationDocumentsDirectory();
          final path = directory.path;
          // 파일 이름에 현재 시간을 포함시켜 고유하게 만듦 (선택 사항)
          // final fileName = 'meal_data_${DateTime.now().millisecondsSinceEpoch}.json';
          final file = File('$path/meal_data.json');

          // JSON 문자열을 파일에 쓰기
          await file.writeAsString(jsonData);
          print('Object file created at: ${file.path}'); // 콘솔에 파일 경로 출력

          // 기존 데이터 전송 로직 (실제 전송 시 이 부분에 API 호출 코드 작성)
          print('--- 데이터 전송 준비 ---');
          print('Image Path: ${_pickedImageFile?.path}');
          print('Menu: $_menuName');
          print('Serving: $_selectedServing');
          print('Time: $_selectedTime');
          print('Object Data: $jsonData'); // 저장된 JSON 데이터도 출력
          print('----------------------');

          // TODO: 실제 백엔드 API로 데이터(mealDataObject 또는 jsonData) 전송 로직 구현
          // 예: await http.post(Uri.parse('YOUR_API_ENDPOINT'), body: jsonData, headers: {'Content-Type': 'application/json'});

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터가 준비되었고, 객체 파일이 저장되었습니다: ${file.path}')),
          );
          if(mounted) Navigator.of(context).pop(); // 저장 후 이전 화면으로 돌아가기

        } catch (e) {
          print('Error saving object file or sending data: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('객체 파일 저장 또는 데이터 전송 중 오류 발생: $e')),
          );
        }

    } else {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('메뉴 이름 분석이 완료되지 않았거나 유효하지 않습니다. 확인 또는 수정 후 저장해주세요.')),
       );
    }
  }

  void _clearSelection() {
    if (_isAnalyzingMenu) return;
    setState(() {
      _pickedImageFile = null;
      _menuName = '';
      _menuNameController.text = '';
      _isEditingMenu = false;
    });
  }

  void _toggleEditMenu() {
    if (_isAnalyzingMenu) return;

    setState(() {
      if (_isEditingMenu) {
        _menuName = _menuNameController.text.trim();
        if (_menuName.isEmpty){
           _menuName = "메뉴 이름 없음"; // 비어있으면 기본값 설정
           _menuNameController.text = _menuName;
        }
        _isEditingMenu = false;
      } else {
        if (_pickedImageFile != null) { // 이미지가 있을 때만 편집 모드 진입
           _isEditingMenu = true;
        }
      }
    });
  }


  void _cancelAndGoBack() {
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = max(16.0, screenSize.width * 0.04);
    final imageAreaHeight = screenSize.height * 0.4;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelAndGoBack,
        ),
        title: const Text(
          'Record',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
         backgroundColor: Colors.white,
         foregroundColor: Colors.black,
         elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: imageAreaHeight,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                           color: Colors.grey[200],
                           borderRadius: BorderRadius.circular(12.0),
                           border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: _pickedImageFile == null
                            ? Center(
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
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.photo_library),
                                          label: const Text('갤러리'),
                                          onPressed: () => _pickImage(ImageSource.gallery),
                                           style: ElevatedButton.styleFrom(
                                               backgroundColor: Colors.indigo,
                                               foregroundColor: Colors.white,
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            : Image.file(
                                File(_pickedImageFile!.path), // XFile의 path를 사용하여 File 객체 생성
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: imageAreaHeight,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Menu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[100]?.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: _isAnalyzingMenu
                                  ? const SizedBox(
                                      height: 24, width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.teal),
                                    )
                                  : _isEditingMenu
                                      ? TextField(
                                          controller: _menuNameController,
                                          textAlign: TextAlign.center,
                                          autofocus: true,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          decoration: const InputDecoration(
                                            isDense: true, hintText: '메뉴 이름을 입력하세요',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(vertical: 8.0)
                                          ),
                                          onSubmitted: (_) => _toggleEditMenu(),
                                        )
                                      : Text(
                                          _menuName.isEmpty && _pickedImageFile == null
                                              ? '사진 선택 후 분석됩니다'
                                              : _menuName.isEmpty && _pickedImageFile != null && !_isAnalyzingMenu
                                                  ? '메뉴 이름 없음' // 분석 후 이름 없는 경우 또는 직접 입력하지 않은 경우
                                                  : _menuName,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                            ),
                          ),
                          if (_pickedImageFile != null && !_isAnalyzingMenu)
                             IconButton(
                               icon: Icon(_isEditingMenu ? Icons.check_circle_outline : Icons.edit_note,
                                          color: _isEditingMenu ? Colors.teal : Colors.black54),
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
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding, right: horizontalPadding,
              top: 16.0, bottom: max(16.0, MediaQuery.of(context).padding.bottom + 8.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
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
                                onChanged: _isAnalyzingMenu ? null : (newValue) {
                                  setState(() { _selectedServing = newValue; });
                                },
                                disabledHint: Center(child: Text(_selectedServing ?? '', style: TextStyle(color: Colors.grey[600]))),
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
                                onChanged: _isAnalyzingMenu ? null : (newValue) {
                                   setState(() { _selectedTime = newValue; });
                                },
                                disabledHint: Center(child: Text(_selectedTime ?? '', style: TextStyle(color: Colors.grey[600]))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Tooltip(
                      message: '초기화',
                      child: OutlinedButton(
                        onPressed: _pickedImageFile != null && !_isAnalyzingMenu ? _clearSelection : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange, backgroundColor: Colors.orange.shade50,
                          side: BorderSide(color: Colors.orange.shade200),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ).copyWith(
                           foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey : Colors.orange),
                           backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.orange.shade50),
                           side: MaterialStateProperty.resolveWith<BorderSide?>((states) => states.contains(MaterialState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.orange.shade200)),
                        ),
                        child: const Icon(Icons.refresh, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !_isAnalyzingMenu && _pickedImageFile != null && _menuName.isNotEmpty && _menuName != "분석 실패" && _menuName != "분석 중..." && _menuName != "이미지 경로 없음" && _menuName != "이미지 없음"
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
                          '저장하기',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
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
                        child: const Icon(Icons.cancel_outlined, size: 24),
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