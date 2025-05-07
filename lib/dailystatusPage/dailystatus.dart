import 'package:flutter/material.dart';

class DailyStatus extends StatefulWidget {
  const DailyStatus({super.key});

  @override
  State<DailyStatus> createState() => _DailyStatusState();
}

class _DailyStatusState extends State<DailyStatus> {
  final List<NutrientData> nutrients = const [
    NutrientData('탄수화물', 20, 12, Color.fromARGB(255, 255, 152, 0)),
    NutrientData('단백질', 12, 9, Color.fromARGB(255, 76, 175, 86)),
    NutrientData('지방', 16, 11, Colors.lightGreen),
    NutrientData('나트륨', 20, 12, Colors.orange),
    NutrientData('식이섬유', 14, 10, Colors.green),
    NutrientData('당류', 10, 8, Colors.red),
    NutrientData('콜레스테롤', 16, 9, Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Status',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: nutrients
              .map((nutrient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: NutrientBar(nutrient: nutrient),
                  ))
              .toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class NutrientData {
  final String name;
  final int totalBlocks;
  final int filledBlocks;
  final Color color;

  const NutrientData(this.name, this.totalBlocks, this.filledBlocks, this.color);
}

class NutrientBar extends StatelessWidget {
  final NutrientData nutrient;
  final double totalWidth = 300.0;
  final double baselineRatio = 0.8; // 기준선 위치 비율

  const NutrientBar({super.key, required this.nutrient});

  @override
  Widget build(BuildContext context) {
    const double blockHeight = 24.0;
    const double spacing = 4.0;

    final double blockWidth = (totalWidth - (nutrient.totalBlocks - 1) * spacing) /
        nutrient.totalBlocks;

    final double baselineLeft = totalWidth * baselineRatio;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 15),
                Text(
                  nutrient.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: SizedBox(
                  width: totalWidth,
                  height: blockHeight + 24, // 블럭 높이 + 수치 공간 확보
                  child: Stack(
                    children: [
                      // 블럭들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          nutrient.totalBlocks,
                          (index) => Container(
                            width: blockWidth,
                            height: blockHeight,
                            margin: EdgeInsets.only(
                              right: index == nutrient.totalBlocks - 1 ? 0 : spacing,
                            ),
                            decoration: BoxDecoration(
                              color: index < nutrient.filledBlocks
                                  ? nutrient.color
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: index < nutrient.filledBlocks
                                    ? nutrient.color
                                    : Colors.black38,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 기준선
                      Positioned(
                        left: baselineLeft - 2,
                        top: 0,
                        bottom: 24,
                        child: Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // 수치 텍스트 (채워진 끝 위치 기준)
                      Positioned(
                        left: nutrient.filledBlocks * (blockWidth + spacing) - blockWidth / 2,
                        top: blockHeight + 4,
                        child: Text(
                          '${nutrient.filledBlocks}/${nutrient.totalBlocks}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
