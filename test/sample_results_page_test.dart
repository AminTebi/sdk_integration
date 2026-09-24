import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenai_skd_integration/demo/mock_health_data.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/pages/results_page.dart';
import 'package:shenai_skd_integration/theme/app_theme.dart';
import 'package:shenai_skd_integration/widgets/health_report_section.dart';

void main() {
  testWidgets('sample results page renders report', (tester) async {
    final results = MockHealthData.measurementResults();
    final profile = MockHealthData.profile(results: results);
    final risks = MockHealthData.healthRisks();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fa', 'IR')],
        home: ResultsPage(
          results: results,
          initialProfile: profile,
          initialRisks: risks,
          useMockRisks: true,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.yourVitals), findsOneWidget);

    // ListView may lazy-build; scroll to bring report onstage.
    await tester.scrollUntilVisible(
      find.text(AppStrings.healthRiskIndices),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.healthRiskIndices), findsOneWidget);
    expect(find.byType(HealthReportSection), findsOneWidget);
  });
}
