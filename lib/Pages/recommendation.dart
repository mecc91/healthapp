import 'package:flutter/material.dart';

class Recommendation extends StatelessWidget {
  const Recommendation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecommendationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  final List<Map<String, dynamic>> weekData = const [
    {'day': 'Mon', 'value': 46},
    {'day': 'Tue', 'value': 72},
    {'day': 'Wed', 'value': 89},
    {'day': 'Thu', 'value': 58},
    {'day': 'Fri', 'value': 37},
    {'day': 'Sat', 'value': 93},
    {'day': 'Sun', 'value': 60},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommendation",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: const [true, false, false, false],
              onPressed: (_) {},
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("week", style: TextStyle(color: Colors.teal)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("month"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("quater"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("year"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: '65',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' point', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text("March 30th ~ April 6th"),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                  minimumSize: const Size(50, 30),
                ),
                child:
                    const Text("detail", style: TextStyle(color: Colors.teal)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekData.map((dayData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${dayData['value']}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          height: dayData['value'].toDouble() * 2,
                          width: 20,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 4),
                        Text(dayData['day']),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: "Good results ",
                      style: TextStyle(color: Colors.green)),
                  TextSpan(text: "in protein, dietary fiber, and fat intake!"),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: "Careful ", style: TextStyle(color: Colors.red)),
                  TextSpan(
                      text:
                          "about carbohydrate, cholesterol, and sodium intake!"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: ''),
        ],
      ),
    );
  }
}
