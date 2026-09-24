import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

/// Page chrome with back control fixed to the physical top-left.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.ink,
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.champagne,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
