import 'package:flutter/material.dart';
import 'package:neeknots/main.dart';

import 'package:url_launcher/url_launcher.dart';
import 'component.dart';

class UrlLauncherService {
  // Open a website URL
  static Future<void> launchWebUrl({required String url}) async {
    if (url.isEmpty) {
      showCommonDialog(
        confirmText: "Close",
        showCancel: false,

        title: "Error",
        content: "Oops! This URL doesn’t seem to be working.",
        context: navigatorKey.currentContext!,
      );
    } else {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showCommonDialog(
          confirmText: "Close",
          showCancel: false,
          context: navigatorKey.currentContext!,
          title: "Error",
          content: "Oops! This URL doesn’t seem to be working.",
        );
        debugPrint('Could not launch $url');
      }
    }
  }

  // Make a phone call
  static Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not call $phoneNumber');
    }
  }

  // Send an SMS
  static Future<void> launchSMS(String phoneNumber, {String? message}) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: message != null ? {'body': message} : null,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not send SMS to $phoneNumber');
    }
  }

  static Future<void> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('No email app found for $email');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  static void shareToWhatsApp({
    required String message,
    required BuildContext context,
  }) async {
    final whatsappUrl = Uri.parse("whatsapp://send?text=$message");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      showCommonDialog(
        context: navigatorKey.currentContext!,
        showCancel: false,
        confirmText: "Close",
        title: "Error",
        content: "WhatsApp is not installed.",
      );
    }
  }

  static void shareToFacebook({required String url}) async {
    final facebookUrl = Uri.parse(
      "https://www.facebook.com/sharer/sharer.php?u=$url",
    );
    if (await canLaunchUrl(facebookUrl)) {
      await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
    } else {}
  }

  static void shareToGmail({
    required String subject,
    required String body,
  }) async {
    final gmailUrl = Uri.parse("mailto:?subject=$subject&body=$body");
    if (await canLaunchUrl(gmailUrl)) {
      await launchUrl(gmailUrl);
    } else {}
  }

  /*  static Future<void> openMap({
    required double latitude,
    required double longitude,
  }) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }*/
  static Future<void> openMap({required String address}) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open map");
    }
  }

  static Future<void> openWaze({
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse("https://waze.com/ul?ll=$lat,$lng&navigate=yes");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Waze';
    }
  }

  static Future<void> openPayPalMe({
    required String handle, // your PayPal.me handle
    double? amount, // e.g., 25.0
    String? currencyCode, // e.g., "USD", "EUR"
  }) async {
    final amountPart = (amount != null)
        ? (currencyCode != null
              ? "/${amount.toStringAsFixed(0)}$currencyCode"
              : "/${amount.toStringAsFixed(0)}")
        : "";

    final url = Uri.parse("https://www.paypal.me/$handle$amountPart");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }
}

Future<void> openMap({required double lat, required double lng}) async {
  final Uri url = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not open map");
  }
}
