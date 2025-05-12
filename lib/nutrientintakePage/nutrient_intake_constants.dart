// lib/nutrientintakePage/nutrient_intake_constants.dart
import 'package:flutter/material.dart';

// Colors (Consider moving to a global app theme if used widely)
const Color kNutrientIntakePrimaryColor = Colors.teal; // Renamed to avoid conflict
const Color kNutrientIntakeGraphAccentColor = Colors.redAccent;
final Color kNutrientIntakeGraphBackgroundColor = Colors.grey.shade200;

// Data simulation settings (Could be part of a configuration service)
const int kWeeksOfDataBeforeToday = 4;
const int kWeeksOfDataAfterToday = 0;

// Nutrient Keys
const List<String> kNutrientKeys = ['Carbohydrate', 'Protein', 'Fat', 'Fiber'];

// UI Texts (Example, can be expanded)
const String kAppBarTitle = "Intake data";
const String kDefaultComment = "주간 평균 섭취량을 확인하고 식단 조절에 참고하세요. 특정 요일에 섭취량이 낮은 경향이 보일 수 있습니다.";
const String kErrorPreviousData = "더 이상 이전 데이터가 없습니다.";
const String kErrorNextData = "더 이상 다음 데이터가 없습니다.";

const List<String> kDayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];

// Graph visual constants
const double kGraphValueTextFontSize = 9.0;
const double kGraphDayTextFontSize = 9.0;
const double kGraphTextLineHeightApproximation = kGraphValueTextFontSize * 1.7;
const double kGraphTopSizedBoxHeight = 1.0;
const double kGraphBottomSizedBoxHeight = 1.0;
const double kGraphContainerVerticalPadding = 5.0 * 2;