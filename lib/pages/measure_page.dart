import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_sdk/shenai_sdk.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/pages/results_page.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/atmosphere_background.dart';
import 'package:shenai_skd_integration/widgets/camera_preview_circle.dart';
import 'package:shenai_skd_integration/widgets/glass_card.dart';
import 'package:shenai_skd_integration/widgets/luxury_button.dart';
import 'package:shenai_skd_integration/widgets/metric_tile.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _isPolling = false;
  bool _appResumed = true;
  bool _showCamera = false;
  bool _isBusy = false;
  int _cameraViewGeneration = 0;

  MeasurementState? _measurementState;
  MeasurementResults? _realtimeMetrics;
  MeasurementResults? _results;
  MeasurementEnvironmentCondition? _violatedCondition;
  double _progress = 0;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ShenaiSdk.setEventCallback((event) {
      if (event == Event.measurementFinished && mounted) {
        setState(() => _hasFinished = true);
        unawaited(_refreshSdkState());
      }
    });
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => unawaited(_refreshSdkState()),
    );
    unawaited(_refreshSdkState());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) {
        return;
      }
      setState(() {
        _showCamera = _appResumed;
        _cameraViewGeneration++;
      });
      if (_showCamera) {
        unawaited(_setCameraMode(CameraMode.facingUser));
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setCameraMode(CameraMode.off));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncCameraVisibility();
  }

  void _syncCameraVisibility() {
    final shouldShow = _appResumed;
    if (_showCamera == shouldShow) {
      return;
    }
    setState(() {
      _showCamera = shouldShow;
      if (shouldShow) {
        _cameraViewGeneration++;
      }
    });
    unawaited(
      _setCameraMode(shouldShow ? CameraMode.facingUser : CameraMode.off),
    );
  }

  Future<void> _setCameraMode(CameraMode mode) async {
    try {
      await ShenaiSdk.setCameraMode(mode);
    } catch (_) {}
  }

  Future<T?> _safeRead<T>(Future<T> Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshSdkState() async {
    if (_isPolling || !mounted) {
      return;
    }
    _isPolling = true;
    try {
      final measurementState =
          await _safeRead(ShenaiSdk.getMeasurementState);
      final progress =
          await _safeRead(ShenaiSdk.getMeasurementProgressPercentage);
      final violatedCondition = await _safeRead(
        ShenaiSdk.getCurrentViolatedMeasurementEnvironmentCondition,
      );
      final realtimeMetrics =
          await _safeRead(() => ShenaiSdk.getRealtimeMetrics(10));
      final results = await _safeRead(ShenaiSdk.getMeasurementResults);

      if (!mounted) {
        return;
      }

      setState(() {
        _measurementState = measurementState;
        if (measurementState == MeasurementState.finished) {
          _hasFinished = true;
        }
        _progress = progress ?? _progress;
        _violatedCondition = violatedCondition;
        if (_isRunning(measurementState)) {
          _realtimeMetrics = realtimeMetrics ?? _realtimeMetrics;
        }
        if (_hasFinished || measurementState == MeasurementState.finished) {
          _results = results ?? _results;
        }
      });
    } finally {
      _isPolling = false;
    }
  }

  bool _isRunning(MeasurementState? state) {
    return state == MeasurementState.waitingForFace ||
        state == MeasurementState.runningSignalShort ||
        state == MeasurementState.runningSignalGood ||
        state == MeasurementState.runningSignalBad ||
        state == MeasurementState.runningSignalBadDeviceUnstable ||
        state == MeasurementState.finalizing;
  }

  Future<void> _startMeasurement() async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
      _hasFinished = false;
      _results = null;
      _realtimeMetrics = null;
      _progress = 0;
      _measurementState = null;
      _violatedCondition = null;
    });
    try {
      await ShenaiSdk.resetMeasurementSession();
      await ShenaiSdk.setOperatingMode(OperatingMode.measure);
      await ShenaiSdk.startMeasurement();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
      await _refreshSdkState();
    }
  }

  Future<void> _stopMeasurement() async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      await ShenaiSdk.stopMeasurement();
      await ShenaiSdk.resetMeasurementSession();
      if (!mounted) {
        return;
      }
      setState(() {
        _hasFinished = false;
        _results = null;
        _realtimeMetrics = null;
        _progress = 0;
        _measurementState = MeasurementState.notStarted;
        _violatedCondition = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _openResults() {
    final results = _results;
    if (results == null) {
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultsPage(results: results),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  String _statusText() {
    if (_hasFinished || _measurementState == MeasurementState.finished) {
      return AppStrings.scanComplete;
    }
    if (_measurementState == MeasurementState.finalizing) {
      return AppStrings.finalizingResults;
    }
    if (_violatedCondition != null) {
      return _conditionText(_violatedCondition!);
    }
    return switch (_measurementState) {
      MeasurementState.waitingForFace => AppStrings.centerFace,
      MeasurementState.runningSignalShort ||
      MeasurementState.runningSignalGood ||
      MeasurementState.runningSignalBad ||
      MeasurementState.runningSignalBadDeviceUnstable =>
        AppStrings.holdStill,
      MeasurementState.failed => AppStrings.scanFailed,
      MeasurementState.notStarted || null => AppStrings.readyToBegin,
      MeasurementState.finalizing => AppStrings.finalizing,
      MeasurementState.finished => AppStrings.finished,
    };
  }

  String _conditionText(MeasurementEnvironmentCondition condition) {
    return switch (condition) {
      MeasurementEnvironmentCondition.facePosition ||
      MeasurementEnvironmentCondition.foreheadVisible =>
        AppStrings.uncoverForehead,
      MeasurementEnvironmentCondition.glassesNotDetected =>
        AppStrings.removeGlasses,
      MeasurementEnvironmentCondition.sufficientLightLevel =>
        AppStrings.brighterLight,
      MeasurementEnvironmentCondition.evenLighting => AppStrings.evenLighting,
      MeasurementEnvironmentCondition.noBacklight => AppStrings.avoidBacklight,
      MeasurementEnvironmentCondition.faceStable => AppStrings.keepFaceStill,
      MeasurementEnvironmentCondition.deviceStable => AppStrings.keepPhoneStill,
    };
  }

  String _metric(double? value, {int decimals = 0}) {
    if (value == null) {
      return '—';
    }
    return value.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    final running = _isRunning(_measurementState);
    final display = _results ?? _realtimeMetrics;
    final canOpenResults = _hasFinished && _results != null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Text(
                      AppStrings.liveScan,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.champagne,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: running
                            ? AppColors.sage.withValues(alpha: 0.1)
                            : AppColors.surface,
                        border: Border.all(
                          color: running
                              ? AppColors.sage.withValues(alpha: 0.4)
                              : AppColors.hairline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: running
                                  ? AppColors.sage
                                  : AppColors.muted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            running ? AppStrings.active : AppStrings.idle,
                            style: textTheme.labelSmall?.copyWith(
                              color: running
                                  ? AppColors.sageSoft
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    Center(
                      child: CameraPreviewCircle(
                        showCamera: _showCamera,
                        cameraViewKey: ValueKey(_cameraViewGeneration),
                        placeholder:
                            _showCamera ? null : AppStrings.preparingCamera,
                        progress: _progress,
                        isActive: running,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlassCard(
                      highlight: canOpenResults,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      child: Column(
                        children: [
                          Text(
                            _statusText(),
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_progress.toStringAsFixed(0)}%',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.champagneSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: LuxuryButton(
                            label: AppStrings.start,
                            icon: Icons.play_arrow_rounded,
                            onPressed: (!_isBusy && !running)
                                ? _startMeasurement
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LuxuryButton(
                            label: AppStrings.stop,
                            icon: Icons.stop_rounded,
                            style: LuxuryButtonStyle.secondary,
                            onPressed: (!_isBusy && running)
                                ? _stopMeasurement
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (canOpenResults) ...[
                      const SizedBox(height: 12),
                      LuxuryButton(
                        label: AppStrings.viewResults,
                        icon: Icons.auto_awesome_rounded,
                        onPressed: _openResults,
                      ),
                    ],
                    const SizedBox(height: 28),
                    const SectionEyebrow(AppStrings.liveMetrics),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        MetricTile(
                          label: AppStrings.heartRate,
                          value: _metric(display?.heart_rate_bpm),
                          unit: AppStrings.unitBpm,
                          accent: AppColors.coral,
                          icon: Icons.favorite_rounded,
                        ),
                        MetricTile(
                          label: AppStrings.systolic,
                          value: _metric(
                            display?.systolic_blood_pressure_mmhg,
                          ),
                          unit: AppStrings.unitMmHg,
                          accent: AppColors.champagne,
                          icon: Icons.monitor_heart_outlined,
                        ),
                        MetricTile(
                          label: AppStrings.diastolic,
                          value: _metric(
                            display?.diastolic_blood_pressure_mmhg,
                          ),
                          unit: AppStrings.unitMmHg,
                          accent: AppColors.champagneSoft,
                          icon: Icons.monitor_heart_outlined,
                        ),
                        MetricTile(
                          label: AppStrings.breathing,
                          value: _metric(
                            display?.breathing_rate_bpm,
                            decimals: 1,
                          ),
                          unit: AppStrings.unitBrpm,
                          accent: AppColors.sage,
                          icon: Icons.air_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
