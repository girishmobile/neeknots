import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum RequestStatus { pending, accepted, rejected }

class DashboardProvider with ChangeNotifier {
  int _currentIndex = 2;

  int get currentIndex => _currentIndex;

  String? _appbarTitle;

  String? get appbarTitle => _appbarTitle;
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  set isFetching(bool value) {
    _isFetching = value;
    notifyListeners();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setAppBarTitle(String? value) {
    _appbarTitle = value;
    notifyListeners();
  }

  String _filter = "Month";

  String get filter => _filter;

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void resetTab() {
    _currentIndex = 2;
    _appbarTitle = null;
    _isFetching = false;
    _filter = "Month"; // 👈 default reset
    notifyListeners();
  }

  String? _name;

  String? get name => _name;

  void setName(String? value) {
    _name = value;
    notifyListeners();
  }
}
