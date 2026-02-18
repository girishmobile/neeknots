import 'dart:async';

import 'package:flutter/material.dart';

import '../core/firebase/auth_service.dart';

class SignupProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  /// Set loading
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Signup
  Future<void> signup({
    required String email,
    required String storeName,
    required String websiteUrl,
    required String mobile,
    required String countryCode,
    required String logoUrl,
    required String name,

    String ?accessToken,
    String ?versionCode,
  }) async {

    _setLoading(true);
    try {
      _userData = await _authService.signupUser(
        email: email,
        logoUrl: logoUrl,
        storeName: storeName,
        websiteUrl: websiteUrl,
        countryCode:countryCode ,
        mobile: mobile,
        name: name,
        accessToken: accessToken,
        versionCode: versionCode,
       // photo: photo,
      );
      notifyListeners();
    } catch (e) {

      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  void resetAll() {
    _userData = null;
    _isLoading = false;

    // reset any other temporary variables here
    notifyListeners();
  }


}
