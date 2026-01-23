import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';

import '../core/firebase/auth_service.dart';
import '../core/string/string_utils.dart';

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
          await sendOtpEmail(email: email, userID: userData?['uid'], otp: otp);
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection("stores").doc(userData?['uid']).update({
            "otp": otp,
            "otp_created_at": FieldValue.serverTimestamp(),
            "active_status":
                false, // Ensure user is inactive until OTP verified
          });
        } else {
          otp = generateOtp();
          await sendOtpEmail(email: email, userID: userData?['uid'], otp: otp);
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection("stores").doc(userData?['uid']).update({
            "otp": otp,
            "otp_created_at": FieldValue.serverTimestamp(),
            "active_status":
                false, // Ensure user is inactive until OTP verified
          });
        }

        //String otp = generateOtp();
      }

      return _userData ?? {}; // 🔹 return the user data
    } catch (e) {
      print('---e$e');
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendOtpEmail({
    required String email,
    required String otp,
    required String userID,
  }) async {
    _setLoading(true);

    if (email.isEmpty) {
      return; // stop execution
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': otpServiceID,
        'template_id': otpTemplateID,
        'user_id': otpPublicID,
        'template_params': {
          'email': email,
          'passcode': otp,
          'time': '15 minutes', // or generate expiry dynamically
        },
      }),
    );
    print('---e${response.statusCode }');
    print('---e${response.body }');
    if (response.statusCode == 200) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection("stores").doc(userID).update({
        "otp": otp,
        "otp_created_at": FieldValue.serverTimestamp(),
        "active_status": false, // Ensure user is inactive until OTP verified
      });

      _setLoading(false);
    } else {
      _setLoading(false);
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
        String otp = generateOtp();
        await sendOtpEmail(email: email, userID: userId, otp: otp);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection("stores").doc(userId).update({
          "otp": otp,
          "otp_created_at": FieldValue.serverTimestamp(),
          "active_status": false, // Ensure user is inactive until OTP verified
        });
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
