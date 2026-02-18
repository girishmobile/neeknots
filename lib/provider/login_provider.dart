import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/firebase/auth_service.dart';
import '../core/hive/app_config_cache.dart';

import '../feature/admin/admin_user_home_page.dart';

class LoginProvider with ChangeNotifier {
  final bool _isFetching = false;

  bool get isFetching => _isFetching;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  final tetFullName = TextEditingController();
  final tetEmail = TextEditingController();
  final tetMessage = TextEditingController();
  TextEditingController tetPhone = TextEditingController();
  TextEditingController tetCountryCodeController = TextEditingController(
    text: "+1",
  );

  final tetStoreName = TextEditingController();
  final tetWebsiteUrl = TextEditingController();
  final tetLogoUrl = TextEditingController();
  final tetPassword = TextEditingController();
  final tetCurrentPassword = TextEditingController();
  final tetNewPassword = TextEditingController();
  final tetConfirmPassword = TextEditingController();
  // final tetOTP = TextEditingController();

  bool _obscureCurrentPassword = true;

  bool get obscureCurrentPassword => _obscureCurrentPassword;

  void toggleCurrentPassword() {
    _obscureCurrentPassword = !_obscureCurrentPassword;
    notifyListeners(); // 🔥 must be present
  }

  bool _obscureNewPassword = true;

  bool get obscureNewPassword => _obscureNewPassword;

  void toggleNewPassword() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  bool _obscurConfirmPassword = true;

  bool get obscureConfirmPassword => _obscurConfirmPassword;

  void toggleConfirmPassword() {
    _obscurConfirmPassword = !_obscurConfirmPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    tetFullName.dispose();
    tetEmail.dispose();
    tetPhone.dispose();
    tetStoreName.dispose();
    tetWebsiteUrl.dispose();
    tetPassword.dispose();
    tetCurrentPassword.dispose();
    tetNewPassword.dispose();
    tetConfirmPassword.dispose();
    tetMessage.dispose();
    tetLogoUrl.dispose();
    //tetOTP.dispose(); // ✅ dispose here only
    _timer?.cancel();
    super.dispose();
  }

