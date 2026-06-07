import '../config/yarn_gpt_config.dart';

/// Secure API Key Configuration.
class ApiKeyConfig {
  static String getApiKey() {
    return YarnGptConfig.apiKey;
  }
}
