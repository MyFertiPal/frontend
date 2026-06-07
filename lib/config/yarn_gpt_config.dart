library yarn_gpt_config;


class YarnGptConfig {
  static String get apiKey {
    const envApiKey = String.fromEnvironment('YARNGPT_API_KEY');

    if (envApiKey.isNotEmpty) {
      return envApiKey;
    }

    throw StateError(
      'YARNGPT_API_KEY is not set in environment variables',
    );
  }
}