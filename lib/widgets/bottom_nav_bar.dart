import 'package:flutter/material.dart';
import 'package:instagram_flutter/enums/enums.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar(
      {super.key,
      required this.items,
      required this.selectedItem,
      required this.onTap});

  final Map<BottomNavItem, (IconData, IconData)> items;
  final BottomNavItem selectedItem;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: BottomNavItem.values.indexOf(selectedItem),
      items: items
          .map((item, icon) => MapEntry(
              item.toString(),
              BottomNavigationBarItem(
                  activeIcon: Icon(icon.$2),
                  icon: Icon(
                    icon.$1,
                  ),
                  label: '')))
          .values
          .toList(),
      onTap: onTap,
    );
  }
}
