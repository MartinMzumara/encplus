import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      selectedItemColor: Colors.blueGrey,
      unselectedItemColor: Colors.grey,
    );
  }
}
