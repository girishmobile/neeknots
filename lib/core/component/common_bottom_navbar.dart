import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(20),
          child: BottomNavigationBar(
            backgroundColor: themeProvider.isDark
                ? colorDarkBgColor
                : Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: true,

            unselectedLabelStyle: commonTextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            selectedLabelStyle: commonTextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            iconSize: 20,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: themeProvider.isDark ? Colors.white : colorLogo,
            unselectedItemColor: Colors.grey,
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
          ),
        );
      },
    );
  }
}
