import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'package:temperature/data_provider.dart';
import 'dart:async';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Timer? _timer;

  @override
  void initState() {
    context.read<DataProvider>().getTemp();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      context.read<DataProvider>().getTemp();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Consumer<DataProvider>(builder: (context, data, _) {
            return SleekCircularSlider(
              min: 0,
              max: 50,
              initialValue: data.temperature,
              appearance: CircularSliderAppearance(
                customColors: CustomSliderColors(
                  progressBarColor:
                  data.temperature > 32.0 ? Colors.red : Colors.green,
                  trackColor: Colors.grey,
                  dotColor: Colors.white,
                  dynamicGradient: true
                ),
              ),
              innerWidget: (value) {
                return Center(
                  child: Text(
                    '${value.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontSize: 40),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
