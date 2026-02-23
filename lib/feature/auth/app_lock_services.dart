import 'package:local_auth/local_auth.dart';

class AppLockServices {
  final LocalAuthentication _auth = LocalAuthentication();
  Future<bool> isAvailable() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: "Authenticate to unlock the app",
        biometricOnly: false,
      );
    } catch (e) {
      return false;
    }
  }
}
