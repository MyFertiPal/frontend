# 🩺 MyFertipal 

A comprehensive Flutter application for fertility tracking with a beautifully designed onboarding and account creation system.

## Android Signing

The permanent upload keystore is stored at `android/app/permanent-upload-keystore.jks`.

Current upload SHA1:

`CC:4A:3A:E7:E2:DA:41:38:1A:45:73:EA:D0:D6:23:9A:15:45:87:F7`

## ✨ Features

### 🌍 Multi-Language Support
- 4 fully translated languages: English, Spanish, French, Portuguese
- Dynamic language switching
- All UI text translated
- Language persistence

### 📝 Account Creation
- **Email-based signup** with password validation
- **Phone-based signup** with OTP verification
- Country code support for international users
- Comprehensive validation and error handling

### 🔐 Email/Phone Verification
- 6-digit OTP verification codes
- 5-minute countdown timers
- Resend code functionality
- Professional verification flow

### 👤 Profile Setup
- User information collection
- Photo upload (camera or gallery)
- Date of birth picker
- Gender selection
- Terms & conditions acceptance


## 🎯 Project Status

✅ **COMPLETE & PRODUCTION READY**

- ✅ Multi-language onboarding flows
- ✅ Email/phone verification
- ✅ Basic profile setup
- ✅ QA testing & comprehensive documentation
- ✅ 3,000+ lines of production-ready code
- ✅ 70+ test cases documented
- ✅ 4 languages supported


## 📱 Technologies

- Flutter 3.10.1+
- Provider (state management)
- Firebase Auth (ready)
- SharedPreferences (local storage)
- intl (localization)
- image_picker (photo upload)

---

## 📊 What's Included

| Component | Status |
|-----------|--------|
| 8 Onboarding Screens | ✅ |
| 4 Language Support | ✅ |
| Email/Phone Signup | ✅ |
| OTP Verification | ✅ |
| Profile Setup | ✅ |
| Unit Tests | ✅ |
| 70+ QA Test Cases | ✅ |
| Documentation | ✅ |

---

## 🎯 Getting Started

1. **Read QUICK_START.md** (5 minutes)
2. **Run `flutter run`** 
3. **Test the app** following the guides
4. **Review code** in lib/ folder
5. **Run tests** with `flutter test`

---

For detailed information, check the documentation files!

## Localization

This app supports exactly 4 languages:
- English (en) — primary
- Yoruba (yo)
- Igbo (ig)
- Hausa (ha)

Spanish, French, and Portuguese were intentionally removed.

How it is enforced:
- The repository should contain only ARB files for the allowed languages in `lib/l10n/` (app_en.arb, app_yo.arb, app_ig.arb, app_ha.arb).
- A GitHub Actions workflow (`.github/workflows/l10n-check.yml`) runs on PRs and will fail if any disallowed `app_*.arb` files are added.
- Application code must declare `supportedLocales` to the four locales above.

Merge & verification steps:
1. Create branch `language-restriction-final` from main.
2. Remove disallowed locale files from `lib/l10n/`.
3. Update `supportedLocales` in the app entry point to the 4 locales.
4. Run `flutter gen-l10n` and verify the app builds and all keys are present for the four locales.
5. Open a PR and request a review. The l10n-check Action will run automatically and block disallowed locales.
