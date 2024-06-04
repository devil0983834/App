import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:temperature/data_provider.dart';
import 'dart:async';

class RecentWidget extends StatefulWidget {
  const RecentWidget({super.key});

  @override
  State<StatefulWidget> createState() => _RecentWidgetState();
}

class _RecentWidgetState extends State<RecentWidget> {
  Timer? _timer;

  @override
  void initState() {
    context.read<DataProvider>().getTempDays();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<DataProvider>().getTempDays();
    return Consumer<DataProvider>(
      builder: (context, data, _) => SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 350,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: const DateTimeCategoryAxis(),
                  primaryYAxis: const NumericAxis(
                      // majorTickLines: MajorTickLines(size: 0),
                      rangePadding: ChartRangePadding.none,
                      axisLine: AxisLine(width: 0),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      labelFormat: '{value}°C',
                      minimum: 0,
                      maximum: 50),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<TemperatureData, DateTime>>[
                    LineSeries(
                      xValueMapper: (datum, _) => datum.time,
                      yValueMapper: (datum, _) => datum.temperature,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataSource: data.tempDays,
                      name: "",
                    ),
                  ],
                )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              SizedBox(
                width: 100,
                height: 50,
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  onSubmitted: (value) => {
                    data.integral(double.parse(value))
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter x',
                  ),
                ),
              ),
              Text("Probability: ${(data.p * 100).toStringAsFixed(2)}%"),
            ])
          ],
        ),
      ),
    );
  }
}
