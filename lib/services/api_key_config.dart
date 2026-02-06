/// Secure API Key Configuration
///
/// This class handles loading API keys from environment variables
/// or secure configuration sources, preventing hardcoded secrets.
///
/// Usage:
/// final apiKey = ApiKeyConfig.getYarnGptApiKey();
///
/// For local development, set the YARNGPT_API_KEY environment variable:
/// export YARNGPT_API_KEY='your-api-key-here'
///
/// For production, set via:
/// - Flutter build: flutter build web --dart-define=YARNGPT_API_KEY='your-key'
/// - Environment variables on the deployment platform
/// - Secret management services (Firebase Secrets, AWS Secrets Manager, etc.)
class ApiKeyConfig {
  /// Get YarnGPT API Key from multiple sources (in order of priority):
  /// 1. Environment variable (YARNGPT_API_KEY)
  /// 2. Test/Development key (if set dynamically)
  ///
  /// For development, set the YARNGPT_API_KEY environment variable
  static String getYarnGptApiKey() {
    // Check environment variable first
    final envApiKey = const String.fromEnvironment(
      'YARNGPT_API_KEY',
      defaultValue: '',
    );

    if (envApiKey.isNotEmpty) {
      return envApiKey;
    }

    // Check if test/development key is set
    if (_testApiKey != null && _testApiKey!.isNotEmpty) {
      return _testApiKey!;
    }

    throw StateError(
      'YarnGPT API Key not configured. '
      'Set YARNGPT_API_KEY environment variable or dart-define. '
      'For local dev: export YARNGPT_API_KEY="your-key"',
    );
  }

  /// For development/testing: Set API key directly
  ///
  /// WARNING: Only use this for development!
  /// Never hardcode API keys in production code.
  static String? _testApiKey;

  static void setTestApiKey(String key) {
    _testApiKey = key;
  }

  static String? getTestApiKey() => _testApiKey;
}
