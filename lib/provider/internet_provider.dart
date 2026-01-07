import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  InternetProvider() {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (results.contains(ConnectivityResult.none)) {
        _isConnected = false;
      } else {
        _isConnected = await InternetConnectionChecker().hasConnection;
      }
      notifyListeners();
    });
  }

  Future<void> checkNow() async {
    _isConnected = await InternetConnectionChecker().hasConnection;
    notifyListeners();
  }
}
