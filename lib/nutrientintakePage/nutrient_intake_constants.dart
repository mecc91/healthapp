// lib/nutrientintakePage/nutrient_intake_constants.dart
import 'package:flutter/material.dart';

// Colors
const Color kNutrientIntakePrimaryColor = Colors.teal;
const Color kNutrientIntakeGraphAccentColor = Colors.redAccent; // 그래프 바 색상
final Color kNutrientIntakeGraphBackgroundColor = Colors.grey.shade200; // 그래프 배경색

// API Configuration
const String kApiBaseUrl = "http://152.67.196.3:4912/v3"; 
const String kDefaultUserId = "TestUser"; // TODO: 실제 userId는 동적으로 가져와야 합니다.

// Nutrient Keys - 코멘트 표시 등에 계속 사용될 수 있음
const List<String> kNutrientKeys = ['Carbohydrate', 'Protein', 'Fat', 'Fiber'];

// DailyIntake 스키마와 매칭되는 영양소 필드명 (실제 API 응답 필드명 기준)
// DailyIntake 모델의 getNutrientValue 메소드에서 사용됩니다.
const Map<String, String> kNutrientApiFieldMap = {
  'Carbohydrate': 'carbohydrateG',
  'Protein': 'proteinG',
  'Fat': 'fatG',
  'Fiber': 'celluloseG', // 스키마에서 celluloseG가 섬유질에 해당
  // 필요시 다른 영양소 추가 (예: 'Energy': 'energyKcal')
};


// UI Texts
const String kAppBarTitle = "섭취 데이터";
const String kDefaultComment = "선택된 영양소의 주간 평균 섭취량을 확인하고 식단 조절에 참고하세요. 일별 종합 점수는 그래프에 표시됩니다.";
const String kErrorPreviousData = "더 이상 이전 데이터가 없습니다.";
const String kErrorNextData = "더 이상 다음 데이터가 없습니다.";
const String kErrorLoadingData = "데이터를 불러오는 중 오류가 발생했습니다.";
const String kLoadingData = "데이터를 불러오는 중...";

// 주간 차트 요일 표시 (NutrientWeeklyChart에서 사용)
const List<String> kDayNames = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];

// Graph visual constants (NutrientWeeklyChart에서 사용)
const double kGraphValueTextFontSize = 9.0;
const double kGraphDayTextFontSize = 9.0;
const double kGraphTextLineHeightApproximation = kGraphValueTextFontSize * 1.7; // 텍스트 높이 근사치
const double kGraphTopSizedBoxHeight = 1.0; // 바 위쪽 여백
const double kGraphBottomSizedBoxHeight = 1.0; // 바 아래쪽 여백 (요일 텍스트 전)
const double kGraphContainerVerticalPadding = 5.0 * 2; // 그래프 컨테이너 상하 패딩

// DailyIntake 모델 클래스는 nutrientintakePage/models/daily_intake_model.dart 로 이동되었습니다.
