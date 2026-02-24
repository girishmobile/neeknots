import 'dart:convert';

import 'package:http/http.dart' as http;

import '../string/string_utils.dart';

Future<void> sendPushNotification({
  required String fcmToken,
  required String title,
  required String body,
}) async {
  const String supabaseUrl =
      "https://hxwlwuvvxtjyukifdarh.supabase.co/functions/v1/send-notification";

  try {
    final response = await http.post(
      Uri.parse(supabaseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $publicKey",
      },
      body: jsonEncode({
        "token":
            "c5qBB-LkSV6eyhSOdTJ6Cc:APA91bFRNHBYpHWYTHu4Q44UaUZ84AJhfF_lCOp-bL-C4KuMbkFPaKaLxU-4JYc467IINbK6A6RpZctThsIYSDUMYy4RzvjKBdiX7Lrnjk1cD6SAZ8FBqao",
        "title": "Hello",
        "body": "This is a test notification",
        "data": {"key1": "value1", "key2": "value2"},
      }),
    );

    if (response.statusCode == 200) {
      // print(response.body);
    } else {}
  } catch (e) {}
}
