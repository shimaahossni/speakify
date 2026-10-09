import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';

/// Row of action buttons: Copy, Clear, and Speak Text.
class ActionButtonsRow extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSpeak;

  const ActionButtonsRow({
    super.key,
    required this.textController,
    required this.onSpeak,
  });

  void _copyText(BuildContext context) {
    final text = textController.text;
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.copiedToClipboard,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  void _clearText() {
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Row(
      children: [
        // Copy button
        Expanded(
          child: _OutlineActionButton(
            label: AppStrings.copyButton,
            icon: Icons.copy_rounded,
            onTap: () => _copyText(context),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        // Clear button
        Expanded(
          child: _OutlineActionButton(
            label: AppStrings.clearButton,
            icon: Icons.delete_outline_rounded,
            onTap: _clearText,
            color: AppTheme.listeningColor,
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        // Speak button
        Expanded(
          flex: 2,
          child: _GradientButton(
            label: AppStrings.speakButton,
            icon: Icons.volume_up_rounded,
            gradient: AppTheme.primaryGradient,
            onTap: onSpeak,
          ),
        ),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: screenHeight * 0.025),
            SizedBox(height: screenHeight * 0.005),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.textPrimary,
              size: screenHeight * 0.025,
            ),
            SizedBox(width: screenHeight * 0.008),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
