import 'package:flutter/material.dart';
import '../payment/payment_screen.dart';

class SpecialistSearchScreen extends StatelessWidget {
  const SpecialistSearchScreen({super.key});

  static const Color _teal = Color(0xFF0EA5A4);
  static const Color _darkGreen = Color(0xFF0F5132);

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.lock,
                color: _darkGreen,
              ),
              SizedBox(width: 12),
              Text('Premium Feature'),
            ],
          ),
          content: const Text(
            'Upgrade to premium to chat with specialists and get personalized advice.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialists = const [
      {
        'name': 'Dr. Amara Obi',
        'role': 'Fertility Specialist',
        'location': 'Lekki, Lagos',
        'distance': '2.1 km away',
        'status': 'Available this week',
      },
      {
        'name': 'Dr. Yusuf Bello',
        'role': 'Gynecologist',
        'location': 'Abuja Central',
        'distance': '4.3 km away',
        'status': 'Accepting new patients',
      },
      {
        'name': 'Adaeze Nwosu',
        'role': 'Mental Health Counselor',
        'location': 'Ikeja, Lagos',
        'distance': '5.0 km away',
        'status': 'Next slot: Tomorrow',
      },
      {
        'name': 'Chinedu Okafor',
        'role': 'Nutritionist',
        'location': 'VI, Lagos',
        'distance': '6.8 km away',
        'status': 'Video consults available',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Specialist'),
        backgroundColor: _teal,
      ),
      backgroundColor: const Color(0xFFF5F5F0),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search specialists by name or specialty',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: _teal,
                  ),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: _teal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _CategoryChip(label: 'Fertility'),
                  _CategoryChip(label: 'Gynecology'),
                  _CategoryChip(label: 'Mental Health'),
                  _CategoryChip(label: 'Nutrition'),
                ],
              ),
              const SizedBox(height: 20),
              ...specialists
                  .map((sp) => _SpecialistCard(data: sp))
                  .toList(),
            ],
          ),

          _LockedOverlay(
            onTap: () => _showPremiumDialog(context),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5A4).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0EA5A4).withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0EA5A4),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final Map<String, String> data;

  const _SpecialistCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? '';
    final role = data['role'] ?? '';
    final location = data['location'] ?? '';
    final distance = data['distance'] ?? '';
    final status = data['status'] ?? '';

    String initials(String input) {
      final parts = input.trim().split(' ');

      if (parts.length == 1) {
        return parts.first.isNotEmpty
            ? parts.first[0].toUpperCase()
            : '?';
      }

      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0EA5A4),
            child: Text(
              initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF0EA5A4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(location),
                Text(distance),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF0F5132),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const _LockedOverlay({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 56,
                      color: Color(0xFF0F5132),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upgrade to Find specialist',
                      textAlign: TextAlign.center,
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
