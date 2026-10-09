import 'package:flutter/material.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';

/// Floating action button with a pulsing animation while listening.
class AnimatedMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const AnimatedMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<AnimatedMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isListening) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AnimatedMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isListening
        ? AppTheme.listeningGradient
        : AppTheme.primaryGradient;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        return Transform.scale(
          scale: widget.isListening ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.isListening
                    ? AppTheme.listeningColor.withOpacity(0.5)
                    : AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: AppTheme.textPrimary,
            size: 30,
          ),
        ),
      ),
    );
  }
}
