// lib/dashboardPage/widgets/meal_diary_card.dart
import 'package:flutter/material.dart';

// 식단 항목을 위한 플레이스홀더 데이터 모델
class MealEntry {
  final String time;
  final String menu;
  final String intake;
  final String notes;
  final String imagePath; // 이미지 에셋 경로를 위한 플레이스홀더

  MealEntry({
    required this.time,
    required this.menu,
    required this.intake,
    required this.notes,
    required this.imagePath,
  });
}

class MealDiaryCard extends StatelessWidget {
  // 플레이스홀더 데이터 - 실제 앱에서는 상태 관리 솔루션이나 API로부터 가져옵니다.
  // 이미지 파일명은 실제 프로젝트의 에셋 경로에 맞게 수정해야 합니다.
  // 예시: 'assets/image/jajangmyeon.jpg', 'assets/image/chicken.jpg'
  final List<MealEntry> mealEntries = [
    MealEntry(
      time: '13:04',
      menu: '짜장면',
      intake: '600g',
      notes:
          '오늘 아침은 평소보다 따뜻하게 먹고 싶어서 동네 중국집에서 짜장면을 포장해왔다. 살짝 매콤하긴 했지만 면도 쫄깃하고 양파랑 고기도 적당히 들어있어서 만족스러웠다. 다음엔 계란 후라이 하나 올려 먹으면 더 좋을 것 같다.',
      imagePath: 'assets/image/jajangmyeon.jpg', // 실제 이미지 경로로 변경 필요
    ),
    MealEntry(
      time: '20:14',
      menu: '후라이드', // 이미지에는 치킨이 있지만, 텍스트는 짜장면으로 되어 있어 텍스트를 따름
      intake: '600g',
      notes:
          '저녁엔 친구들이랑 황금올리브 치킨을 시켜서 먹었다. 겉은 바삭하고 속은 촉촉해서 늘 먹어도 맛있다. 소스 없이도 짜지지도 않고 혼자 반 마리 정도는 충분히 먹는 느낌. 야채나 샐러드가 없어 좀 아쉽긴 했지만, 맛있게 먹었다!',
      imagePath: 'assets/image/chicken.jpg', // 실제 이미지 경로로 변경 필요
    ),
    MealEntry(
      time: '08:30',
      menu: '스크램블 에그와 토스트',
      intake: '350g',
      notes: '간단하지만 든든한 아침! 우유 한 잔과 함께.',
      imagePath: 'assets/image/toast.jpg', // 실제 이미지 경로로 변경 필요
    ),
    MealEntry(
      time: '12:15',
      menu: '김치볶음밥',
      intake: '450g',
      notes: '어제 남은 김치와 찬밥으로 만든 김치볶음밥. 계란후라이는 반숙이 진리!',
      imagePath: 'assets/image/kimchirice.jpg', // 실제 이미지 경로로 변경 필요
    ),
    MealEntry(
      time: '19:00',
      menu: '닭가슴살 샐러드',
      intake: '400g',
      notes: '가볍게 먹고 싶어서 선택한 닭가슴살 샐러드. 오리엔탈 드레싱과 함께.',
      imagePath: 'assets/image/salad.jpg', // 실제 이미지 경로로 변경 필요
    ),
    // 5개 이상 항목이 있어도 상위 5개만 표시됨
    MealEntry(
      time: '15:00',
      menu: '과일 요거트',
      intake: '200g',
      notes: '오후 간식으로 블루베리와 그래놀라를 넣은 요거트.',
      imagePath: 'assets/image/placeholder_meal_6.png', // 실제 이미지 경로로 변경 필요
    ),
  ];

  final String diaryDate; // 식단 일기 날짜
  final VoidCallback? onTap; // <<< MODIFIED: Added onTap callback

  MealDiaryCard({
    super.key,
    this.diaryDate = "날짜 정보 없음",
    this.onTap, // <<< MODIFIED: Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    // 최근 5개 항목만 표시 (또는 데이터가 5개 미만이면 그만큼만)
    final recentEntries = mealEntries.take(5).toList();

    return GestureDetector(
      // <<< MODIFIED: Wrapped with GestureDetector
      onTap: onTap, // <<< MODIFIED: Assigned onTap
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Card(
          color: const Color(0xFFFCFCFC), // 기존 카드와 유사한 배경색
          elevation: 5,
          shadowColor: Colors.grey.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // "$diaryDate 식단 일기", // 날짜를 동적으로 표시
                  "식단 일기 요약 ($diaryDate)",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 16),
                if (recentEntries.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "최근 식단 기록이 없습니다.",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true, // Column 내부에서 ListView가 올바르게 작동하도록 설정
                    physics:
                        const NeverScrollableScrollPhysics(), // ListView 자체 스크롤 비활성화
                    itemCount: recentEntries.length,
                    itemBuilder: (context, index) {
                      final entry = recentEntries[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0), // 항목 간 간격 증가
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12.0), // 이미지 모서리 둥글게
                              child: Image.asset(
                                entry.imagePath, // 동적 경로 사용
                                width: 100, // 이미지 크기 조정
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // 이미지 로드 실패 시 플레이스홀더 아이콘 표시
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu, // 식단 관련 아이콘
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16), // 이미지와 텍스트 사이 간격
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.time,
                                    style: const TextStyle(
                                      fontSize: 17, // 시간 폰트 크기 조정
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6), // 시간과 메뉴 사이 간격
                                  Text(
                                    "Menu: ${entry.menu}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600, // 메뉴 텍스트 굵게
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "섭취량: ${entry.intake}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.notes,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.4, // 줄 간격 조정
                                    ),
                                    maxLines: 3, // 메모 표시 줄 수 제한
                                    overflow: TextOverflow
                                        .ellipsis, // 내용이 넘칠 경우 ... 처리
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade200, // 구분선 색상 연하게
                      thickness: 1, // 구분선 두께
                      height: 24, // 구분선 위아래 간격
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
