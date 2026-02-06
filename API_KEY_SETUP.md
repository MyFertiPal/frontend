# API Key Configuration

This guide explains how to manage API keys securely in the Fertipath app.

## Security Best Practices

**NEVER commit API keys to version control.** They are secrets and should be treated as such.

## For Local Development

### Option 1: Environment Variables (Recommended)

Set the API key as an environment variable before running:

```bash
export YARNGPT_API_KEY='your-api-key-here'
flutter run
```

Or in one line:

```bash
YARNGPT_API_KEY='your-api-key-here' flutter run
```

For web development:

```bash
YARNGPT_API_KEY='your-api-key-here' flutter run -d web-server
```

### Option 2: flutter run with dart-define

```bash
flutter run --dart-define=YARNGPT_API_KEY='your-api-key-here'
```

Or for web:

```bash
flutter run -d web-server --dart-define=YARNGPT_API_KEY='your-api-key-here'
```

## For Production/Build

### Option 1: Build-time dart-define

```bash
flutter build web --dart-define=YARNGPT_API_KEY='your-production-key'
```

### Option 2: Android APK Build

```bash
flutter build apk --release --dart-define=YARNGPT_API_KEY='your-production-key'
```

### Option 3: Environment Variables on Deployment

Set environment variables on your deployment platform:
- Netlify: Site settings → Build & deploy → Environment
- Vercel: Project settings → Environment Variables
- GitHub Actions: Settings → Secrets and variables → Actions
- Google Cloud Build: Cloud Build configuration

### Option 4: Secret Management Services

For enterprise deployments:
- Firebase Secrets (Google Cloud Secret Manager)
- AWS Secrets Manager
- Azure Key Vault
- Vault (HashiCorp)

## Configuration Files

The `.gitignore` file includes:
- `*.local.dart` - Local Dart configuration files
- `.env.local` - Environment variable files

These files will NOT be committed to version control.

## Code Implementation

The `ApiKeyConfig` class looks for API keys in this order:

1. **Environment variable** (`YARNGPT_API_KEY`) - Best for both local and production
2. **Runtime dynamic setting** (`ApiKeyConfig.setTestApiKey()`) - For testing only
3. **Throws error** - If no key is found

Example in code:

```dart
// This will automatically use the environment variable if set
final apiKey = ApiKeyConfig.getYarnGptApiKey();
```

## Troubleshooting YarnGPT API Errors

### 403 Forbidden Error

If you're getting a **403 Forbidden** error from YarnGPT API:

1. **Verify API Key Format**
   - Ensure the key is exactly: `sk_live_YOUR_KEY_HERE`
   - No extra spaces or quotes
   - Full key is passed (not truncated)

2. **Check API Key Validity**
   - Log in to YarnGPT dashboard: https://yarngpt.ai
   - Go to API Keys section
   - Verify the key is active and not revoked
   - Check if the key has expired

3. **Verify Permissions**
   - Ensure the API key has permission for TTS (Text-to-Speech)
   - Some keys may have restricted scopes
   - Contact YarnGPT support if permissions are limited

4. **Check Endpoint**
   - Current endpoint: `https://yarngpt.ai/api/v1/tts`
   - Verify this is the correct endpoint for your API key tier
   - Some API keys may have different endpoints

5. **Review Request Format**
   - The app sends: `Authorization: Bearer {YARNGPT_API_KEY}`
   - Headers: `Content-Type: application/json`
   - Body format: `{text, voice, response_format}`

6. **Debug Output**
   - Check Flutter console logs for detailed error response
   - The app will show the full API error in debug logs
   - Example: `YarnGPT API error: 403 - {error details}`

### 401 Unauthorized Error

If you're getting a **401 Unauthorized** error:

1. API key is invalid or expired
2. Try regenerating a new key in YarnGPT dashboard
3. Make sure you're passing the complete key without modifications

## If You Accidentally Committed a Secret

If a secret was committed to git:

```bash
# Rotate the secret immediately
# Remove it from git history
git filter-branch --tree-filter 'rm -f lib/services/api_key_config.dart' HEAD

# Force push (dangerous, coordinate with team)
git push --force-with-lease origin main
```

Or use GitHub's secret scanning to automatically detect and alert on leaked keys.

## Current Status

✅ No secrets hardcoded in source code  
✅ `.gitignore` configured to ignore local config files  
✅ Environment variable approach set up  
✅ Ready for secure CI/CD deployment  

## Support

For YarnGPT API issues:
- Visit: https://yarngpt.ai
- Contact: support@yarngpt.ai
- Check API documentation: https://docs.yarngpt.ai
