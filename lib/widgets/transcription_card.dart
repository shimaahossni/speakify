import 'package:flutter/material.dart';
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';

/// Text field card where speech-to-text results appear and can be edited.
class TranscriptionCard extends StatelessWidget {
  final TextEditingController controller;

  const TranscriptionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 5,
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: AppStrings.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textHint,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenHeight * 0.02,
          ),
        ),
      ),
    );
  }
}
