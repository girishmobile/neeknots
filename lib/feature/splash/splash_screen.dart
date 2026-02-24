import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/feature/auth/app_lock_services.dart';
import 'package:neeknots/feature/auth/app_lock_storage.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/hive/app_config_cache.dart';
//https://neeknots-a8758.web.app
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _logoUrl;

  //Face lock
  bool _authCancelled = false;
  final _biometric = AppLockServices();
  final _storage = AppLockStorage();

  @override
  void initState() {
    super.initState();
    print("🔥 Splash initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSlash();
    });
  }

  Future<void> initSlash() async {
    String? storedEmailOrMobile = await AppConfigCache.getStoredEmailOrMobile();

    if (kIsWeb) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteName.adminLoginPage,
        (Route<dynamic> route) => false,
      );
    } else {
      if (storedEmailOrMobile?.isNotEmpty == true) {
        _handleAppLock();
        // checkStatus();
      } else {
        redirectToIntro();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleAppLock() async {
    final enabled = await _storage.isEnabled();
    if (enabled) {
      final authenticated = await _biometric.authenticate();
      if (!authenticated) {
        // App stays locked – user can retry or background app
        setState(() {
          _authCancelled = true;
        });
        return;
      }
    }
    if (!mounted) return;
    checkStatus();
  }

  void checkStatus() async {
    try {
      String? storedEmailOrMobile =
          await AppConfigCache.getStoredEmailOrMobile();

      if (storedEmailOrMobile == null || storedEmailOrMobile.isEmpty) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.loginScreen,
          (Route<dynamic> route) => false,
        );
        return;
      }

      final userData = await AuthService().checkUserStatus(
        emailOrMobile: storedEmailOrMobile,
      );
      setState(() {
        _logoUrl = userData['logo_url'];
      });

      if (userData.isNotEmpty == true && userData['active_status'] == true) {
        await AppConfigCache.saveUser(
          uid: userData['uid'],
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          photo: userData['logo_url'] ?? '',
          mobile: userData['mobile'] ?? '',
        );
        await AppConfigCache.saveConfig(
          accessToken: userData['accessToken'] ?? '',
          storeName: userData['store_name'] ?? '',
          versionCode: userData['version_code'] ?? '',
          logoUrl: userData['logo_url'] ?? '',
        );

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.dashboardScreen,
          (Route<dynamic> route) => false,
        );
      } else {
        Timer(const Duration(seconds: 3), () {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            RouteName.inactiveAccountScreen,
            (Route<dynamic> route) => false,
          );
        });
      }

      /*  Timer(const Duration(seconds: 3), () {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.dashboardScreen,
          (Route<dynamic> route) => false,
        );
      });*/
    } catch (e) {
      String errorMessage = e.toString().split(": ").last;
      if (e.toString() == "User not found") {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.inactiveAccountScreen,
          (Route<dynamic> route) => false,
        );
      }
      if (errorMessage == "Account inactive") {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.inactiveAccountScreen,
          (Route<dynamic> route) => false,
        );
      } else {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RouteName.loginScreen,
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void redirectToIntro() {
    Timer(const Duration(seconds: 5), () async {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteName.loginScreen,
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return commonScaffold(
      body: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return commonAppBackground(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: commonNetworkImage(
                    decoration: BoxDecoration(),
                    errorWidget: Center(
                      child: commonAssetImage(
                        icAppLogo,
                        width: size.width * 0.7,

                        height: 72,
                      ),
                    ),
                    fit: BoxFit.scaleDown,
                    _logoUrl ?? '',
                    size: size.width * 0.7,
                  ),
                ),
                if (_authCancelled) ...[
                  const Text(
                    'Authentication required',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _authCancelled = false;
                      });
                      _handleAppLock();
                    },
                    child: const Text('Try Again'),
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () {
                      // Optional: exit app
                      // SystemNavigator.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
