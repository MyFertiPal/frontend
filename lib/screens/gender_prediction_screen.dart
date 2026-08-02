import 'package:flutter/material.dart';
import "../../theme/app_colors.dart";

enum GenderExpectation { girl, boy, noPreference }

class GenderPredictionScreen extends StatefulWidget {
  const GenderPredictionScreen({super.key});

  @override
  State<GenderPredictionScreen> createState() =>
      _GenderPredictionScreenState();
}

class _GenderPredictionScreenState extends State<GenderPredictionScreen> {
  GenderExpectation? _selected;

  

  void _selectOption(GenderExpectation option) {
    setState(() => _selected = option);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GenderPredictionResultScreen(selection: option),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Gender Prediction',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Disclaimer card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECE3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF5C6A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFE0703A), width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                '!',
                                style: TextStyle(
                                  color: Color(0xFFE0703A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Important Disclaimer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFE0703A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'This feature uses AI to provide gender prediction advice. These predictions may not be fully accurate and should not replace professional medical advice. Please consult a qualified doctor for health decisions.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select your gender expectation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This helps personalize your insights and experience.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('💗', style: TextStyle(fontSize: 26)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _OptionCard(
                      title: 'Girl',
                      subtitle: "I'm hoping for a baby girl",
                      emoji: '👧',
                      accentColor: AppColors.pinkAccent,
                      backgroundColor: const Color(0xFFFCE4EC),
                      iconBackgroundColor: const Color(0xFFF8BBD0),
                      selected: _selected == GenderExpectation.girl,
                      onTap: () => _selectOption(GenderExpectation.girl),
                    ),
                    const SizedBox(height: 12),
                    _OptionCard(
                      title: 'Boy',
                      subtitle: "I'm hoping for a baby boy",
                      emoji: '👦',
                      accentColor: AppColors.teal,
                      backgroundColor: const Color(0xFFE3EBFB),
                      iconBackgroundColor: const Color(0xFFBBD6F8),
                      selected: _selected == GenderExpectation.boy,
                      onTap: () => _selectOption(GenderExpectation.boy),
                    ),
                    const SizedBox(height: 12),
                    _OptionCard(
                      title: 'No Preference',
                      subtitle: "I'm open to either",
                      emoji: '💚',
                      accentColor: AppColors.primaryDark,
                      backgroundColor: const Color(0xFFE3F1EA),
                      iconBackgroundColor: const Color(0xFFBFE0CD),
                      selected: _selected == GenderExpectation.noPreference,
                      onTap: () =>
                          _selectOption(GenderExpectation.noPreference),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                  color: selected ? accentColor : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple results screen shown after an option is tapped.
class GenderPredictionResultScreen extends StatelessWidget {
  final GenderExpectation selection;

  const GenderPredictionResultScreen({super.key, required this.selection});

  String get _label {
    switch (selection) {
      case GenderExpectation.girl:
        return 'Girl';
      case GenderExpectation.boy:
        return 'Boy';
      case GenderExpectation.noPreference:
        return 'No Preference';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FBF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B6E4F)),
        title: const Text(
          'Your Results',
          style: TextStyle(
            color: Color(0xFF0B6E4F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 56, color: Color(0xFFE91E63)),
              const SizedBox(height: 16),
              Text(
                'You selected: $_label',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B6E4F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is a placeholder results screen — replace with your prediction results UI.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}