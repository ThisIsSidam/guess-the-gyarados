import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:guessthegyarados/pages/caught_mons_page.dart';

class HomeBottomNavBar extends ConsumerStatefulWidget {
  const HomeBottomNavBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeBottomNavBarState();
}

class _HomeBottomNavBarState extends ConsumerState<HomeBottomNavBar> {

  int _selectedIndex = 0;  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: Colors.black,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[100]!,
          color: Colors.black,
          tabs: const [
            GButton(
              icon: Icons.gamepad, // Icon for Play button
              text: 'Play',
            ),
            GButton(
              icon: Icons.catching_pokemon, // Icon for Caught button
              text: 'Caught',
            ),
            GButton(
              icon: Icons.coffee, 
              text: 'Third',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              // Navigate to the caught page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaughtPage()),
              );
            }
          },
        ),
      )
    );
  }
}