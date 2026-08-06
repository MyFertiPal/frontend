import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// Colors used across the screen.
class _LogColors {
  static const headerBgTop = Color(0xFFE3F0E9);
  static const heading = Color(0xFF15503F);
  static const textMuted = Color(0xFF7C8580);
  static const bg = Color(0xFFF7F8F6);
  static const cardBorder = Color(0xFFE9ECE9);
  static const primary = Color(0xFF1F6A50);
  static const chipBg = Color(0xFFEFF3EF);
  static const chipSelectedBg = Color(0xFFDCEFE5);
  static const tipBg = Color(0xFFE3F0E9);
}

/// One symptom row: icon, label, and the sub-options revealed on selection.
/// If [options] is empty, a free-text field is shown instead of chips.
class SymptomData {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<String> options;
  final bool allowMultipleOptions;

  const SymptomData({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.options = const [],
    this.allowMultipleOptions = false,
  });
}

const List<SymptomData> defaultSymptoms = [
  SymptomData(
    id: 'mood',
    label: 'Mood',
    icon: Icons.sentiment_satisfied_alt,
    iconColor: Color(0xFFD8578A),
    iconBg: Color(0xFFFBE1EC),
    options: ['Happy', 'Sad', 'Anxious', 'Irritable', 'Calm', 'Energetic'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'bleeding',
    label: 'Bleeding',
    icon: Icons.water_drop,
    iconColor: Color(0xFFD8365A),
    iconBg: Color(0xFFFBDDE4),
    options: ['Spotting', 'Light', 'Medium', 'Heavy'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'cervical_mucus',
    label: 'Cervical Mucus',
    icon: Icons.water_drop_outlined,
    iconColor: Color(0xFF6E7BC7),
    iconBg: Color(0xFFE7E9F8),
    options: ['Dry', 'Sticky', 'Creamy', 'Watery', 'Egg white'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'sexual_activity',
    label: 'Sexual Activity',
    icon: Icons.favorite_border,
    iconColor: Color(0xFFD8578A),
    iconBg: Color(0xFFFBE1EC),
    options: ['Protected', 'Unprotected', 'None'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'pain',
    label: 'Pain',
    icon: Icons.bolt,
    iconColor: Color(0xFFCB8A2C),
    iconBg: Color(0xFFFBEDD2),
    options: ['Headache', 'Back pain', 'Breast tenderness', 'Ovulation pain'],
    allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'abdominal_cramps',
    label: 'Abdominal Cramps',
    icon: Icons.waves,
    iconColor: Color(0xFFCB8A2C),
    iconBg: Color(0xFFFBEDD2),
    options: ['Mild', 'Moderate', 'Severe'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'sleep',
    label: 'Sleep',
    icon: Icons.bedtime_outlined,
    iconColor: Color(0xFF3B8AD8),
    iconBg: Color(0xFFDCEBFB),
    options: ['Good', 'Poor', 'Insomnia', 'Oversleeping'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'appetite',
    label: 'Appetite',
    icon: Icons.eco_outlined,
    iconColor: Color(0xFF1F9E75),
    iconBg: Color(0xFFDCF3E8),
    options: ['Increased', 'Decreased', 'Normal', 'Cravings'],
     allowMultipleOptions: true,
  ),
  SymptomData(
    id: 'other',
    label: 'Other',
    icon: Icons.more_horiz,
    iconColor: Color(0xFF1F9E75),
    iconBg: Color(0xFFDCF3E8),
  ),
];

/// Result of logging: symptom id -> selected sub-options (or free text).
typedef SymptomLogResult = Map<String, Set<String>>;


class LogSymptomsScreen extends StatefulWidget {
  final List<SymptomData> symptoms;
  final ValueChanged<SymptomLogResult>? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onBack;

  const LogSymptomsScreen({
    super.key,
    this.symptoms = defaultSymptoms,
    this.onSave,
    this.onCancel,
    this.onBack,
  });

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  final ApiService _apiService = ApiService();
  final Set<String> _selectedSymptomIds = {};
  final Map<String, Set<String>> _optionSelections = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String id) =>
      _textControllers.putIfAbsent(id, () => TextEditingController());

  void _toggleSymptom(SymptomData symptom) {
    setState(() {
      if (_selectedSymptomIds.contains(symptom.id)) {
        _selectedSymptomIds.remove(symptom.id);
        _optionSelections.remove(symptom.id);
      } else {
        _selectedSymptomIds.add(symptom.id);
        _optionSelections.putIfAbsent(symptom.id, () => {});
      }
    });
  }

  void _toggleOption(SymptomData symptom, String option) {
    setState(() {
      final selections = _optionSelections.putIfAbsent(symptom.id, () => {});
      if (selections.contains(option)) {
        selections.remove(option);
      } else {
        if (!symptom.allowMultipleOptions) selections.clear();
        selections.add(option);
      }
    });
  }

 Future<void> _handleSave() async {
  final result = <String, Set<String>>{};

  for (final id in _selectedSymptomIds) {
    final symptom = widget.symptoms.firstWhere((s) => s.id == id);

    if (symptom.options.isEmpty) {
      final text = _controllerFor(id).text.trim();
      result[id] = text.isEmpty ? {} : {text};
    } else {
      result[id] = _optionSelections[id] ?? {};
    }
  }

  // Convert selections into one list of strings
  final List<String> symptoms = [];

  result.forEach((category, values) {
    if (values.isEmpty) {
      symptoms.add(category);
    } else {
      for (final value in values) {
        symptoms.add(
  "${category.toLowerCase()}: ${value.toLowerCase()}",
);
      }
    }
  });

  // Notes from the "Other" field
  String notes = "";
  if (_textControllers.containsKey("other")) {
    notes = _controllerFor("other").text.trim();
  }

  try {
    await _apiService.saveSymptoms(
      symptoms: symptoms,
      severity: 0,
      notes: notes,
    );

    widget.onSave?.call(result);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text( AppLocalizations.of(context).symptomsSaved,),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to save symptoms: $e"),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: _LogColors.bg,
  body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Text(
                        AppLocalizations.of(context).selectSymptomsToLog,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _LogColors.heading,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        AppLocalizations.of(context).chooseMoreThanOne,
                        style: TextStyle(fontSize: 13, color: _LogColors.textMuted),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (final symptom in widget.symptoms) ...[
                            _SymptomCard(
                              symptom: symptom,
                              isSelected: _selectedSymptomIds.contains(symptom.id),
                              selectedOptions:
                                  _optionSelections[symptom.id] ?? const {},
                              textController: symptom.options.isEmpty
                                  ? _controllerFor(symptom.id)
                                  : null,
                              onTap: () => _toggleSymptom(symptom),
                              onOptionTap: (option) => _toggleOption(symptom, option),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: _buildTipBanner(),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  // ---- Header ---------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      color: _LogColors.headerBgTop,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: IconButton(
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: _LogColors.heading),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).logSymptomsTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _LogColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).trackHowYouFeel,
                    style: TextStyle(fontSize: 13, color: _LogColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Tip banner --------------------------------------------------------------

  Widget _buildTipBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LogColors.tipBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: _LogColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: _LogColors.heading, height: 1.4),
                children: const [
                  TextSpan(text: 'Tip: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text:
                        'Logging symptoms daily helps us give you more accurate insights.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Bottom action bar ----------------------------------------------------

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _LogColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onCancel ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close, size: 18, color: _LogColors.primary),
              label: Text( AppLocalizations.of(context).cancel,
                  style: TextStyle(color: _LogColors.primary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _LogColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _selectedSymptomIds.isEmpty ? null : _handleSave,
              icon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              label:  Text( AppLocalizations.of(context).saveSymptoms,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _LogColors.primary,
                disabledBackgroundColor: _LogColors.primary.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final SymptomData symptom;
  final bool isSelected;
  final Set<String> selectedOptions;
  final TextEditingController? textController;
  final VoidCallback onTap;
  final ValueChanged<String> onOptionTap;

  const _SymptomCard({
    required this.symptom,
    required this.isSelected,
    required this.selectedOptions,
    required this.textController,
    required this.onTap,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isSelected
            ? _LogColors.primary.withOpacity(0.4)
            : _LogColors.cardBorder,
      ),
    ),
    child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: symptom.iconBg, shape: BoxShape.circle),
                    child: Icon(symptom.icon, size: 18, color: symptom.iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      symptom.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _LogColors.heading,
                      ),
                    ),
                  ),
                  _CheckSquare(checked: isSelected),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                isSelected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: symptom.options.isEmpty
                  ? _buildTextField(context)
                  : _buildOptionChips(),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    )
  );}

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).describeFeeling,
        filled: true,
        fillColor: _LogColors.chipBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOptionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in symptom.options)
          _OptionChip(
            label: option,
            selected: selectedOptions.contains(option),
            onTap: () => onOptionTap(option),
          ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _LogColors.chipSelectedBg : _LogColors.chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _LogColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: _LogColors.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? _LogColors.primary : _LogColors.heading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckSquare extends StatelessWidget {
  final bool checked;

  const _CheckSquare({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? _LogColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? _LogColors.primary : const Color(0xFFC7CDC9),
          width: 1.5,
        ),
      ),
      child: checked ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
    );
  }
}