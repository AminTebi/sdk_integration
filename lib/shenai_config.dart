/// Shen.AI credentials and identity used during SDK initialization.
///
/// Replace [apiKey] with your **Mobile** API key from the Shen AI Platform /
/// Customer Dashboard. Do not use a Web API key with this Flutter app.
///
/// Get credentials: https://developer.shen.ai/getting-started/authorization
///
/// Alternatively, pass the key at run time without editing this file:
/// `flutter run --dart-define=SHENAI_API_KEY=your_mobile_api_key`
class ShenaiConfig {
  ShenaiConfig._();

  /// 32-character hex Mobile API key tied to an active Shen AI license.
  ///
  /// REQUIRED — paste your key here, or provide `SHENAI_API_KEY` via
  /// `--dart-define`. Leave empty only while scaffolding.
  static const String apiKey = String.fromEnvironment(
    'SHENAI_API_KEY',
    defaultValue: '2daf85e3dbfb470191521d89185385e4',
  );

  /// Optional user id for per-user (manual) license attribution.
  ///
  /// Leave empty for per-use or automatic per-user billing.
  /// Do not pass personally identifiable information.
  static const String userId = String.fromEnvironment(
    'SHENAI_USER_ID',
    defaultValue: '',
  );
}



