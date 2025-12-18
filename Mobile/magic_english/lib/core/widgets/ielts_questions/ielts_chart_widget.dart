import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/ielts/ielts_test.dart';

/// Widget to display IELTS Writing Task 1 charts
class IELTSChartWidget extends StatelessWidget {
  final ChartData chartData;

  const IELTSChartWidget({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Title
          Text(
            chartData.title,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // Chart
          SizedBox(height: 250, child: _buildChart()),

          const SizedBox(height: 12),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: chartData.datasets.map((dataset) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _parseColor(dataset.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dataset.label,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartData.chartType.toLowerCase()) {
      case 'line':
        return _buildLineChart();
      case 'bar':
        return _buildBarChart();
      case 'pie':
        return _buildPieChart();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildLineChart() {
    final List<LineChartBarData> lineBars = [];

    for (int i = 0; i < chartData.datasets.length; i++) {
      final dataset = chartData.datasets[i];
      final spots = <FlSpot>[];

      for (int j = 0; j < dataset.data.length; j++) {
        spots.add(FlSpot(j.toDouble(), dataset.data[j]));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _parseColor(dataset.color),
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: _parseColor(dataset.color).withOpacity(0.1),
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: chartData.yAxisLabel != null
                ? Text(
                    chartData.yAxisLabel!,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: chartData.xAxisLabel != null
                ? Text(
                    chartData.xAxisLabel!,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartData.labels[index],
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return const Text('');
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
        lineBarsData: lineBars,
      ),
    );
  }

  Widget _buildBarChart() {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < chartData.labels.length; i++) {
      final rods = <BarChartRodData>[];

      for (int j = 0; j < chartData.datasets.length; j++) {
        final dataset = chartData.datasets[j];
        if (i < dataset.data.length) {
          rods.add(
            BarChartRodData(
              toY: dataset.data[i],
              color: _parseColor(dataset.color),
              width: chartData.datasets.length > 1 ? 12 : 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          );
        }
      }

      barGroups.add(BarChartGroupData(x: i, barRods: rods, barsSpace: 4));
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartData.labels[index],
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
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
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = <PieChartSectionData>[];
    final dataset = chartData.datasets.isNotEmpty
        ? chartData.datasets[0]
        : null;

    if (dataset == null) {
      return const Center(child: Text('No data'));
    }

    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFFE24A4A),
      const Color(0xFF4AE290),
      const Color(0xFFE2A64A),
      const Color(0xFF9B4AE2),
      const Color(0xFF4AE2E2),
    ];

    for (
      int i = 0;
      i < dataset.data.length && i < chartData.labels.length;
      i++
    ) {
      sections.add(
        PieChartSectionData(
          value: dataset.data[i],
          title: '${dataset.data[i].toInt()}%',
          color: colors[i % colors.length],
          radius: 80,
          titleStyle: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              chartData.labels.length.clamp(0, dataset.data.length),
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        chartData.labels[index],
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF4A90E2);
    }
  }

  double _calculateInterval() {
    double maxValue = 0;
    for (final dataset in chartData.datasets) {
      for (final value in dataset.data) {
        if (value > maxValue) maxValue = value;
      }
    }
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    return maxValue / 5;
  }
}
