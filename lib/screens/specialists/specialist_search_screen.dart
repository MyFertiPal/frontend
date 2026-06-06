import 'package:flutter/material.dart';
import '../payment/payment_screen.dart';

class SpecialistSearchScreen extends StatelessWidget {
  const SpecialistSearchScreen({super.key});

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
        backgroundColor: const Color(0xFF0EA5A4),
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
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF0EA5A4)),
                  suffixIcon: const Icon(Icons.tune, color: Color(0xFF0EA5A4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming soon')),
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _CategoryChip(label: 'Fertility'),
                  _CategoryChip(label: 'Gynecology'),
                  _CategoryChip(label: 'Mental Health'),
                  _CategoryChip(label: 'Nutrition'),
                ],
              ),
              const SizedBox(height: 20),
              if (specialists.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48.0, bottom: 24.0),
                  child: Text(
                    'No specialists found. Please check back later.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...specialists.map((sp) => _SpecialistCard(data: sp)).toList(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5A4).withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0EA5A4).withOpacity(0.2)),
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
  const _SpecialistCard({required this.data});

  static const Color _darkGreen = Color(0xFF0F5132);

  void _openPaymentScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.lock,
                color: _darkGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Premium Feature',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Upgrade to premium to chat with specialists and get personalized advice.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: Colors.grey),
              ),
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
                backgroundColor: const Color(0xFF0EA5A4),
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

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0EA5A4).withOpacity(0.12),
            ),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0EA5A4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 16,
                          color: Color(0xFF0EA5A4),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: Color(0xFF0EA5A4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _openPaymentScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Premium overlay
        _LockedOverlay(
          onTap: () => _showPremiumDialog(context),
        ),
      ],
    );
  }
}
