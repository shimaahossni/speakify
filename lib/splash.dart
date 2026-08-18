import 'package:flutter/material.dart';
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';
import 'package:voice_to_text/push_rep.dart';
import 'package:voice_to_text/speakify.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  static const Duration _splashDuration = Duration(seconds: 3);
  static const Duration _fadeDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: _fadeDuration);
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    Future.delayed(_splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (mounted) pushReplacement(context, const Speakify());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: screenSize.width * 0.35,
                    height: screenSize.width * 0.35,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.025),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    AppStrings.appName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: screenSize.width * 0.12,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.008),
                Text(
                  AppStrings.appSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
