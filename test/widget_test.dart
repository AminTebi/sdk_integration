import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/main.dart';

void main() {
  testWidgets('shows start screen before SDK init', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(const ShenaiApp());
      await tester.pump();

      expect(find.text(AppStrings.brandMark), findsWidgets);
      expect(find.text(AppStrings.beginScan), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
