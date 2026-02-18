import 'package:shared_preferences/shared_preferences.dart';

class AppConfigCache {
  static const String _uidKey = 'uid';
  static const String _accessTokenKey = 'accessToken';
  static const String _storeNameKey = 'storeName';
  static const String _versionCodeKey = 'versionCode';
  static const String _logoUrlKey = 'logoUrl';
  static const String _emailKey = 'email';
  static const String _mobileKey = 'mobile';
  static const String _nameKey = 'name';

  /// Save Config
  static Future<void> saveConfig({
    required String accessToken,
    required String storeName,
    required String versionCode,
    required String logoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_storeNameKey, storeName);
    await prefs.setString(_versionCodeKey, versionCode);
    await prefs.setString(_logoUrlKey, logoUrl);
  }

  /// Save User
  static Future<void> saveUser({
    required String uid,
    required String name,
    required String mobile,
    required String email,
    required String photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_logoUrlKey, photo);
  }

  /// Get User Data
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? "",
      'email': prefs.getString(_emailKey) ?? "",
      'mobile': prefs.getString(_mobileKey) ?? "",
      'logoUrl': prefs.getString(_logoUrlKey) ?? "",
      'id': prefs.getString(_uidKey) ?? "",
    };
  }

  static Future<String?> getStoredEmailOrMobile() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_emailKey);
    if (email != null && email.isNotEmpty) return email;
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_nameKey);
    if (name != null && name.isNotEmpty) return name;
    return prefs.getString(_emailKey);
  }

  static Future<String?> getID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  static Future<String?> getLogo() async {
    final prefs = await SharedPreferences.getInstance();
    String? logo = prefs.getString(_logoUrlKey);
    if (logo != null && logo.isNotEmpty) return logo;
    return prefs.getString(_nameKey);
  }

  /// Load Config
  static Future<Map<String, String>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString(_accessTokenKey) ?? "",
      'storeName': prefs.getString(_storeNameKey) ?? "",
      'versionCode': prefs.getString(_versionCodeKey) ?? "",
      'logoUrl': prefs.getString(_logoUrlKey) ?? "",
    };
  }

  static Future<String> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeNameKey) ?? "";
  }
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? "";
  }

  /// Clear Config
  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_storeNameKey);
    await prefs.remove(_versionCodeKey);
    await prefs.remove(_logoUrlKey);
  }
/*  static Future<void> saveSelectedStoreUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedStoreKey, uid);
  }

  static Future<String?> getSelectedStoreUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedStoreKey);
  }*/
  /// Clear All
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
