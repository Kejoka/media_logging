import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class CustomBarChart extends StatelessWidget {
  const CustomBarChart({required this.chartData, super.key});
  final List<Map<dynamic, dynamic>> chartData;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(chartData[0]["chartTitle"]),
        SizedBox(
          height: 400,
          child: Chart(
            data: chartData.sublist(1),
            variables: {
              "label": Variable(
                accessor: (Map map) => map["label"] as String,
              ),
              "value": Variable(accessor: (Map map) => map["value"] as num)
            },
            elements: [
              IntervalElement(
                color: (chartData.length > 10)
                    ? ColorAttr(variable: "label", values: Defaults.colors20)
                    : ColorAttr(variable: "label", values: Defaults.colors10),
              )
            ],
            axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
          ),
        ),
      ],
    );
  }
}
