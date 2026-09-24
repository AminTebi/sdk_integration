import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shenai_sdk/shenai_view.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

/// Circular camera preview with a clean progress ring.
class CameraPreviewCircle extends StatelessWidget {
  const CameraPreviewCircle({
    super.key,
    required this.showCamera,
    required this.cameraViewKey,
    this.placeholder,
    this.progress = 0,
    this.isActive = false,
  });

  final bool showCamera;
  final Key cameraViewKey;
  final String? placeholder;
  final double progress;
  final bool isActive;

  static const double _portraitCameraAspectRatio = 9 / 16;
  static const double dimension = 292;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(dimension),
            painter: _RingPainter(
              progress: (progress / 100).clamp(0.0, 1.0),
              active: isActive,
            ),
          ),
          SizedBox.square(
            dimension: dimension - 28,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipOval(
                  child: ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: showCamera
                        ? _CoveringCameraView(cameraViewKey: cameraViewKey)
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                placeholder ?? AppStrings.cameraUnavailable,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ),
                          ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.hairline,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const stroke = 3.0;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.hairline;

    canvas.drawCircle(center, radius, track);

    if (progress <= 0) {
      final idle = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.champagneSoft.withValues(alpha: 0.4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 0.4,
        false,
        idle,
      );
      return;
    }

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = active ? AppColors.sage : AppColors.champagneSoft;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}

class _CoveringCameraView extends StatelessWidget {
  const _CoveringCameraView({required this.cameraViewKey});

  final Key cameraViewKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final cameraHeight =
            side / CameraPreviewCircle._portraitCameraAspectRatio;
        return OverflowBox(
          alignment: Alignment.center,
          minWidth: side,
          maxWidth: side,
          minHeight: cameraHeight,
          maxHeight: cameraHeight,
          child: SizedBox(
            width: side,
            height: cameraHeight,
            child: KeyedSubtree(key: cameraViewKey, child: ShenaiView()),
          ),
        );
      },
    );
  }
}
