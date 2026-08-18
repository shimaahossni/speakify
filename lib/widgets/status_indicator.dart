import 'package:flutter/material.dart';
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final bool isListening;

  const StatusIndicator({super.key, required this.isListening});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey<bool>(isListening),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isListening)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.listeningColor,
                shape: BoxShape.circle,
              ),
            ),
          if (isListening) const SizedBox(width: 8),
          Text(
            isListening ? AppStrings.statusListening : AppStrings.statusIdle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isListening
                  ? AppTheme.listeningColor
                  : AppTheme.textSecondary,
              fontWeight:
                  isListening ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
