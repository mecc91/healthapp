import 'package:flutter/material.dart';

class ScoreCommentDisplay extends StatelessWidget {
  // 실제 앱에서는 코멘트 내용을 동적으로 생성하거나 외부에서 주입받아야 합니다.
  // 여기서는 기존의 하드코딩된 텍스트를 유지합니다.
  const ScoreCommentDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible( // 남은 공간을 차지하도록 Flexible 사용
      flex: 1, // 다른 Expanded 위젯과의 비율에 따라 조정
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView( // 짧은 내용이지만, 여러 줄일 경우 스크롤 가능하도록 ListView 사용
          shrinkWrap: true, // 내용만큼만 높이 차지
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87),
                children: const [
                  TextSpan(text: "이번 주는 전반적으로 양호한 점수를 기록했습니다. 특히 "),
                  TextSpan(
                      text: "단백질과 식이섬유 ",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                  TextSpan(text: "섭취가 잘 이루어졌습니다. "),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87),
                children: const [
                  TextSpan(text: "다만, "),
                  TextSpan(
                      text: "탄수화물과 나트륨 ",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "섭취량에 조금 더 주의가 필요해 보입니다. 다음 주에는 균형 잡힌 식단을 유지해 보세요!"),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}