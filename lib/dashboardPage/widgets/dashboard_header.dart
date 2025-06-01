// lib/dashboardPage/widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final double avatarScale; // 프로필 아바타 클릭 시 애니메이션을 위한 스케일 값
  final VoidCallback? onNotificationsPressed; // 알림 아이콘 클릭 이벤트 콜백
  final Function(TapDownDetails) onAvatarTapDown; // 프로필 아바타 탭 다운 이벤트 콜백
  final Function(TapUpDetails) onAvatarTapUp; // 프로필 아바타 탭 업 이벤트 콜백
  final VoidCallback onAvatarTapCancel; // 프로필 아바타 탭 취소 이벤트 콜백

  const DashboardHeader({
    super.key,
    required this.avatarScale,
    this.onNotificationsPressed,
    required this.onAvatarTapDown,
    required this.onAvatarTapUp,
    required this.onAvatarTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // 헤더 좌우 패딩 및 상하 패딩 조정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 요소들을 양 끝으로 정렬
        children: [
          // 'Dashboard' 타이틀
          const Text(
            'Dashboard',
            style: TextStyle(
                fontSize: 28, // 폰트 크기 약간 줄임
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          // 알림 아이콘 및 프로필 아바타
          Row(
            children: [
              // 알림 아이콘 버튼
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28), // 아이콘 변경 및 크기 유지
                onPressed: onNotificationsPressed,
                color: Colors.black54,
                tooltip: '알림', // 접근성을 위한 툴팁
              ),
              const SizedBox(width: 8), // 아이콘과 아바타 사이 간격
              // 프로필 아바타 (탭 제스처 및 애니메이션 적용)
              GestureDetector(
                onTapDown: onAvatarTapDown,
                onTapUp: onAvatarTapUp,
                onTapCancel: onAvatarTapCancel,
                child: AnimatedScale(
                  scale: avatarScale, // 외부에서 전달받은 스케일 값으로 애니메이션
                  duration: const Duration(milliseconds: 150), // 애니메이션 지속 시간
                  child: CircleAvatar(
                    radius: 22, // 아바타 크기 약간 키움
                    // TODO: 'assets/image/default_man.png' 이미지 경로가 실제 프로젝트에 존재하는지 확인 필요
                    // 이미지가 없을 경우를 대비하여 backgroundColor 설정
                    backgroundImage: const AssetImage('assets/image/default_man.png'),
                    backgroundColor: Colors.grey.shade300, // 이미지 로드 실패 시 배경색
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
