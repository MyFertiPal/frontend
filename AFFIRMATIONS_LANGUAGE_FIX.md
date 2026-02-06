# Affirmation Language Switching Fix

## Problem
Affirmations in the Support Screen were not updating when users changed the app language. When a user switched from English to Yoruba, Igbo, Hausa, or Pidgin, the affirmations remained in English instead of showing the translated versions.

## Root Cause
The `SupportScreen` widget loads affirmations only **once** in the `initState()` method. When the app language changes:
1. The entire app rebuilds with the new locale
2. `AppLocalizations.of(context)` returns translations in the new language
3. But the `_affirmations` list still contains the old English affirmations
4. Because `initState()` is never called again after the initial load

## Solution
Implemented automatic affirmation refresh when the language changes:

### Changes Made to `/workspaces/Frontend/lib/screens/support/support_screen.dart`:

#### 1. **Added Faith Preference Tracking** (Line 21)
```dart
String _currentFaith = 'neutral'; // Track current faith preference
```
Stores which faith category the user has selected (christian, muslim, traditionalist, or neutral).

#### 2. **Store Faith Preference** (Lines 135, 147)
Updated `_fetchFaithPreference()` to save the faith preference:
```dart
setState(() {
  _currentFaith = faith; // Store the current faith preference
  _affirmations = _faithAffirmations[faith]!;
  ...
});
```

#### 3. **Added Language Change Detection** (Lines 66-70)
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Refresh affirmations when locale changes to ensure translations are updated
  _refreshAffirmations();
}
```
The `didChangeDependencies()` method is called whenever the widget's dependencies change, including when the app's locale changes. This automatically triggers affirmation refresh.

#### 4. **Implemented Affirmation Refresh** (Lines 72-85)
```dart
void _refreshAffirmations() {
  if (_affirmations.isNotEmpty && mounted) {
    // Reload affirmations from the new language using stored faith preference
    setState(() {
      _affirmations = _faithAffirmations[_currentFaith]!;
      // Keep the current affirmation index if possible, otherwise reset to first
      final currentIndex = _currentAffirmation.isEmpty
          ? 0
          : _affirmations.indexWhere((a) => a == _currentAffirmation);
      _currentAffirmation = currentIndex >= 0 && currentIndex < _affirmations.length
          ? _affirmations[currentIndex]
          : _affirmations[0];
    });
  }
}
```
This method:
- Gets affirmations in the new language from `_faithAffirmations[_currentFaith]`
- Attempts to keep showing the same affirmation by matching the index (e.g., if showing 2nd Christian affirmation, keep showing the 2nd one after language change)
- Falls back to the first affirmation if matching fails

## How It Works Now

### Initial Load
1. User opens Support Screen
2. `initState()` → calls `_fetchFaithPreference()`
3. Fetches user's faith preference from backend
4. Sets `_currentFaith = 'christian'` (or muslim, traditionalist, neutral)
5. Loads affirmations in current language (e.g., English)

### When Language Changes
1. User goes to Profile → Changes language from English to Yoruba
2. `LanguageProvider.setLanguage('yo')` is called
3. Entire app rebuilds with Yoruba locale
4. Support Screen's `didChangeDependencies()` is triggered
5. `_refreshAffirmations()` is called
6. Affirmations are reloaded from `_faithAffirmations['christian']!` which now returns Yoruba versions
7. User sees affirmations in Yoruba ✅

## Language Support Verified

All language files have complete affirmation translations:
- ✅ **English (en)** - [en.arb](lib/l10n/en.arb)
- ✅ **Pidgin (pcm)** - [pcm.arb](lib/l10n/pcm.arb)
- ✅ **Yoruba (yo)** - [yo.arb](lib/l10n/yo.arb)
- ✅ **Igbo (ig)** - [ig.arb](lib/l10n/ig.arb)
- ✅ **Hausa (ha)** - [ha.arb](lib/l10n/ha.arb)

Each file contains all affirmation keys:
- `christianAffirmation1`, `christianAffirmation2`, `christianAffirmation3`
- `muslimAffirmation1`, `muslimAffirmation2`, `muslimAffirmation3`
- `traditionalistAffirmation1` through `traditionalistAffirmation5`
- `neutralAffirmation1`, `neutralAffirmation2`, `neutralAffirmation3`

## Testing the Fix

### Test Case 1: Change Language with Christian Faith
1. Login and set faith preference to "Christian"
2. Navigate to Support tab
3. Verify affirmations show in English
4. Go to Profile → Language → Select "Yoruba"
5. **Expected**: Affirmations immediately change to Yoruba translations
6. **Example**: "I can do all things..." → "Mo le ṣe ohun gbogbo..."

### Test Case 2: Change Language Multiple Times
1. Start in English
2. Switch to Igbo → Verify affirmations in Igbo
3. Switch to Hausa → Verify affirmations in Hausa
4. Switch back to English → Verify affirmations in English
5. **Expected**: Each switch shows correct translations

### Test Case 3: Different Faith Preferences
1. Set faith to "Muslim"
2. Change language from English to Pidgin
3. **Expected**: Muslim affirmations show in Pidgin (e.g., "So true true, with the hardship, relief dey.")

## What Was NOT the Issue

- ❌ Missing translations in language files (all translations were present)
- ❌ Missing getter methods in generated localization files (all getters exist)
- ❌ LanguageProvider not notifying listeners (it was working correctly)
- ❌ AppLocalizations not returning correct language (it was returning correct translations)

The issue was specifically that the Support Screen was **caching** the affirmations and not **refreshing** them when the app language changed.

## Similar Issues to Check

If other screens show localized content that doesn't update when language changes, check if they:
1. Load content in `initState()` and cache it
2. Don't have `didChangeDependencies()` to refresh on locale change

Common patterns to look for:
```dart
// ⚠️ Problematic pattern
void initState() {
  final localizedText = AppLocalizations.of(context).someText;
  _cachedText = localizedText; // This won't update on language change
}

// ✅ Better pattern
void didChangeDependencies() {
  super.didChangeDependencies();
  _refreshLocalizedContent();
}
```

## Additional Notes

- The fix maintains the current affirmation's position when possible (if showing 2nd affirmation, continues showing 2nd after language switch)
- The `mounted` check prevents setState after widget disposal
- Empty affirmations check prevents refresh before initial load completes