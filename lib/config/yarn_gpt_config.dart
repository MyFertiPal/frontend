library yarn_gpt_config;


class YarnGptConfig {
  static String get apiKey {
    final envApiKey = const String.fromEnvironment(
      'YARNGPT_API_KEY',
      defaultValue: '',
    );

    if (envApiKey.isNotEmpty) {
      return envApiKey;
    }

    if (_localYarnGptApiKey.isNotEmpty) {
      return _localYarnGptApiKey;
    }

    if (_testApiKey != null && _testApiKey!.isNotEmpty) {
      return _testApiKey!;
    }

    throw StateError(
      'YarnGPT API Key not configured. '
      'Set YARNGPT_API_KEY or lib/config/yarn_gpt_config.local.dart.',
    );
  }

  static String? _testApiKey;

  static void setTestApiKey(String key) {
    _testApiKey = key;
  }

  static String? getTestApiKey() => _testApiKey;
}