import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_sdk/shenai_sdk.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/demo/mock_health_data.dart';
import 'package:shenai_skd_integration/pages/measure_page.dart';
import 'package:shenai_skd_integration/pages/results_page.dart';
import 'package:shenai_skd_integration/shenai_config.dart';
import 'package:shenai_skd_integration/shenai_settings.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/theme/app_theme.dart';
import 'package:shenai_skd_integration/widgets/atmosphere_background.dart';
import 'package:shenai_skd_integration/widgets/luxury_button.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.canvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  runApp(const ShenaiApp());
}

bool get _isSupportedMobilePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class ShenaiApp extends StatelessWidget {
  const ShenaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const StartupPage(),
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with SingleTickerProviderStateMixin {
  bool _isBusy = false;
  String _status = AppStrings.statusReady;
  String? _error;

  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<PermissionStatus> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) {
      return status;
    }
    if (status.isPermanentlyDenied) {
      return status;
    }
    return Permission.camera.request();
  }

  Future<void> _start() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
      _status = AppStrings.statusChecking;
    });

    try {
      if (ShenaiConfig.apiKey.isEmpty) {
        setState(() {
          _error = AppStrings.errorMissingApiKey;
        });
        return;
      }

      if (!_isSupportedMobilePlatform) {
        setState(() {
          _error = AppStrings.errorUnsupportedPlatform;
        });
        return;
      }

      setState(() => _status = AppStrings.statusCameraPermission);
      final status = await _requestCameraPermission();
      if (!mounted) {
        return;
      }

      if (!(status.isGranted || status.isLimited)) {
        setState(() {
          _error = status.isPermanentlyDenied
              ? AppStrings.errorCameraPermanentlyDenied
              : AppStrings.errorCameraDenied;
        });
        return;
      }

      setState(() => _status = AppStrings.statusInitializing);
      final result = await ShenaiSdk.initialize(
        ShenaiConfig.apiKey,
        ShenaiConfig.userId,
        settings: customUiInitializationSettings(),
      );

      if (!mounted) {
        return;
      }

      if (result != InitializationResult.success) {
        setState(() => _error = AppStrings.errorInitFailed(result.name));
        return;
      }

      setState(() => _status = AppStrings.statusOpeningScan);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const MeasurePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Startup failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() => _error = AppStrings.errorStartup(error));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _openSampleReport() async {
    final results = MockHealthData.measurementResults();
    final profile = MockHealthData.profile(results: results);
    final risks = MockHealthData.healthRisks();

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultsPage(
          results: results,
          initialProfile: profile,
          initialRisks: risks,
          useMockRisks: true,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  Future<void> _retry() async {
    final status = await Permission.camera.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = _error != null;

    return Scaffold(
      body: AtmosphereBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.brandMark,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.champagne,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      AppStrings.heroTitle,
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 40,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppStrings.heroSubtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.mist,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _StatusPill(
                      text: hasError ? _error! : _status,
                      isError: hasError,
                      isBusy: _isBusy,
                    ),
                    const Spacer(flex: 3),
                    LuxuryButton(
                      label: hasError
                          ? AppStrings.tryAgain
                          : AppStrings.beginScan,
                      icon: hasError
                          ? Icons.refresh_rounded
                          : Icons.bolt_rounded,
                      onPressed: _isBusy ? null : (hasError ? _retry : _start),
                      isLoading: _isBusy,
                    ),
                    const SizedBox(height: 12),
                    LuxuryButton(
                      label: AppStrings.viewSampleReport,
                      icon: Icons.auto_awesome_rounded,
                      style: LuxuryButtonStyle.secondary,
                      onPressed: _isBusy ? null : _openSampleReport,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.sampleReportHint,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.cameraPrivacyHint,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.isError,
    required this.isBusy,
  });

  final String text;
  final bool isError;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isError
            ? AppColors.coral.withValues(alpha: 0.08)
            : AppColors.surface,
        border: Border.all(
          color: isError
              ? AppColors.coral.withValues(alpha: 0.35)
              : AppColors.hairline,
        ),
      ),
      child: Row(
        children: [
          if (isBusy) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.champagneSoft,
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 18,
              color: isError ? AppColors.coral : AppColors.sage,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isError ? AppColors.coral : AppColors.mist,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
