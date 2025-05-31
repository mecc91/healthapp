// lib/mealrecordPage/mealrecord.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthymeal/mealrecordPage/services/meal_gpt_service.dart';
import 'dart:io';       // File 클래스 사용
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:healthymeal/mealrecordPage/services/menu_analysis_service.dart'; // Refactored
import 'package:healthymeal/mealrecordPage/services/meal_data_service.dart'; // Refactored

// String constants for UI text and states
class MealRecordStrings {
  static const String appBarTitle = 'Record';
  static const String menuLabel = 'Menu';
  static const String servingLabel = 'Serving';
  static const String timeLabel = 'Time';
  static const String saveButtonText = '저장하기';
  static const String retakeTooltip = '재촬영';
  static const String cancelTooltip = '기록 취소';
  static const String editTooltip = '수정';
  static const String confirmEditTooltip = '확인';

  static const String statusAnalyzing = "분석 중...";
  static const String statusNoMenuName = "메뉴 이름 없음";
  static const String statusSelectPhotoFirst = "사진 선택 후 분석됩니다";
  static const String statusAnalysisFailed = MenuAnalysisService.defaultAnalysisError; // Use from service
  static const String statusImagePathError = MenuAnalysisService.defaultImagePathError; // Use from service


  static const String hintEditMenu = '메뉴 이름을 입력하세요';
  static const String hintAddPhoto = '음식 사진을 추가하세요';
  static const String cameraButtonText = '카메라';
  static const String galleryButtonText = '갤러리';

  static const String snackBarImageCancelled = '이미지 선택이 취소되었습니다.';
  static const String snackBarImageError = '이미지를 가져오는 중 오류 발생: ';
  static const String snackBarAnalysisError = '음식 이름 분석 중 오류 발생: ';
  static const String snackBarSaveError = '객체 파일 저장 또는 데이터 전송 중 오류 발생: ';
  static const String snackBarSaveSuccess = '데이터가 준비되었고, 객체 파일이 저장되었습니다: ';
  static const String snackBarNoPhotoToSave = '먼저 음식 사진을 선택해주세요.';
  static const String snackBarInvalidMenuNameToSave = '메뉴 이름 분석이 완료되지 않았거나 유효하지 않습니다. 확인 또는 수정 후 저장해주세요.';
}


// 음식 기록 화면 위젯 (StatefulWidget)
class MealRecord extends StatefulWidget {
  final XFile? initialImageFile;

  const MealRecord({super.key, this.initialImageFile});

  @override
  State<MealRecord> createState() => _MealRecordState();
}

class _MealRecordState extends State<MealRecord> {
  // Imgae 관련 멤버변수
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile;
  File? _storedImage;

  // 
  String? _selectedServing = '1';
  String? _selectedTime = 'Breakfast';
  final List<String> _servingOptions = ['1', '2', '3', '4', '5'];
  final List<String> _timeOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  String _menuName = '';
  bool _isAnalyzingMenu = false;
  bool _isEditingMenu = false;
  final TextEditingController _menuNameController = TextEditingController();

  // Services
  final MenuAnalysisService _menuAnalysisService = MenuAnalysisService();
  final MealDataService _mealDataService = MealDataService();
  final MealGptService _mealGptService = MealGptService();

