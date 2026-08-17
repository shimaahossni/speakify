// main.dart
import 'package:flutter/material.dart';
import 'package:voice_to_text/voice_text.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Speakify(),
    );
  }
}
