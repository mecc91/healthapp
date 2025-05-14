import 'package:flutter/material.dart';
import 'package:healthymeal/widgets/common_bottom_navigation_bar.dart'; // 공통 네비게이션 바 import

class MenuRecommendScreen extends StatefulWidget {
  const MenuRecommendScreen({super.key});

  @override
  State<MenuRecommendScreen> createState() => _MenuRecommendScreenState();
}

class _MenuRecommendScreenState extends State<MenuRecommendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Custom App Bar with Back Button and Title ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0), // AppBar 전체 패딩
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                children: [
                  // --- Back Button ---
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
                    onPressed: () {
                      // 뒤로 가기 기능
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    tooltip: '뒤로 가기', // Optional: accessibility
                  ),

                  // --- Title ---
                  // Expanded를 사용하여 제목이 중앙을 차지하도록 하지만,
                  // IconButton 때문에 정확한 중앙 정렬이 어려울 수 있어,
                  // 제목 자체를 중앙 정렬하고 Row의 MainAxisAlignment를 활용합니다.
                  // 또는 Stack을 사용하여 Positioned로 배치할 수도 있습니다.
                  // 여기서는 Row와 Spacer를 활용하여 제목을 중앙에 가깝게 배치합니다.
                  const Expanded(
                    child: Text(
                      'Menu Recommend',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // --- Placeholder to balance the Row for centering title ---
                  // IconButton과 동일한 공간을 차지하게 하여 제목을 중앙에 정렬합니다.
                  // Opacity를 사용하여 시각적으로는 보이지 않게 합니다.
                  Opacity(
                    opacity: 0.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: null, // 기능 없음
                    ),
                  ),
                ],
              ),
            ),

            // --- Main Content Area ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Preference Priority Section ---
                      _buildSectionContainer(
                        title: 'Preference priority',
                        children: [
                          _buildMenuItem(
                            imagePath: 'assets/image/namul.jpg',
                            title: '나물',
                            subtitle: '참나물',
                            tags: [_buildTag('식이섬유', Colors.teal[300]!)],
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            imagePath: 'assets/image/dubu.jpg',
                            title: '두부',
                            subtitle: '두부 구이',
                            tags: [_buildTag('단백질', Colors.yellow[600]!)],
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            imagePath: 'assets/image/goguma.jpg',
                            title: '고구마',
                            subtitle: '찐 고구마',
                            tags: [
                              _buildTag('식이섬유', Colors.teal[300]!),
                              const SizedBox(width: 5),
                              _buildTag('탄수화물', Colors.purple[300]!),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // 섹션 간 간격

                      // --- Nutrient Balance Priority Section ---
                      _buildSectionContainer(
                        title: 'Nutrient Balance priority',
                        children: [
                          _buildMenuItem(
                            imagePath: 'assets/image/gyeran.jpg',
                            title: '계란',
                            subtitle: '계란찜',
                            tags: [_buildTag('단백질', Colors.yellow[600]!)],
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            imagePath: 'assets/image/saengseon.jpg',
                            title: '생선',
                            subtitle: '연어구이',
                            tags: [_buildTag('단백질', Colors.yellow[600]!)],
                          ),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            imagePath: 'assets/image/yogurt.jpg',
                            title: '요거트',
                            subtitle: '그릭요거트',
                            tags: [
                              _buildTag('식이섬유', Colors.teal[300]!),
                              const SizedBox(width: 5),
                              _buildTag('콜레스테롤', Colors.pink[300]!),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25), // 섹션과 버튼 간 간격

                      // --- Capture Button ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildCaptureButton(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10), // Bottom Nav Bar와의 간격
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentPage: AppPage.recommendation,
      ),
    );
  }

  // --- Helper Widget for Section Containers ---
  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  // --- Helper Widget for Section Titles ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.8),
      ),
    );
  }

  // --- Helper Widget for Menu Items ---
  Widget _buildMenuItem({
    required String imagePath,
    required String title,
    required String subtitle,
    required List<Widget> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            backgroundImage: AssetImage(imagePath),
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading image: $imagePath');
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: tags,
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Tags ---
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- Helper Widget for Capture Button ---
  Widget _buildCaptureButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement capture action
        print('Capture Menu List tapped!');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[400],
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Capture Menu List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.camera_alt, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
