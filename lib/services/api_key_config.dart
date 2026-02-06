/// Secure API Key Configuration
///
/// This class handles loading API keys from environment variables
/// or secure configuration sources, preventing hardcoded secrets.
///
/// Usage:
/// final apiKey = ApiKeyConfig.getYarnGptApiKey();
class ApiKeyConfig {
  /// Get YarnGPT API Key from environment
  ///
  /// In production, this should be set via:
  /// - Environment variables
  /// - Secret management services (Firebase Secrets, AWS Secrets Manager, etc.)
  /// - Secure configuration files (not committed to version control)
  ///
  /// For development, set the YARNGPT_API_KEY environment variable
  static String getYarnGptApiKey() {
    final apiKey = const String.fromEnvironment(
      'YARNGPT_API_KEY',
      defaultValue: '', // Default to empty - will throw error if not set
    );

    if (apiKey.isEmpty) {
      throw StateError(
        'YarnGPT API Key not configured. '
        'Set YARNGPT_API_KEY environment variable or update ApiKeyConfig.',
      );
    }

    return apiKey;
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
