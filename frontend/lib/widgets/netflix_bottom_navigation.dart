import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../utils/utils.dart';

class NextflixBottomNavigation extends StatefulWidget {
  const NextflixBottomNavigation({super.key});

  @override
  State<NextflixBottomNavigation> createState() =>
      _NextflixBottomNavigationState();
}

class _NextflixBottomNavigationState extends State<NextflixBottomNavigation> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: bottomNavigationBarColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          activeIcon: Icon(LucideIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.film),
          activeIcon: Icon(LucideIcons.film),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.tv),
          activeIcon: Icon(LucideIcons.tv),
          label: 'Series',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _index,
      selectedItemColor: Colors.white,
      onTap: (value) {
        switch (value) {
          case 0:
            context.go('/home');
            break;
          case 1:
            // Navigate to home and request the movies section to be shown
            context.go('/home?section=movies');
            break;
          case 2:
            context.go('/home/tvshows');
            break;
        }
        setState(() {
          _index = value;
        });
      },
    );
  }
}
