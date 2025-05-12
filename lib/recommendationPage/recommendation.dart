import 'package:flutter/material.dart';

class Recommendation extends StatelessWidget {
  const Recommendation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 화면 배경색을 흰색으로 설정
      body: Center( // 모든 내용을 화면 중앙에 배치
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Column 내부 요소를 세로 중앙 정렬
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded, // 주의 아이콘 표시
              size: 80, // 아이콘 크기
              color: Colors.orangeAccent, // 아이콘 색상
            ),
            SizedBox(height: 20), // 아이콘과 텍스트 사이 간격
            Text(
              '개발중..', // 표시할 텍스트
              style: TextStyle(
                fontSize: 24, // 텍스트 크기
                fontWeight: FontWeight.bold, // 텍스트 굵기
              ),
            ),
          ],
        ),
      ),
    );
  }
}