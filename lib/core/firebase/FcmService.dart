import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class FcmService {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future<void> sendToToken({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    final client = await _getAuthClient();

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/neeknots-a8758/messages:send',
    );

    final payload = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
      },
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    client.close();

    if (response.statusCode != 200) {
      throw Exception('FCM Error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<AuthClient> _getAuthClient() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/service_account.json',
    );

    final jsonMap = jsonDecode(jsonString);

    final credentials = ServiceAccountCredentials.fromJson(jsonMap);
    return clientViaServiceAccount(credentials, _scopes);
  }
}
