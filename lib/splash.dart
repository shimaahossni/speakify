// splash.dart
import 'package:flutter/material.dart';
import 'package:voice_to_text/push_rep.dart';
import 'package:voice_to_text/voice_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      pushReplacement(context, const Speakify());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset("assets/logo.jpg"),
    );
  }
}
