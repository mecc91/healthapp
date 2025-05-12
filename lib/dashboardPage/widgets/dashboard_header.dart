// lib/dashboardPage/widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final double avatarScale;
  final VoidCallback? onNotificationsPressed;
  final Function(TapDownDetails) onAvatarTapDown;
  final Function(TapUpDetails) onAvatarTapUp;
  final VoidCallback onAvatarTapCancel;

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
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: onNotificationsPressed,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTapDown: onAvatarTapDown,
                onTapUp: onAvatarTapUp,
                onTapCancel: onAvatarTapCancel,
                child: AnimatedScale(
                  scale: avatarScale,
                  duration: const Duration(milliseconds: 150),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        const AssetImage('assets/image/default_man.png'), // 이미지 경로 확인 필요
                    backgroundColor: Colors.grey.shade300,
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