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


  final List<Widget> _screens =  [

    const HomeScreen(),

    CalendarTabScreen(),

    const EducationHubScreen(),

    const SupportScreen(),

  ];

void changeTab(int index) {
  setState(() {
    _currentIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: IndexedStack(

        index: _currentIndex,

        children: _screens,

      ),



      bottomNavigationBar: BottomNavigationBar(


        currentIndex: _currentIndex,


        onTap: (index){

          setState((){

            _currentIndex = index;

          });

        },


        type:
        BottomNavigationBarType.fixed,


        selectedItemColor:
        const Color(0xff16A6A6),


        unselectedItemColor:
        Colors.grey,


        items:[


          const BottomNavigationBarItem(

            icon:
            Icon(Icons.home_outlined),

            activeIcon:
            Icon(Icons.home),

            label:"Home",

          ),



          const BottomNavigationBarItem(

            icon:
            Icon(Icons.calendar_today_outlined),

            activeIcon:
            Icon(Icons.calendar_today),

            label:"Calendar",

          ),



          const BottomNavigationBarItem(

            icon:
            Icon(Icons.menu_book_outlined),

            activeIcon:
            Icon(Icons.menu_book),

            label:"Learn",

          ),



          const BottomNavigationBarItem(

            icon:
            Icon(Icons.support_agent_outlined),

            activeIcon:
            Icon(Icons.support_agent),

            label:"Support",

          ),


        ],

      ),


    );


  }

}