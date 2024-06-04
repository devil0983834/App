import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import 'package:temperature/data_provider.dart';
import 'bottom_navigation.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DataProvider(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: BottomNavigation());
  }
}
