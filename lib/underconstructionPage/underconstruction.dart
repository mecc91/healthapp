import 'package:flutter/material.dart';

class Underconstruction extends StatelessWidget {
  const Underconstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 화면 배경색을 흰색으로 설정
      appBar: AppBar( // AppBar를 추가합니다.
        leading: IconButton( // AppBar의 왼쪽에 아이콘 버튼을 추가합니다.
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘을 사용합니다.
          onPressed: () {
            Navigator.pop(context); // 현재 화면을 스택에서 제거하여 이전 화면으로 돌아갑니다.
          },
        ),
        title: Text(' '), // AppBar 제목 (필요에 따라 변경 가능)
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        elevation: 0, // AppBar 그림자 제거
      ),
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