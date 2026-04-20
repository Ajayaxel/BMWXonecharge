import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonEmiosn extends StatelessWidget {
  final String userName;
  const CarbonEmiosn({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://images.unsplash.com/photo-1567667194029-8e7a178814ea?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Zm9yZXN0JTIwdG9wJTIwdmlld3xlbnwwfHwwfHx8MA%3D%3D",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      width: 150,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.eco,
                              color: Colors.green,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Offset 1.2 tonnes",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // progress bar
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "15.02",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          "Tons CO₂",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hi, $userName!",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                "Goal: 12 CO₂",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            ),
                            Text(
                              "-22% below your avg carbon footprint",
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // overview cards
                        const CarbonOverviewCard(),
                        SizedBox(height: 16),

                        // weekly progress bar
                        const WeeklyProgressBar(),
                        const SizedBox(height: 20),

                        // offset emissions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Offset Emissions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  "See more",
                                  style: TextStyle(
                                    color: Color(0xFF1B4D3E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF1B4D3E),
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        SizedBox(
                          height: 230,
                          child: ListView.builder(
                            itemCount: 5,

                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Blog();
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Blog extends StatelessWidget {
  const Blog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: 180,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        image: DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1567667194029-8e7a178814ea?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Zm9yZXN0JTIwdG9wJTIwdmlld3xlbnwwfHwwfHx8MA%3D%3D",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Spacer(),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Offset Emissions",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Lorem Ipsum is simply dummy text of the printing\nand typesetting industry.",

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyProgressBar extends StatelessWidget {
  const WeeklyProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly overview",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "Carbon Footprint (kg)",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [_buildToggle("W", true), _buildToggle("M", false)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 400,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        const values = [
                          '300',
                          '340',
                          '260',
                          '280',
                          '60',
                          '0',
                          '0',
                        ];
                        int index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              days[index],
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              values[index],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 300, const Color(0xFFC0E5B1)),
                  _buildBarGroup(1, 340, const Color(0xFFC0E5B1)),
                  _buildBarGroup(2, 260, const Color(0xFFC0E5B1)),
                  _buildBarGroup(3, 280, const Color(0xFFC0E5B1)),
                  _buildBarGroup(4, 60, const Color(0xFF1B4D3E)),
                  _buildBarGroup(5, 0, Colors.transparent),
                  _buildBarGroup(6, 0, Colors.transparent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String text, bool isSelected) {
    return Container(
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B4D3E) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(15),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 340,
            color: Colors.black.withValues(alpha: 0.03),
          ),
        ),
      ],
    );
  }
}

class CarbonOverviewCard extends StatelessWidget {
  const CarbonOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Monthly overview",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "Carbon Footprint",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    _buildToggleItem("D", false),
                    _buildToggleItem("W", false),
                    _buildToggleItem("M", true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Center(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 10,
                      centerSpaceRadius: 35,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: 30,
                          color: const Color(0xFF98C9B8),
                          radius: 45,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 25,
                          color: const Color(0xFFD3E9E2),
                          radius: 45,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 20,
                          color: const Color(0xFF8CD47E),
                          radius: 45,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 15,
                          color: const Color(0xFFC0E5B1),
                          radius: 45,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 10,
                          color: const Color(0xFF1B4D3E),
                          radius: 55,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildLabelPoint(
                  alignment: const Alignment(-1.0, -0.7),
                  percentage: "10%",
                  label: "Long Trips",
                  color: const Color(0xFF1B4D3E),
                ),
                _buildLabelPoint(
                  alignment: const Alignment(1.0, -0.7),
                  percentage: "30%",
                  label: "Home Charging",
                  color: const Color(0xFF98C9B8),
                ),
                _buildLabelPoint(
                  alignment: const Alignment(-1.0, 0.1),
                  percentage: "15%",
                  label: "Public Charging",
                  color: const Color(0xFFC0E5B1),
                  lineCross: true,
                ),
                _buildLabelPoint(
                  alignment: const Alignment(1.0, 0.6),
                  percentage: "25%",
                  label: "Daily Commute",
                  color: const Color(0xFFD3E9E2),
                ),
                _buildLabelPoint(
                  alignment: const Alignment(-1.0, 0.9),
                  percentage: "20%",
                  label: "Climate Control",
                  color: const Color(0xFF8CD47E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String text, bool isSelected) {
    return Container(
      width: 30,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B4D3E) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLabelPoint({
    required Alignment alignment,
    required String percentage,
    required String label,
    required Color color,
    bool lineCross = false,
  }) {
    final bool isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isLeft) ...[
            _buildBentLine(isLeft, alignment.y),
            const SizedBox(width: 8),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isLeft
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (isLeft) ...[
            const SizedBox(width: 8),
            _buildBentLine(isLeft, alignment.y),
          ],
        ],
      ),
    );
  }

  Widget _buildBentLine(bool isLeft, double y) {
    return CustomPaint(
      size: const Size(25, 15),
      painter: DashBentLinePainter(isLeft: isLeft, y: y),
    );
  }
}

class DashBentLinePainter extends CustomPainter {
  final bool isLeft;
  final double y;

  DashBentLinePainter({required this.isLeft, required this.y});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isLeft) {
      // Label on LEFT, line goes RIGHT towards chart
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width * 0.7, size.height / 2);
      if (y < -0.2) {
        path.lineTo(size.width, size.height);
      } else if (y > 0.2) {
        path.lineTo(size.width, 0);
      } else {
        path.lineTo(size.width, size.height / 2);
      }
    } else {
      // Label on RIGHT, line goes LEFT towards chart
      path.moveTo(size.width, size.height / 2);
      path.lineTo(size.width * 0.3, size.height / 2);
      if (y < -0.2) {
        path.lineTo(0, size.height);
      } else if (y > 0.2) {
        path.lineTo(0, 0);
      } else {
        path.lineTo(0, size.height / 2);
      }
    }

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 2), paint);
        distance += 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
