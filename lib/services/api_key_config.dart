import '../config/yarn_gpt_config.dart';

/// Secure API Key Configuration.
class ApiKeyConfig {
  static String getYarnGptApiKey() {
    return YarnGptConfig.apiKey;
  }

  static void setTestApiKey(String key) {
    YarnGptConfig.setTestApiKey(key);
  }

  static String? getTestApiKey() => YarnGptConfig.getTestApiKey();
}
