/// LOCAL CONFIGURATION TEMPLATE
/// 
/// DO NOT COMMIT THIS FILE IF YOU ADD REAL SECRETS
/// 
/// To set up local development with your API keys:
/// 1. Copy this file: cp api_key_config.local.example.dart api_key_config.local.dart
/// 2. Replace the placeholder values with your actual API keys
/// 3. The .local.dart files are in .gitignore and won't be committed
/// 
/// For production/CI builds, use environment variables or dart-define instead:
/// flutter build web --dart-define=YARNGPT_API_KEY='your-key'

// Example of how you COULD load from a local file (NOT RECOMMENDED for secrets):
// 
// class ApiKeyConfig {
//   static const String _localYarnGptKey = 'sk_live_YOUR_KEY_HERE';
//   
//   static String getYarnGptApiKey() {
//     // Environment variable takes priority (recommended)
//     final envApiKey = const String.fromEnvironment(
//       'YARNGPT_API_KEY',
//       defaultValue: '',
//     );
//     
//     if (envApiKey.isNotEmpty) {
//       return envApiKey;
//     }
//     
//     // Local file only for development (should be .gitignored)
//     return _localYarnGptKey;
//   }
// }
