import 'package:flutter/material.dart';
import '../tokens.dart';

/// Primary call-to-action button. Use for the main action on a screen.
/// Variants: KnowButton.primary (filled) and KnowButton.secondary (outlined).
/// Example: KnowButton.primary(label: 'Start quiz', onPressed: _start)
class KnowButton extends StatelessWidget {
  const KnowButton.primary({super.key, required this.label, required this.onPressed})
      : _filled = true;
  const KnowButton.secondary({super.key, required this.label, required this.onPressed})
      : _filled = false;

  final String label;
  final VoidCallback? onPressed;
  final bool _filled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      side: BorderSide(color: t.colors.primary),
    );
    return Material(
      color: _filled ? t.colors.primary : t.colors.surface,
      shape: shape,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.lg, vertical: t.spacing.md),
          child: Text(
            label,
            style: TextStyle(
              color: _filled ? t.colors.surface : t.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}