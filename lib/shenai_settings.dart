import 'package:shenai_sdk/pigeon.dart';

/// Initialization settings for a custom Flutter UI.
///
/// Hides Shen's built-in controls/screens while keeping the camera preview
/// available through [ShenaiView].
InitializationSettings customUiInitializationSettings() {
  return InitializationSettings(
    precisionMode: PrecisionMode.relaxed,
    operatingMode: OperatingMode.measure,
    measurementPreset: MeasurementPreset.thirtySecondsAllMetrics,
    cameraMode: CameraMode.facingUser,
    onboardingMode: OnboardingMode.hidden,
    showUserInterface: false,
    showFacePositioningOverlay: true,
    showVisualWarnings: true,
    enableCameraSwap: false,
    showFaceMask: true,
    showBloodFlow: false,
    enableStartAfterSuccess: false,
    enableSummaryScreen: false,
    showResultsFinishButton: false,
    enableHealthRisks: true,
    showHealthIndicesFinishButton: false,
    saveHealthRisksFactors: true,
    showOutOfRangeResultIndicators: false,
    applyPrecisionModeToBloodPressure: false,
    showSignalQualityIndicator: false,
    showSignalTile: false,
    showStartStopButton: false,
    showInfoButton: false,
    showDisclaimer: false,
    uiVersion: UiVersion.v2,
  );
}