  @override
  void initState() {
    super.initState();
    _menuNameController.text = _menuName;

    if (widget.initialImageFile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _pickedImageFile = widget.initialImageFile;
            _menuName = MealRecordStrings.statusAnalyzing;
            _menuNameController.text = _menuName;
            _isEditingMenu = false;
          });
          if (_pickedImageFile != null) {
            _analyzeImage(_pickedImageFile!.path);
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

  // 식단사진 재촬영시 호출
  Future<void> _pickImageAndAnalyze(ImageSource source) async {
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
          _menuName = MealRecordStrings.statusAnalyzing;
          _menuNameController.text = _menuName;
          _isEditingMenu = false;
        });
        await _analyzeImage(pickedFile.path);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(MealRecordStrings.snackBarImageCancelled)),
          );
        }
      }
    } catch (e) {
      print('Image picking error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${MealRecordStrings.snackBarImageError}$e')),
      );
      _resetMenuAnalysisStateOnError();
    }
  }

  // 촬영된 이미지 GPT 분석
  Future<void> _analyzeImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      _resetMenuAnalysisStateOnError(errorMessage: MealRecordStrings.statusImagePathError);
      return;
    }
    if (mounted) {
      setState(() {
        _isAnalyzingMenu = true;
        _isEditingMenu = false; // Ensure edit mode is off during analysis
      });
    }
    try {
      final File imageFile = File(imagePath);
      late String analyzedMenuName;
      _mealGptService.sendMealImage(imageFile).then((value) {
        analyzedMenuName = value;
      },);
      if (!mounted) return;
      setState(() {
        _menuName = analyzedMenuName;
        _menuNameController.text = _menuName;
        _isAnalyzingMenu = false;
      });
    } catch (e) {
      print('GPT Analysis Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${MealRecordStrings.snackBarAnalysisError}$e')),
      );
      _resetMenuAnalysisStateOnError(errorMessage: MealRecordStrings.statusAnalysisFailed);
    }
  }
  
  void _resetMenuAnalysisStateOnError({String? errorMessage}) {
    if (mounted) {
      setState(() {
        _menuName = errorMessage ?? MealRecordStrings.statusAnalysisFailed;
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
        const SnackBar(content: Text(MealRecordStrings.snackBarNoPhotoToSave)),
      );
      return;
    }

    // Validate menu name
    final currentMenuName = _isEditingMenu ? _menuNameController.text.trim() : _menuName.trim();
    if (currentMenuName.isEmpty ||
        currentMenuName == MealRecordStrings.statusAnalyzing ||
        currentMenuName == MealRecordStrings.statusAnalysisFailed ||
        currentMenuName == MealRecordStrings.statusImagePathError ||
        currentMenuName == MealRecordStrings.statusNoMenuName ||
        currentMenuName == MealRecordStrings.statusSelectPhotoFirst) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MealRecordStrings.snackBarInvalidMenuNameToSave)),
      );
      return;
    }
    
    // If in editing mode, finalize the menu name from controller
    if (_isEditingMenu) {
        _menuName = _menuNameController.text.trim();
        if (_menuName.isEmpty) _menuName = MealRecordStrings.statusNoMenuName; // Should be caught by above check
        if(mounted) setState(() => _isEditingMenu = false); // Exit editing mode
    }


    final mealRecord = MealRecordData(
      imagePath: _pickedImageFile?.path,
      menuName: _menuName, // Use the finalized _menuName
      serving: _selectedServing,
      mealTime: _selectedTime,
      timestamp: DateTime.now().toIso8601String(),
    );

    try {
      final String savedFilePath = await _mealDataService.saveMealRecord(mealRecord);
      print('--- Data to be sent (conceptually) ---');
      print('Image Path: ${mealRecord.imagePath}');
      print('Menu: ${mealRecord.menuName}');
      print('Serving: ${mealRecord.serving}');
      print('Time: ${mealRecord.mealTime}');
      print('Timestamp: ${mealRecord.timestamp}');
      print('Object Data (JSON): ${jsonEncode(mealRecord.toJson())}');
      print('----------------------');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${MealRecordStrings.snackBarSaveSuccess}$savedFilePath')),
      );
      if (mounted) {
        Navigator.of(context).pop(); // Go back to previous screen
      }
    } catch (e) {
      print('Error saving object file or sending data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${MealRecordStrings.snackBarSaveError}$e')),
      );
    }
  }

  void _toggleEditMenu() {
    if (_isAnalyzingMenu) return; // Cannot edit while analyzing

    if (mounted) {
      setState(() {
        if (_isEditingMenu) {
          // Save changes from text field
          _menuName = _menuNameController.text.trim();
          if (_menuName.isEmpty) {
            _menuName = MealRecordStrings.statusNoMenuName; // Default if empty
            _menuNameController.text = _menuName;
          }
          _isEditingMenu = false;
        } else {
          // Enter edit mode only if there's an image and menu isn't one of the placeholder/error states
          if (_pickedImageFile != null && 
              _menuName.isNotEmpty &&
              _menuName != MealRecordStrings.statusAnalyzing &&
              _menuName != MealRecordStrings.statusSelectPhotoFirst) {
            _menuNameController.text = (_menuName == MealRecordStrings.statusAnalysisFailed || _menuName == MealRecordStrings.statusImagePathError || _menuName == MealRecordStrings.statusNoMenuName) ? '' : _menuName;
            _isEditingMenu = true;
          }
        }
      });
    }
  }

  // 뒤로가기 button
  void _deleteRecordAndExit() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  bool get _canEnableSaveButton {
    if (_isAnalyzingMenu || _pickedImageFile == null) return false;
    final currentMenuName = _isEditingMenu ? _menuNameController.text.trim() : _menuName.trim();
    return currentMenuName.isNotEmpty &&
           currentMenuName != MealRecordStrings.statusAnalyzing &&
           currentMenuName != MealRecordStrings.statusAnalysisFailed &&
           currentMenuName != MealRecordStrings.statusImagePathError &&
           currentMenuName != MealRecordStrings.statusNoMenuName &&
           currentMenuName != MealRecordStrings.statusSelectPhotoFirst;
  }


  // --- UI Builder Methods ---

  Widget _buildImagePickerArea(double height) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
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
                        label: const Text(MealRecordStrings.cameraButtonText),
                        onPressed: () => _pickImageAndAnalyze(ImageSource.camera),
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
                        label: const Text(MealRecordStrings.galleryButtonText),
                        onPressed: () => _pickImageAndAnalyze(ImageSource.gallery),
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
                    MealRecordStrings.hintAddPhoto,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : Image.file(
              File(_pickedImageFile!.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
            ),
    );
  }

  Widget _buildMenuSection() {
    String displayMenuName;
    if (_menuName.isEmpty && _pickedImageFile == null) {
      displayMenuName = MealRecordStrings.statusSelectPhotoFirst;
    } else if (_menuName.isEmpty && _pickedImageFile != null && !_isAnalyzingMenu) {
      displayMenuName = MealRecordStrings.statusNoMenuName;
    } else {
      displayMenuName = _menuName;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          MealRecordStrings.menuLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.lightGreen[100]?.withAlpha(153),
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
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.teal),
                        )
                      : _isEditingMenu
                          ? TextField(
                              controller: _menuNameController,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: MealRecordStrings.hintEditMenu,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              onSubmitted: (_) => _toggleEditMenu(),
                            )
                          : Text(
                              displayMenuName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                ),
              ),
              if (_pickedImageFile != null && !_isAnalyzingMenu)
                IconButton(
                  icon: Icon(
                    _isEditingMenu ? Icons.check_circle_outline : Icons.edit_note,
                    color: _isEditingMenu ? Colors.teal : Colors.black54,
                  ),
                  onPressed: _toggleEditMenu,
                  tooltip: _isEditingMenu ? MealRecordStrings.confirmEditTooltip : MealRecordStrings.editTooltip,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownContainer(
            label: MealRecordStrings.servingLabel,
            value: _selectedServing,
            items: _servingOptions,
            onChanged: _isAnalyzingMenu
                ? null
                : (newValue) {
                    if (mounted) setState(() => _selectedServing = newValue);
                  },
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildDropdownContainer(
            label: MealRecordStrings.timeLabel,
            value: _selectedTime,
            items: _timeOptions,
            onChanged: _isAnalyzingMenu
                ? null
                : (newValue) {
                    if (mounted) setState(() => _selectedTime = newValue);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownContainer({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.lightGreen[100]?.withAlpha(153),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              items: items.map((String val) {
                return DropdownMenuItem<String>(value: val, child: Center(child: Text(val)));
              }).toList(),
              onChanged: onChanged,
              disabledHint: Center(child: Text(value ?? '', style: TextStyle(color: Colors.grey[600]))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double horizontalPadding, Size screenSize) {
     return Row(
        children: [
          Tooltip(
            message: MealRecordStrings.retakeTooltip,
            child: OutlinedButton(
              onPressed: _isAnalyzingMenu ? null : () => _pickImageAndAnalyze(ImageSource.camera),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                backgroundColor: Colors.teal.shade50,
                side: BorderSide(color: Colors.teal.shade200),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ).copyWith(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey : Colors.teal),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey.shade200 : Colors.teal.shade50),
                side: WidgetStateProperty.resolveWith<BorderSide?>((states) => states.contains(WidgetState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.teal.shade200)),
              ),
              child: const Icon(Icons.camera_alt, size: 24),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: ElevatedButton(
              onPressed: _canEnableSaveButton ? _saveData : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: Colors.orange.shade200,
                disabledForegroundColor: Colors.white70,
              ),
              child: const Text(
                MealRecordStrings.saveButtonText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Tooltip(
            message: MealRecordStrings.cancelTooltip,
            child: OutlinedButton(
              onPressed: _isAnalyzingMenu ? null : _deleteRecordAndExit, // Allow cancelling even during analysis if needed, or disable
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent.shade700,
                backgroundColor: Colors.red.shade50, // Slightly different background
                side: BorderSide(color: Colors.redAccent.shade200),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: max(15, screenSize.width * 0.04)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ).copyWith(
                 foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey : Colors.redAccent.shade700),
                 backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey.shade200 : Colors.red.shade50), // Keep the red shade50 for disabled
                 side: WidgetStateProperty.resolveWith<BorderSide?>((states) => states.contains(WidgetState.disabled) ? BorderSide(color: Colors.grey.shade300) : BorderSide(color: Colors.redAccent.shade200)),
              ),
              child: const Icon(Icons.delete_outline, size: 24),
            ),
          ),
        ],
      );
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
          onPressed: _deleteRecordAndExit,
        ),
        title: const Text(
          MealRecordStrings.appBarTitle,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            // 식단사진 & 메뉴이름 파트
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePickerArea(imageAreaHeight),
                    const SizedBox(height: 24.0),
                    _buildMenuSection(),
                    // Dropdowns will be pushed to the bottom
                  ],
                ),
              ),
            ),
          ),
          // 섭취량 & 식사시간 & 식단기록버튼 파트
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 16.0, // Space above dropdowns
              bottom: max(16.0, MediaQuery.of(context).padding.bottom + 8.0), // Safe area for bottom
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // So it doesn't expand unnecessarily
              children: [
                _buildDropdownsSection(),
                const SizedBox(height: 24.0),
                _buildActionButtons(horizontalPadding, screenSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}