import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 16),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ),
        title: Text(
          'Mood History',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Color(0xFF2C3E50), size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDate),
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF48C9B0), size: 28),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_left_rounded, color: Color(0xFFBDC3C7), size: 32),
                const SizedBox(width: 16),
                const Icon(Icons.keyboard_arrow_right_rounded, color: Color(0xFF2C3E50), size: 32),
              ],
            ),
            const SizedBox(height: 24),
            
            // Weekly Calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][index];
                final date = index + 12; // Example dates
                final isToday = index == 3;
                final moodEmoji = ['😊', '😑', '😊', '😇', '😨', '😊', '😊'][index];
                
                return Column(
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBDC3C7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isToday ? ThemeConfig.primaryTeal : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isToday ? null : Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
                        boxShadow: isToday ? [
                          BoxShadow(
                            color: ThemeConfig.primaryTeal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            date.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isToday ? Colors.white : const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            moodEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Mood Trends Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FCFB),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF0F9F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mood Trends',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Weekly',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF7F8C8D)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                if (value == 4) text = 'Great';
                                if (value == 3) text = 'Good';
                                if (value == 2) text = 'Okay';
                                if (value == 1) text = 'Low';
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    text,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFBDC3C7),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 45,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Wed', 'Fri', 'Sun'];
                                if (value % 2 == 0 && value < 8) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      days[(value / 2).toInt()],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFBDC3C7),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 7,
                        minY: 0,
                        maxY: 5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 1.5),
                              const FlSpot(1, 2.8),
                              const FlSpot(2, 2.2),
                              const FlSpot(3, 3.5),
                              const FlSpot(4, 2.5),
                              const FlSpot(5, 4.2),
                              const FlSpot(6, 3.0),
                            ],
                            isCurved: true,
                            color: ThemeConfig.primaryTeal,
                            barWidth: 6,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == 5) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: ThemeConfig.primaryTeal.withOpacity(0.4),
                                    strokeWidth: 0,
                                  );
                                }
                                return FlDotCirclePainter(radius: 0);
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  ThemeConfig.primaryTeal.withOpacity(0.15),
                                  ThemeConfig.primaryTeal.withOpacity(0.01),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Today's Insights
            Text(
              'Today\'s Insights',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your mood is up 12%',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ThemeConfig.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Consistency in your morning meditation is showing positive effects.',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: const Color(0xFF7F8C8D),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
