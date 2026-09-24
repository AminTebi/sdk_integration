import 'package:flutter/material.dart';

/// Navy / soft blue — calm, product-like (Stripe / Apple Health feel).
abstract final class AppColors {
  // Canvas & surfaces
  static const Color canvas = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F7);
  static const Color elevated = Color(0xFFFFFFFF);

  // Ink / type
  static const Color ink = Color(0xFF0F172A);
  static const Color mist = Color(0xFF475569);
  static const Color muted = Color(0xFF94A3B8);
  static const Color ivory = Color(0xFF0F172A);

  // Brand — deep navy primary, soft blue secondary accent
  static const Color champagne = Color(0xFF1E3A5F); // navy
  static const Color champagneSoft = Color(0xFF3B82F6); // soft blue
  static const Color champagneDim = Color(0xFF152A45);

  // Supporting
  static const Color sage = Color(0xFF0EA5E9); // sky — active / success-adjacent
  static const Color sageSoft = Color(0xFF38BDF8);
  static const Color coral = Color(0xFFEF4444);

  // Structure
  static const Color slate = Color(0xFFEEF2F7);
  static const Color charcoal = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFDCE3ED);

  static const LinearGradient atmosphere = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFF5F7FA),
      Color(0xFFEFF3F8),
    ],
  );

  static const LinearGradient primaryFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1E3A5F),
    ],
  );
}