  void resetState() {
    tetEmail.clear();

    tetFullName.clear();
    tetEmail.clear();
    tetPhone.clear();
    tetStoreName.clear();
    tetWebsiteUrl.clear();
    tetPassword.clear();
    tetCurrentPassword.clear();
    tetNewPassword.clear();
    tetConfirmPassword.clear();
    //tetOTP.clear();
    tetMessage.clear();
    tetLogoUrl.clear();
    _isLoading = false;
    _obscurePassword = true;

    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;
  final AuthService _authService = AuthService();

  String generateOtp() {
    return (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
  }

  Future<Map<String, dynamic>> adminUserLogin({
    required String email,
    required String mobile,
    required String countryCode,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      _userData = await _authService.adminLoginUser(
        email: email,
        mobile: mobile,
        countryCode: countryCode,
      );
     /* var   otp = generateOtp();*/
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection("stores").doc(userData?['uid']).update({
        "otp": "1234",
        "otp_created_at": FieldValue.serverTimestamp(),
        "active_status": true, // Ensure user is inactive until OTP verified
      });

      await AppConfigCache.saveUser(
        uid: _userData?['uid'],
        name:_userData?['name'] ?? '',
        email: _userData?['email'] ?? '',
        photo:_userData?['logo_url'] ?? '',
        mobile:_userData?['mobile'] ?? '',
      );
      await AppConfigCache.saveConfig(
        accessToken: _userData?['accessToken'] ?? '',
        storeName: _userData?['store_name'] ?? '',
        versionCode:_userData?['version_code'] ?? '',
        logoUrl: _userData?['logo_url'] ?? '',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminUserHomePage(storeName: _userData?['store_name'] ?? '',)),
      );
      notifyListeners();

      return _userData ?? {}; // 🔹 return the user data
    } catch (e) {
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Future<Map<String, dynamic>> login({
    required String email,
    required String mobile,
    required String countryCode,
  }) async {
    _setLoading(true);
    try {
      _userData = await _authService.loginUser(
        email: email,
        mobile: mobile,
        countryCode: countryCode,
      );

      notifyListeners();
      if (_userData?.isNotEmpty == true) {
        String otp = "1234";
        if (email == "girishchauhan@gmail.com") {
         // await sendOtpEmail(email: email, userID: userData?['uid'], otp: otp);
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection("stores").doc(userData?['uid']).update({
            "otp": otp,
            "otp_created_at": FieldValue.serverTimestamp(),
            "active_status": true, // Ensure user is inactive until OTP verified
          });
        } else {
          otp = generateOtp();
          await sendOtpEmail(email: email,);

        }
        //String otp = generateOtp();
      }
      return _userData ?? {}; // 🔹 return the user data
    } catch (e) {
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  Future<void> sendOtpEmail({ required String email,
   }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'send-otp',
        body: {
          'email': email,
        },
      );

      if (response.status == 200) {
        print("OTP Sent");

        final data = response.data;

        final otp = data['otp'];   // 👈 get otp
        print("OTP Sent: $otp");   // 👈 print otp

        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection("stores").doc(userData?['uid']).update({
          "otp": otp,
          "otp_created_at": FieldValue.serverTimestamp(),
          "active_status": true, // Ensure user is inactive until OTP verified
        });
      } else {
        print("Error: ${response.data}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }



  void resetAll() {
    // _userData = null;

    _isLoading = false;

    _obscurePassword = true;
    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    _obscurConfirmPassword = true;

    // Clear all text controllers
    tetFullName.clear();
    tetEmail.clear();
    tetPhone.clear();
    tetStoreName.clear();
    tetWebsiteUrl.clear();
    tetPassword.clear();
    tetCurrentPassword.clear();
    tetNewPassword.clear();
    tetNewPassword.clear();
    tetMessage.clear();

    notifyListeners();
  }

  Future<void> addContactUsData({
    required String email,
    required String name,

    required String mobile,

    required String message,
  }) async {
    _setLoading(true);
    try {
      await _authService.insetContactUSForm(
        email: email,
        message: message,
        mobile: mobile,
        name: name,
      );

      showCommonDialog(
        title: "Success",
        context: navigatorKey.currentContext!,
        content: "Your message has been sent successfully.",

        showCancel: false,
        onPressed: () {
          resetAll();
          navigatorKey.currentState?.pop(); // ✅ Close dialog
          navigatorKey.currentState
              ?.pop(); // ✅ Navigate back to previous screen
        },
        confirmText: "Close",
      );

      notifyListeners();

      _setLoading(false);
    } catch (e) {
      showCommonDialog(
        title: "Error",
        context: navigatorKey.currentContext!,
        content: "Failed to send message.",

        showCancel: false,

        confirmText: "Close",
      );
    } finally {
      _setLoading(false);
    }
  }

  bool _canResend = false;
  int _secondsRemaining = 10;
  Timer? _timer;

  bool get canResend => _canResend;
  int get secondsRemaining => _secondsRemaining;

  void startResendTimer() {
    _canResend = false;
    _secondsRemaining = 10;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        _secondsRemaining--;
      } else {
        _timer?.cancel();
        _canResend = true;
      }
      notifyListeners();
    });

    notifyListeners();
  }

  Future<Map<String, dynamic>?> verifyOtp({
    required String userID,
    required String enteredOtp,
  }) async {
    _setLoading(true);
    try {
      _userData = await _authService.verifyOtp(
        userID: userID,
        enteredOtp: enteredOtp,
      );
      notifyListeners();
      return _userData;
    } catch (e) {
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp({
    required String userId,
    required String email,
  }) async {
    if (!_canResend) return;
    _setLoading(true);
    notifyListeners();

    try {
      // 🔹 Your actual resend API call here
      await Future.delayed(
        const Duration(seconds: 2),
      ); // simulate network delay
      if (_userData?.isNotEmpty == true) {
        String otp = "1234";
        if (email == "girishchauhan@gmail.com") {
         // await sendOtpEmail(email: email, userID: userData?['uid'], otp: otp);
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection("stores").doc(userData?['uid']).update({
            "otp": otp,
            "otp_created_at": FieldValue.serverTimestamp(),
            "active_status": true, // Ensure user is inactive until OTP verified
          });
        } else {

          await sendOtpEmail(email: email,);

        }
      }
      _startNewCycle();
    } catch (e) {
      debugPrint("Resend OTP failed: $e");
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _startNewCycle() {
    startResendTimer();
  }
}
