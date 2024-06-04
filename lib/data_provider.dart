import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:calculus/calculus.dart';

class DataProvider with ChangeNotifier {
  double _sigma = 1;
  double _temperature = 0;
  List<TemperatureData> _tempDays = [];
  double _p = 0;

  double get p => _p;

  List<TemperatureData> get tempDays => _tempDays;

  double get temperature => _temperature;
  final int channelId = 2560219;

  final String apiKey = 'BJ1BH4TRLKQE5Q4Y';
  final String url = 'https://api.thingspeak.com/';

  Future<void> getTemp() async {
    final String path =
        'channels/${channelId}/feeds.json?api_key=${apiKey}&results=1&rounding=2';
    final response = await http.get(Uri.parse(url + path));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _temperature = double.parse(data['feeds'][0]['field1']);
    } else {
      throw Exception('Failed to fetch data from Thingspeak');
    }
    notifyListeners();
  }

  Future<void> getTempDays() async {
    double sum = 0;
    final String path =
        'channels/${channelId}/feeds.json?api_key=${apiKey}'
        '&average=10&results=220';
    final response = await http.get(Uri.parse(url + path));
    if (response.statusCode == 200) {
      tempDays.clear();
      Map<String, dynamic> jsonData = json.decode(response.body);
      List<dynamic> data = jsonData['feeds'];
      data.forEach((element) {
        if (element['field1'] != null) {
          DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
          DateTime time =
              dateFormat.parse(element['created_at']).add(Duration(hours: 7));
          double temperature = double.parse(element['field1']);
          print(temperature);
          _tempDays.add(TemperatureData(time, temperature));
          sum += temperature;
        }
      });
    } else {
      throw Exception('Failed to fetch data from Thingspeak');
    }
    double avg = sum / _tempDays.length;
    double sum1 = 0;
    _tempDays.forEach((element) {
      sum1 += pow((avg - element.temperature), 2);
    });
    _sigma = sqrt(sum1 / _tempDays.length);
    List<TemperatureData> newTemp = _tempDays
        .where((e) =>
            e.temperature >= avg - 3 * _sigma &&
            e.temperature <= avg + 3 * _sigma)
        .toList();
    if (newTemp.length != _tempDays.length) {
      sum = 0;
      sum1 = 0;
      newTemp.forEach((element) {
        sum += element.temperature;
      });
      avg = sum / newTemp.length;
      newTemp.forEach((element) {
        sum1 += pow(avg - element.temperature, 2);
      });
      _sigma = sqrt(sum1 / newTemp.length);
    }
    notifyListeners();
  }

  Future<void> integral(double x) async {
    _p = 2 * Calculus.integral(0, x, gaussianFunction, 1000);
    notifyListeners();
  }

  num gaussianFunction(num x) {
    double exponent = -(x * x) / (2 * _sigma * _sigma);
    double coefficient = 1 / (sqrt(2 * pi) * _sigma);
    return coefficient * exp(exponent);
  }
}

class TemperatureData {
  final DateTime time;
  final double temperature;

  TemperatureData(this.time, this.temperature);
}
