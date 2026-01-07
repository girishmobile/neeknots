
import 'package:flutter/cupertino.dart';

import '../feature/admin/all_store_page.dart';

class AdminMenuProvider extends ChangeNotifier {
  // 🔹 Default selected menu
  String _selectedMenu = 'All Store';
  String get selectedMenu => _selectedMenu;

  // 🔹 Common menu items
  final List<String> _menuItems = ['All Store', 'Orders', 'Products'];
  List<String> get menuItems => _menuItems;

  // 🔹 Update selected menu and notify listeners
  void setSelectedMenu(String menu) {
    _selectedMenu = menu;

    notifyListeners();
  }

  final Widget _currentPage = const AllStorePage(); // Default page
  Widget get currentPage => _currentPage;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}