import 'package:flutter/material.dart';
import 'dart:io'; // File 클래스 사용
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // image_picker 패키지 임포트
import 'dart:convert'; // For JSON encoding
import 'package:path_provider/path_provider.dart'; // To get local path
// DashboardPage import (필요한 경우)
// import 'package:healthymeal/dashboardPage/dashboard.dart';


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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지 선택이 취소되었습니다.')),
            );
          }
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
         _isAnalyzingMenu = false;
       });
     }
   }

  // 재촬영 또는 새로 촬영하는 함수
  Future<void> _retakePicture() async {
    if (_isAnalyzingMenu) return; // 분석 중에는 실행 방지

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, // 항상 카메라를 사용
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _pickedImageFile = pickedFile; // 새 이미지로 교체
          _menuName = "분석 중..."; // 메뉴 이름 초기화 및 분석 메시지 표시
          _menuNameController.text = _menuName;
          _isEditingMenu = false; // 편집 모드 해제
        });
        await _analyzeImageWithGPT(pickedFile.path); // 새 이미지로 분석 시작
      } else {
        // 사용자가 카메라 촬영을 취소한 경우
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진 촬영이 취소되었습니다.')),
          );
        }
      }
    } catch (e) {
      print('카메라 실행 중 오류: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라를 실행하는 중 오류 발생: $e')),
      );
      setState(() {
        // 필요한 경우 오류 발생 시 상태 초기화
        _isAnalyzingMenu = false;
      });
    }
  }


  Future<void> _analyzeImageWithGPT(String imagePath) async {
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
      _isEditingMenu = false;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션
      final String analyzedMenuName = "오므라이스 (재분석됨)"; // 예시

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
        Map<String, dynamic> mealDataObject = {
          'imagePath': _pickedImageFile?.path,
          'menuName': _menuName,
          'serving': _selectedServing,
          'time': _selectedTime,
          'timestamp': DateTime.now().toIso8601String(),
        };
        String jsonData = jsonEncode(mealDataObject);
        try {
          final directory = await getApplicationDocumentsDirectory();
          final path = directory.path;
          final file = File('$path/meal_data_${DateTime.now().millisecondsSinceEpoch}.json'); // 고유한 파일 이름
          await file.writeAsString(jsonData);
          print('Object file created at: ${file.path}');

          print('--- 데이터 전송 준비 ---');
          print('Image Path: ${_pickedImageFile?.path}');
          print('Menu: $_menuName');
          print('Serving: $_selectedServing');
          print('Time: $_selectedTime');
          print('Object Data: $jsonData');
          print('----------------------');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터가 준비되었고, 객체 파일이 저장되었습니다: ${file.path}')),
          );
          if(mounted) {
            // 저장 후 대시보드로 돌아가기 (popUntil 사용 가능)
            // 예: Navigator.of(context).popUntil((route) => route.isFirst);
            // 또는 단순히 이전 화면으로 돌아가기
            Navigator.of(context).pop();
          }

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

  // 이 함수는 이제 사용되지 않지만, 참고용으로 남겨둘 수 있습니다.
  // void _clearSelection() {
  //   if (_isAnalyzingMenu) return;
  //   setState(() {
  //     _pickedImageFile = null;
  //     _menuName = '';
  //     _menuNameController.text = '';
  //     _isEditingMenu = false;
  //   });
  // }

  void _toggleEditMenu() {
    if (_isAnalyzingMenu) return;

    setState(() {
      if (_isEditingMenu) {
        _menuName = _menuNameController.text.trim();
        if (_menuName.isEmpty){
           _menuName = "메뉴 이름 없음";
           _menuNameController.text = _menuName;
        }
        _isEditingMenu = false;
      } else {
        if (_pickedImageFile != null) {
           _isEditingMenu = true;
        }
      }
    });
  }

  // 기록 취소 및 대시보드로 돌아가기 함수
  void _deleteRecordAndExit() {
    // 현재 화면을 pop하여 이전 화면(대시보드)으로 돌아갑니다.
    // 저장 로직이 호출되지 않으므로 데이터는 "삭제" (저장되지 않음) 됩니다.
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
          onPressed: _deleteRecordAndExit, // 뒤로가기 버튼도 기록 취소와 동일하게 동작
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
                                File(_pickedImageFile!.path),
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
                                                  ? '메뉴 이름 없음'
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
                      message: '재촬영', // 툴팁 변경
                      child: OutlinedButton(
                        onPressed: _isAnalyzingMenu ? null : _retakePicture, // onPressed 변경
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal, // 아이콘 색상 변경 (예시)
                          backgroundColor: Colors.teal.shade50,
                          side: BorderSide(color: Colors.teal.shade200), // 테두리 색상 변경 (예시)
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ).copyWith(
                           foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey : Colors.teal),
                           backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.teal.shade50),
                           side: MaterialStateProperty.resolveWith<BorderSide?>((states) => states.contains(MaterialState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.teal.shade200)),
                        ),
                        child: const Icon(Icons.camera_alt, size: 24), // 아이콘 변경
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
                      message: '기록 취소', // 툴팁 변경
                      child: OutlinedButton(
                        onPressed: _deleteRecordAndExit, // onPressed 변경
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade700, // 아이콘 색상 변경 (예시)
                          backgroundColor: Colors.redAccent.shade200,
                          side: BorderSide(color: Colors.redAccent.shade200), // 테두리 색상 변경 (예시)
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ).copyWith(
                           foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey : Colors.redAccent.shade700),
                           backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.orange.shade50),
                           side: MaterialStateProperty.resolveWith<BorderSide?>((states) => states.contains(MaterialState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.redAccent.shade200)),
                        ),
                        child: const Icon(Icons.delete_outline, size: 24), // 아이콘 변경
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