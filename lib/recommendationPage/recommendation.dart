import 'package:flutter/material.dart';



class MenuRecommendScreen extends StatefulWidget {
  const MenuRecommendScreen({super.key});

  @override
  State<MenuRecommendScreen> createState() => _MenuRecommendScreenState();
}

class _MenuRecommendScreenState extends State<MenuRecommendScreen> {
  int _selectedIndex = 1; // Default selected index for bottom nav (apps icon)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic here based on index if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using SafeArea to avoid notch/status bar overlap
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Custom App Bar / Title ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
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

            // --- Main Content Area ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light grey background for the content area
                  borderRadius: BorderRadius.circular(25.0), // Rounded corners
                ),
                child: SingleChildScrollView( // Allows scrolling if content overflows
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Preference Priority Section ---
                      _buildSectionTitle('Preference priority'),
                      const SizedBox(height: 15),
                      _buildMenuItem(
                        imagePath: 'assets/image/namul.jpg', // Replace with your asset path
                        title: '나물',
                        subtitle: '참나물',
                        tags: [_buildTag('식이섬유', Colors.teal[300]!)],
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        imagePath: 'assets/image/dubu.jpg', // Replace with your asset path
                        title: '두부',
                        subtitle: '두부 구이',
                        tags: [_buildTag('단백질', Colors.yellow[600]!)],
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        imagePath: 'assets/image/goguma.jpg', // Replace with your asset path
                        title: '고구마',
                        subtitle: '찐 고구마',
                        tags: [
                          _buildTag('식이섬유', Colors.teal[300]!),
                          const SizedBox(width: 5), // Spacing between tags
                          _buildTag('탄수화물', Colors.purple[300]!),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- Nutrient Balance Priority Section ---
                      _buildSectionTitle('Nutrient Balance priority'),
                      const SizedBox(height: 15),
                       _buildMenuItem(
                        imagePath: 'assets/image/gyeran.jpg', // Replace with your asset path
                        title: '계란',
                        subtitle: '계란찜',
                        tags: [_buildTag('단백질', Colors.yellow[600]!)],
                      ),
                      const SizedBox(height: 12),
                       _buildMenuItem(
                        imagePath: 'assets/image/saengseon.jpg', // Replace with your asset path
                        title: '생선',
                        subtitle: '연어구이',
                        tags: [_buildTag('단백질', Colors.yellow[600]!)],
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        imagePath: 'assets/image/yogurt.jpg', // Replace with your asset path
                        title: '요거트',
                        subtitle: '그릭요거트',
                        tags: [
                          _buildTag('식이섬유', Colors.teal[300]!),
                          const SizedBox(width: 5),
                          _buildTag('콜레스테롤', Colors.pink[300]!), // Assuming it means Cholesterol
                        ],
                      ),
                      const SizedBox(height: 30), // Space before button

                       // --- Capture Button ---
                       _buildCaptureButton(),
                       const SizedBox(height: 10), // Some padding at the bottom if needed
                    ],
                  ),
                ),
              ),
            ),
              const SizedBox(height: 10), // Space between content and bottom nav bar
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '', // No label shown
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: '', // No label shown
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border), // Use Icons.star for filled star
            label: '', // No label shown
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87, // Color for selected icon
        unselectedItemColor: Colors.grey[400], // Color for unselected icons
        backgroundColor: Colors.white, // Background of the nav bar
        type: BottomNavigationBarType.fixed, // Ensures items are evenly spaced
        showSelectedLabels: false, // Hide labels even when selected
        showUnselectedLabels: false, // Hide labels
        elevation: 5.0, // Adds a subtle shadow
        iconSize: 28, // Adjust icon size
        onTap: _onItemTapped,
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
        color: Colors.white.withOpacity(0.8), // Slightly transparent white or solid grey[200]
        // color: Colors.grey[200], // Alternative background
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          // Image
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300], // Placeholder background
            backgroundImage: AssetImage(imagePath),
             onBackgroundImageError: (exception, stackTrace) {
               // Optional: Handle image load errors gracefully
               print('Error loading image: $imagePath');
             },
          ),
          const SizedBox(width: 15),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // Semi-bold
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Space before tags

          // Tags on the right
          Row(
            mainAxisSize: MainAxisSize.min, // Takes minimum space needed for tags
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
          backgroundColor: Colors.orange[400], // Button color
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0), // Rounded button corners
          ),
          elevation: 2, // Slight shadow
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