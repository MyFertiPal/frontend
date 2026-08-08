import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/calendar_tab_screen.dart';
import '../screens/educational/educational_hub_screen.dart';
import '../screens/support/support_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  static _RootScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_RootScreenState>();
  }

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  // ------------------------------------------------------------
  // KEY FOR CALENDAR
  // ------------------------------------------------------------

  final GlobalKey<CalendarTabScreenState> _calendarKey =
      GlobalKey<CalendarTabScreenState>();

  // ------------------------------------------------------------
  // SCREENS
  // ------------------------------------------------------------

  late final List<Widget> _screens = [
    const HomeScreen(),

    CalendarTabScreen(
      key: _calendarKey,
    ),

    const EducationHubScreen(),

    const SupportScreen(),
  ];

  // ------------------------------------------------------------
  // CHANGE TAB
  // ------------------------------------------------------------

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh calendar whenever user opens it.
    if (index == 1) {
      _refreshCalendar();
    }
  }

  // ------------------------------------------------------------
  // REFRESH CALENDAR
  // ------------------------------------------------------------

  Future<void> _refreshCalendar() async {
    await _calendarKey.currentState?.refresh();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ----------------------------------------------------------
      // BOTTOM NAVIGATION
      // ----------------------------------------------------------

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        onTap: (index) {
          changeTab(index);
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xff16A6A6),

        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Learn",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: "Support",
          ),
        ],
      ),
    );
  }
}