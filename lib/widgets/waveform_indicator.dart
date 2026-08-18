import 'package:flutter/material.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';

/// Animated waveform bars shown while the mic is listening.
class WaveformIndicator extends StatefulWidget {
  final bool isActive;

  const WaveformIndicator({super.key, required this.isActive});

  @override
  State<WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<WaveformIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const int _barCount = 5;
  static const List<double> _delayFactors = [0.0, 0.2, 0.4, 0.2, 0.0];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (i * 80)),
      ),
    );
    _animations = List.generate(
      _barCount,
      (i) => Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[i],
          curve: Curves.easeInOut,
        ),
      ),
    );
    if (widget.isActive) _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _barCount; i++) {
      Future.delayed(
        Duration(milliseconds: (_delayFactors[i] * 400).toInt()),
        () {
          if (mounted) _controllers[i].repeat(reverse: true);
        },
      );
    }
  }

  void _stopAnimations() {
    for (final c in _controllers) {
      c.animateTo(0.2);
    }
  }

  @override
  void didUpdateWidget(WaveformIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _startAnimations() : _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth * 0.03;
        final maxBarHeight = constraints.maxHeight;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_barCount, (i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: barWidth * 0.4),
              child: AnimatedBuilder(
                animation: _animations[i],
                builder: (_, __) => Container(
                  width: barWidth,
                  height: maxBarHeight * _animations[i].value,
                  decoration: BoxDecoration(
                    gradient: widget.isActive
                        ? AppTheme.listeningGradient
                        : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(barWidth),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
