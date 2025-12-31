import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:magic_enlish/data/services/progress_service.dart';

class GrammarScoreDetailScreen extends StatefulWidget {
  final int avgScore;

  const GrammarScoreDetailScreen({super.key, required this.avgScore});

  @override
  State<GrammarScoreDetailScreen> createState() =>
      _GrammarScoreDetailScreenState();
}

class _GrammarScoreDetailScreenState extends State<GrammarScoreDetailScreen> {
  final ProgressService _progressService = ProgressService();
  List<int> _dailyScores = [];
  List<DateTime> _dailyDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _progressService.getDailyGrammarScoreStats(days: 7);
      setState(() {
        _dailyScores = stats
            .map((e) => (e['avgScore'] as num).toInt())
            .toList();
        _dailyDates = stats
            .map((e) => DateTime.parse(e['date'] as String))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _dailyScores = List.filled(7, 0);
        _dailyDates = List.generate(
          7,
          (i) => DateTime.now().subtract(Duration(days: 6 - i)),
        );
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFF8F9FA);
    final surface = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Grammar Score Stats',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avg Score Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade300, Colors.purple.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, size: 48, color: Colors.white),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.avgScore}',
                              style: GoogleFonts.lexend(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                '/100',
                                style: GoogleFonts.lexend(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Average Score',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // This Week Stats
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Highest',
                          '${_dailyScores.reduce((a, b) => a > b ? a : b)}',
                          'points',
                          isDark
                              ? Colors.green.shade900.withOpacity(0.3)
                              : Colors.green.shade100,
                          isDark ? Colors.green.shade300 : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          'Lowest',
                          '${_dailyScores.reduce((a, b) => a < b ? a : b)}',
                          'points',
                          isDark
                              ? Colors.red.shade900.withOpacity(0.3)
                              : Colors.red.shade100,
                          isDark ? Colors.red.shade300 : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Daily Scores (Last 7 Days)',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Line Chart with Area
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toInt()} points',
                                  GoogleFonts.lexend(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            Color lineColor = isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200;
                            if (value == 60) {
                              lineColor = Colors.orange.withOpacity(0.3);
                            }
                            if (value == 80) {
                              lineColor = Colors.green.withOpacity(0.3);
                            }
                            return FlLine(color: lineColor, strokeWidth: 1);
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= _dailyDates.length) {
                                  return const SizedBox.shrink();
                                }
                                final day = _dailyDates[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('E').format(day),
                                        style: GoogleFonts.lexend(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM').format(day),
                                        style: GoogleFonts.lexend(
                                          fontSize: 9,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              reservedSize: 48,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 20,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              7,
                              (i) => FlSpot(
                                i.toDouble(),
                                _dailyScores[i].toDouble(),
                              ),
                            ),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final color = _getScoreColor(
                                  _dailyScores[index],
                                );
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: color,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pink.withOpacity(0.2),
                                  Colors.purple.withOpacity(0.05),
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

                  const SizedBox(height: 24),

                  // Score Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score Levels',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _scoreLegend(Colors.green, '80-100', 'Excellent'),
                        const SizedBox(height: 8),
                        _scoreLegend(Colors.orange, '60-79', 'Good'),
                        const SizedBox(height: 8),
                        _scoreLegend(Colors.red, '0-59', 'Needs Improvement'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String unit,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(fontSize: 12, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreLegend(Color color, String range, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          range,
          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
