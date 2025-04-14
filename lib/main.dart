import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PhoneDineApp());
}

class PhoneDineApp extends StatelessWidget {
  const PhoneDineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneDine',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
