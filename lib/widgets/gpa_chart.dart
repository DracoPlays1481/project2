import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GPAChart extends StatelessWidget {
  final List<Map<String, dynamic>> gpaData;

  const GPAChart({
    super.key,
    required this.gpaData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.primary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: _buildBottomTitles(),
            leftTitles: _buildLeftTitles(),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1,
              ),
              left: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          minX: 0,
          maxX: 2,
          minY: 1.5,
          maxY: 4.0,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                gpaData.length,
                    (index) => FlSpot(
                  index.toDouble(),
                  (gpaData[index]['gpa'] as num).toDouble(),
                ),
              ),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: theme.colorScheme.primary,
                    strokeWidth: 3,
                    strokeColor: theme.colorScheme.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AxisTitles _buildBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= gpaData.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              gpaData[index]['semester'].toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        reservedSize: 40,
      ),
    );
  }

  AxisTitles _buildLeftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 0.5,
        getTitlesWidget: (value, meta) {
          return Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        reservedSize: 35,
      ),
    );
  }
}