import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardHeader extends StatefulWidget {
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
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (mounted) {
      setState(() {
        _profileImagePath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
                onPressed: widget.onNotificationsPressed,
                color: Colors.black54,
                tooltip: '알림',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTapDown: widget.onAvatarTapDown,
                onTapUp: widget.onAvatarTapUp,
                onTapCancel: widget.onAvatarTapCancel,
                child: AnimatedScale(
                  scale: widget.avatarScale,
                  duration: const Duration(milliseconds: 150),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: _profileImagePath != null &&
                            File(_profileImagePath!).existsSync()
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/image/default_man.png')
                            as ImageProvider,
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
