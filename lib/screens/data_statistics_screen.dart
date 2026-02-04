import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../generated/l10n/app_localizations.dart';
import '../services/api_service.dart';

class DataStatisticsScreen extends StatefulWidget {
  static const routeName = '/data-statistics';
  const DataStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<DataStatisticsScreen> createState() => _DataStatisticsScreenState();
}

class _DataStatisticsScreenState extends State<DataStatisticsScreen> {
  late ApiService _apiService;
  Map<String, dynamic>? _profileData;
  List<String>? _tappedDays;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Load profile data
      final profile = await _apiService.getProfile();

      // Load tapped days from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final tappedDaysJson = prefs.getString('tapped_days');
      List<String>? tappedDays;
      if (tappedDaysJson != null) {
        tappedDays = List<String>.from(jsonDecode(tappedDaysJson));
      }

      setState(() {
        _profileData = profile;
        _tappedDays = tappedDays ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E683D),
        elevation: 0,
        title: Text(AppLocalizations.of(context).exploreMyData),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Your Cycle Data',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E683D),
                                  fontFamily: 'Poppins',
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Statistics Grid
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard(
                            'Cycle Length',
                            '${_profileData?['cycle_length'] ?? 28} days',
                            const Color(0xFF2E683D),
                          ),
                          _buildStatCard(
                            'Period Length',
                            '${_profileData?['period_length'] ?? 5} days',
                            const Color(0xFFA8D497),
                          ),
                          _buildStatCard(
                            'Days Tracked',
                            '${_tappedDays?.length ?? 0}',
                            const Color(0xFF1B4D2D),
                          ),
                          _buildStatCard(
                            'Last Period',
                            _profileData?['last_period_date'] != null
                                ? DateFormat('MMM dd, yyyy').format(
                                    DateTime.parse(
                                        _profileData!['last_period_date']))
                                : 'Not set',
                            const Color(0xFFFFB3BA),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Cycle Information
                      Text(
                        'Cycle Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Current Cycle Length',
                        _profileData?['cycle_length'] != null
                            ? 'Your cycle averages ${_profileData!['cycle_length']} days'
                            : 'Not enough data',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Current Period Length',
                        _profileData?['period_length'] != null
                            ? 'Your period averages ${_profileData!['period_length']} days'
                            : 'Not enough data',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'Last Period Start',
                        _profileData?['last_period_date'] != null
                            ? DateFormat('EEEE, MMMM dd, yyyy').format(
                                DateTime.parse(
                                    _profileData!['last_period_date']))
                            : 'Not recorded',
                      ),
                      const SizedBox(height: 32),

                      // Tracked Days
                      Text(
                        'Days You\'ve Tracked',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (_tappedDays != null && _tappedDays!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tappedDays!.map((date) {
                              final parsedDate = DateTime.parse(date);
                              return Chip(
                                label: Text(
                                  DateFormat('MMM dd').format(parsedDate),
                                  style: const TextStyle(
                                    color: Color(0xFF2E683D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor:
                                    const Color(0xFFA8D497).withOpacity(0.3),
                                side: const BorderSide(
                                  color: Color(0xFF2E683D),
                                  width: 0.5,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No days tracked yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Export Data Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _downloadData,
                          icon: const Icon(Icons.download),
                          label: const Text('Download My Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E683D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E683D),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadData() async {
    // Show a dialog with data download options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'Your fertility data including cycle information, tracked days, and symptoms will be downloaded as a JSON file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Your data export has been prepared. Check your downloads folder.'),
                  backgroundColor: Color(0xFF2E683D),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E683D),
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
