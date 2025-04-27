import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MenuRecommendPage(),
  ));
}

class MenuRecommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Menu Recommend',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),

            // Preference Priority
            Text('Preference priority', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            _buildMenuItem('assets/images/chamnamul.jpg', '나물', ['식이섬유']),
            _buildMenuItem('assets/images/tofu.jpg', '두부', ['단백질']),
            _buildMenuItem('assets/images/sweet_potato.jpg', '고구마', ['식이섬유', '탄수화물']),
            SizedBox(height: 30),

            // Nutrient Balance Priority
            Text('Nutrient Balance priority', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            _buildMenuItem('assets/images/egg.jpg', '계란', ['단백질']),
            _buildMenuItem('assets/images/fish.jpg', '생선', ['단백질']),
            _buildMenuItem('assets/images/yogurt.jpg', '요거트', ['식이섬유', '콜레스테롤']),
            SizedBox(height: 30),

            // Capture Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Menu List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String imagePath, String title, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18)),
                SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    Color bgColor;
    if (label == '식이섬유') {
      bgColor = Colors.green.shade100;
    } else if (label == '단백질') {
      bgColor = Colors.yellow.shade100;
    } else if (label == '탄수화물') {
      bgColor = Colors.blue.shade100;
    } else if (label == '콜레스테롤') {
      bgColor = Colors.red.shade100;
    } else {
      bgColor = Colors.grey.shade300;
    }

    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: bgColor,
    );
  }
}
