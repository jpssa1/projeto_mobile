import 'package:flutter/material.dart';
import 'package:projeto_mobile/core/theme/app_theme.dart';

class Answer extends StatelessWidget {
  const Answer({
    super.key,
    required this.label,
    required this.index,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });
  final String label;
  final int index;
  final bool selected, correct, wrong;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = correct
        ? const Color(0xFF007D19)
        : wrong
        ? AppTheme.red
        : selected
        ? AppTheme.purple
        : const Color(0xFFDCD3E8);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected || correct
            ? color.withValues(alpha: 0.08)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text(
                  String.fromCharCode(65 + index),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (correct || wrong || selected)
                  Icon(
                    correct
                        ? Icons.check_circle
                        : wrong
                        ? Icons.cancel
                        : Icons.radio_button_checked,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
