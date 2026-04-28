import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import 'onboarding_screens.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedCode;
  bool _isSaving = false;

  List<Map<String, String>> _languages(BuildContext context) => [
        {'code': 'en', 'name': 'English'},
        {'code': 'ig', 'name': 'Igbo'},
        {'code': 'yo', 'name': 'Yoruba'},
        {'code': 'ha', 'name': 'Hausa'},
        {'code': 'pcm', 'name': 'Pidgin'},
      ];

  void _handleSelect(String code) {
    setState(() => _selectedCode = code);
  }

  Future<void> _handleNext(BuildContext context) async {
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).pleaseSelectLanguage)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save language preference locally
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      await languageProvider.setLanguage(_selectedCode!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).languageSelected),
            duration: const Duration(seconds: 1),
          ),
        );

        // Navigate to onboarding screens
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreens()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langs = _languages(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF224D2D),
              Color(0xFF4FB369),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).selectPreferredLanguage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ...langs.map((lang) {
                      final isSelected = _selectedCode == lang['code'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 250,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _handleSelect(lang['code']!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xFF0EA5A4)
                                  : Colors.white,
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : const Color(0xFF224D2D),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF0EA5A4)
                                    : const Color(0x33224D2D),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF224D2D),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: SizedBox(
                          width: 99,
                          height: 47,
                          child: ElevatedButton(
                            onPressed:
                                _isSaving ? null : () => _handleNext(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0EA5A4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context).next,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
