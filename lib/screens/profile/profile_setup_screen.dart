import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
 

const Color _primaryTeal = Color(0xFF0EA5A4);

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  int _age = 27;
  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime? _lastPeriodDate;
  List<String> _ttcHistory = [];
  String? _faithPreference;

  String _language = 'English';
  bool _audioGuidance = false;
  bool _isLoading = false;

  final List<String> _ttcHistories = [
    'Trying to Conceive',
    'Trying to Conceive - Default',
    'Preparing to conceive',
    'Just tracking my cycle',
    'TTC 6+ months',
    'TTC 12+ months',
    'Using fertility treatment',
    'Prefer not to say'
  ];

  final List<String> _faithPreferences = [
    'Christian',
    'Muslim',
    'Traditionalist',
    'Neutral'
  ];

  final List<String> _languages = [
    'English',
    'Yoruba',
    'Igbo',
    'Hausa',
    'Pidgin',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final user = auth.currentUser;

      if (user != null) {
        setState(() {
          _cycleLength = user.cycleLength ?? 28;
          _audioGuidance = user.audioGuidance ?? false;
          
          if (user.lastPeriodDate != null) {
            _lastPeriodDate = user.lastPeriodDate;
          }
          _ttcHistory = user.ttcHistory;
          _faithPreference = user.faithPreference;
          _language = _getLanguageDisplayName(user.preferredLanguage ?? 'en');
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).profileSetup,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
               AppLocalizations.of(context).updateProfile,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Customize your fertility tracking experience',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Age
              _buildFieldLabel(AppLocalizations.of(context).age),
              _buildNumberDropdown(
                value: _age,
                items: List.generate(73, (i) => i + 18),
                onChanged: (value) => setState(() => _age = value),
              ),
              const SizedBox(height: 20),

              // Cycle Length
              _buildFieldLabel(AppLocalizations.of(context).cycleLength),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _cycleLength,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(35, (i) => i + 1).map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days Days'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _cycleLength = value ?? 28);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).averageCycleDays,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Period Length
              _buildFieldLabel(AppLocalizations.of(context).periodLength),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _periodLength,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(14, (i) => i + 1).map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days Days'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _periodLength = value ?? _periodLength);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).typicalPeriodDays,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Last Period Date
             _buildFieldLabel(AppLocalizations.of(context).lastPeriodDate),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _lastPeriodDate == null
                              ? AppLocalizations.of(context).selectLastPeriodDate
                              : '${_lastPeriodDate!.day}, ${_getMonthName(_lastPeriodDate!.month)} ${_lastPeriodDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _lastPeriodDate == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).lastPeriodStartedInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // TTC History
              _buildFieldLabel(AppLocalizations.of(context).ttcHistory),
              _buildDropdown(
                value: _ttcHistory.isNotEmpty ? _ttcHistory.first : null,
                items: _ttcHistories,
                onChanged: (value) =>
                    setState(() => _ttcHistory = value != null ? [value] : []),
              ),
              const SizedBox(height: 20),

              // Faith Preference
              _buildFieldLabel(AppLocalizations.of(context).faithPreference),
              _buildDropdown(
                value: _faithPreference,
                items: _faithPreferences,
                onChanged: (value) => setState(() => _faithPreference = value),
              ),
              const SizedBox(height: 20),

              // Language
              _buildFieldLabel(AppLocalizations.of(context).language),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _language,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _languages.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _language = value);
                      // Language selection removed - using default
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Audio Guidance
              _buildFieldLabel(AppLocalizations.of(context).audioGuidance),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).enableAudioGuidance,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _audioGuidance,
                      activeColor: const Color(0xFF064B23),
                      onChanged: (value) {
                        setState(() {
                          _audioGuidance = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF064B23),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).updateProfile,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildNumberDropdown({
    required int value,
    required List<int> items,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: (val) => onChanged(val ?? value),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Select an option'),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
if (date != null) {
  setState(() {
    _lastPeriodDate = date;
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'last_period_date',
    date.toIso8601String(),
  );
}
  }

  String _getLanguageDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'yo':
        return 'Yoruba';
      case 'ig':
        return 'Igbo';
      case 'ha':
        return 'Hausa';
      case 'pcm':
        return 'Pidgin';
      default:
        return 'English';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _handleUpdate() async {
    final prefs = await SharedPreferences.getInstance();

if (_lastPeriodDate != null) {
  await prefs.setString(
    'last_period_date',
    _lastPeriodDate!.toIso8601String(),
  );
}
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      await apiService.updateProfile(
        age: _age,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
        lastPeriodDate: _lastPeriodDate != null
            ? _lastPeriodDate!.toIso8601String().split('T')[0]
            : null,
        ttcHistory: _ttcHistory.isNotEmpty ? _ttcHistory.first : null,
        faithPreference:
            (_faithPreference != null && _faithPreference!.isNotEmpty)
                ? _faithPreference
                : null,
        audioPreference: _audioGuidance,
      );
      final auth = Provider.of<AuthService>(
  context,
  listen: false,
);

await auth.refreshCurrentUser();

      await AnalyticsService.logAgeRange(_age);

      // Generate and save period days to calendar if last period date is set
      if (_lastPeriodDate != null) {
        await _generateAndSavePeriodDays();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: const Color(0xFF0EA5A4),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('unable to update profile. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateAndSavePeriodDays() async {
    if (_lastPeriodDate == null) return;

    try {
      // Generate period days based on last period date and period length
      final periodDays = List<DateTime>.generate(
        _periodLength,
        (i) => DateTime(
          _lastPeriodDate!.year,
          _lastPeriodDate!.month,
          _lastPeriodDate!.day + i,
        ),
      );

      // Convert to formatted strings
      final periodDaysFormatted = periodDays
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toSet()
          .toList();

      // Save to SharedPreferences for calendar to load
      final prefs = await SharedPreferences.getInstance();

await prefs.setString(
  'last_period_date',
  _lastPeriodDate!.toIso8601String(),
);

await prefs.setStringList(
  'tapped_days',
  periodDaysFormatted,
);

      debugPrint(
          'Generated and saved ${periodDays.length} period days starting from ${DateFormat('yyyy-MM-dd').format(_lastPeriodDate!)}');
    } catch (e) {
      debugPrint('Error generating period days: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
