import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';
import 'package:voice_to_text/speakify.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SpeakifyApp());
}

class SpeakifyApp extends StatelessWidget {
  const SpeakifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Speakify(),
    );
  }
}
