import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

enum LuxuryButtonStyle { primary, secondary, ghost }

class LuxuryButton extends StatelessWidget {
  const LuxuryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = LuxuryButtonStyle.primary,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LuxuryButtonStyle style;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: style == LuxuryButtonStyle.primary
                  ? Colors.white
                  : AppColors.champagne,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20, color: _foreground),
          const SizedBox(width: 10),
        ],
        if (!isLoading)
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _foreground,
                  letterSpacing: 0,
                ),
          ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: switch (style) {
                LuxuryButtonStyle.primary => AppColors.champagneSoft,
                LuxuryButtonStyle.secondary => AppColors.surface,
                LuxuryButtonStyle.ghost => Colors.transparent,
              },
              border: style != LuxuryButtonStyle.primary
                  ? Border.all(color: AppColors.hairline)
                  : null,
              boxShadow: style == LuxuryButtonStyle.primary && enabled
                  ? [
                      BoxShadow(
                        color: AppColors.champagneSoft.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  Color get _foreground {
    return switch (style) {
      LuxuryButtonStyle.primary => Colors.white,
      LuxuryButtonStyle.secondary || LuxuryButtonStyle.ghost =>
        AppColors.ink,
    };
  }
}
