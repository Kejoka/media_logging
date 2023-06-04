import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_logging/presentation/custom_bar_chart.dart';
import 'package:media_logging/presentation/custom_pie_chart.dart';

/// Stat ideas:
/// Genre Percentage
/// Percentage of Medals
/// Average Rating of all Movies
/// Pie chart of average rating ranges
/// Watched movies that were released in n separate years
/// Collection of medal movies

class StatItem extends StatelessWidget {
  const StatItem({required this.statValues, super.key});
  final List<Map<String, dynamic>> statValues;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
            elevation: 7.5,
            color:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).canvasColor,
            shadowColor: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10),
            child: _buildChart()));
  }

  _buildChart() {
    log(statValues.toString());
    switch (statValues[0]["chartType"]) {
      case "pie":
        return CustomPieChart(chartData: statValues);
      case "bar":
        return CustomBarChart(chartData: statValues);
      default:
    }
  }
}
