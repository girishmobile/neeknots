import 'package:flutter/material.dart';

import '../feature/admin/admin_home_page.dart';

class AdminHomeProvider extends ChangeNotifier {
  int _selectedStoreIndex = 0;
  String? _selectedSection;
  final List<AdminUserModel> _users = [
    AdminUserModel(
      name: "Girish Chauhan",
      email: "girish@redefinesolution.com",
      phone: "9558697986",
      isActive: true,
    ),
    AdminUserModel(
      name: "Sameer Khan",
      email: "sammerkhan@example.com",
      phone: "9558697987",
      isActive: false,
    ),
    AdminUserModel(
      name: "Jane Smith",
      email: "jane@example.com",
      phone: "9558697988",
      isActive: true,
    ),
  ];
  final List<Map<String, dynamic>> dashboardItems = [
    {"title": "Users", "icon": Icons.people},
    {"title": "Orders", "icon": Icons.shopping_cart},
    {"title": "Products", "icon": Icons.inventory},
    {"title": "Contacts", "icon": Icons.contact_mail},
    {"title": "Filter", "icon": Icons.filter_alt},
  ];
  // Getters
  int get selectedStoreIndex => _selectedStoreIndex;
  String? get selectedSection => _selectedSection;
  List<AdminUserModel> get users => _users;

  // Methods
  void setSelectedStore(int index) {
    _selectedStoreIndex = index;
    _selectedSection = null;
    notifyListeners();
  }

  void setSelectedSection(String? section) {
    _selectedSection = section;
    notifyListeners();
  }

  void toggleUserStatus(int index, bool value) {
    _users[index].isActive = value;
    notifyListeners();
  }


}
