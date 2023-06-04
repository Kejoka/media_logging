import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class CustomPieChart extends StatelessWidget {
  const CustomPieChart({required this.chartData, super.key});
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
              "value": Variable(
                  accessor: (Map map) => map["value"] as num,
                  scale: LinearScale(min: 0)),
            },
            transforms: [Proportion(variable: "value", as: "percent")],
            elements: [
              IntervalElement(
                position: Varset("percent") / Varset("label"),
                modifiers: [StackModifier()],
                color: ColorAttr(variable: "label", values: Defaults.colors20),
                label: LabelAttr(
                    encoder: (tuple) => (Label(
                        "${tuple["label"].toString()}\n${tuple["value"].toStringAsFixed(2)}%",
                        LabelStyle(
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                backgroundColor:
                                    ThemeData.dark().backgroundColor))))),
              )
            ],
            coord: PolarCoord(transposed: true, dimCount: 1),
          ),
        ),
      ],
    );
  }
}
