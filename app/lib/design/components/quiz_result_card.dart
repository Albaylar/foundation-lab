import 'package:flutter/material.dart';
import '../tokens.dart';
import 'know_button.dart';

/// Shows the result of a quiz: score (e.g. 8/10), an encouraging message,
/// and a "Try again" action.
/// Example:
///   QuizResultCard(score: 8, total: 10, message: 'Great job!', onTryAgain: _restart)
class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    super.key,
    required this.score,
    required this.total,
    required this.message,
    required this.onTryAgain,
    this.tryAgainLabel = 'Try again',
  });

  final int score;
  final int total;
  final String message;
  final VoidCallback? onTryAgain;
  final String tryAgainLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radius.lg),
        side: BorderSide(color: t.colors.muted.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$score',
                    style: TextStyle(
                      color: t.colors.primary,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: TextStyle(
                      color: t.colors.muted,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: t.spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: t.spacing.lg),
            KnowButton.primary(label: tryAgainLabel, onPressed: onTryAgain),
          ],
        ),
      ),
    );
  }
}
