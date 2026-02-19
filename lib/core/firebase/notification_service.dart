import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../../provider/notification_provider.dart';
import '../../routes/app_routes.dart';
import 'local_notification.dart';
import 'notification_storage.dart';

@pragma('vm:entry-point') // 👈 Needed so native code can call it
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static String? token;
  static bool _permissionRequested = false;

  @pragma('vm:entry-point')
  void initNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log(
        "🔥 FG Notification received: ${message.messageId}, data: ${message.data}",
      );
      await _showLocalNotification(message);
    });
  }

  static Future<void> initializeApp({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    await Firebase.initializeApp();
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await initFirebaseToken();

    // Handle notification tap when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        final safeData = message.data.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );

        final notification = LocalNotification(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title:
              message.notification?.title ??
              message.data['title'] ??
              'New Notification',
          body: message.notification?.body ?? message.data['body'] ?? '',
          category: safeData['category'] ?? '',
          receivedAt: DateTime.now(),
          data: safeData,
        );

        // ✅ Provider के जरिए add करो
        final context = _navigatorKey.currentContext;
        if (context != null) {
          Provider.of<NotificationProvider>(
            _navigatorKey.currentContext!,
            listen: false,
          ).addNotification(notification);
        } else {
          // अगर context नहीं मिला तो fallback
          await NotificationStorage.saveNotification(notification);
        }
        _handlePayloadNavigation(
          payload: safeData['category'] ?? '',
          data: safeData,
        );
      }
    });
  }

  /// Token setup
  static Future<void> initFirebaseToken() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? apnsToken = await _messaging.getAPNSToken();
      while (apnsToken == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        apnsToken = await _messaging.getAPNSToken();
      }
    } else if (kIsWeb) {
      // Request permission for web notifications
      try {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } catch (e) {
        debugPrint("🔥 Error requesting web notification permission: $e");
      }
    }

    token = await FirebaseMessaging.instance.getToken();
    debugPrint("Firebase Token by Flutter code: $token");

    _messaging.onTokenRefresh.listen((newToken) {
      token = newToken;
      debugPrint("Token refreshed: $token");
    });
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 👇 Create Android channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Must match AndroidManifest.xml
      'High Importance Notifications', // Human-readable name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    // Register the channel with system
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload);
            _handlePayloadNavigation(data: data, payload: data['category']);
          } catch (e) {
            debugPrint('Error decoding payload: $e');
          }
        }
      },
    );
  }

  /// FCM setup
  static Future<void> _initializeFirebaseMessaging() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('Notification permission declined');
      return;
    }

    debugPrint('Notification permission granted');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("🔥 Foreground FCM: ${message.data}");
      await _showLocalNotification(message);
    });

    // App opened by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 Notification opened (background): ${message.data}");
      _handlePayloadNavigation(
        payload: message.data['category'],
        data: message.data,
      );
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;

      final String title =
          notification?.title ?? message.data['title'] ?? 'New Notification';
      final String body = notification?.body ?? message.data['body'] ?? '';

      final safeData = message.data.map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
      final notification1 = LocalNotification(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title:
            message.notification?.title ??
            message.data['title'] ??
            'New Notification',
        body: message.notification?.body ?? message.data['body'] ?? '',
        category: safeData['category'] ?? '',
        receivedAt: DateTime.now(),
        data: safeData,
      );

      // ✅ Provider के जरिए add करो
      final context = _navigatorKey.currentContext;
      if (context != null) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).addNotification(notification1);
      } else {
        // अगर context नहीं मिला तो fallback
        await NotificationStorage.saveNotification(notification1);
      }
      // ✅ Foreground me bhi save karega
      /*await NotificationStorage.saveNotification(
        LocalNotification(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: body,
          category: safeData['category'] ?? '',
          receivedAt: DateTime.now(),
          data: safeData,
        ),
      );*/

      await _localNotificationsPlugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(safeData),
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  /// Background handler called by native

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final safeData = message.data.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );

    final notification1 = LocalNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title:
          message.notification?.title ??
          message.data['title'] ??
          'New Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      category: safeData['category'] ?? '',
      receivedAt: DateTime.now(),
      data: safeData,
    );

    // ✅ Provider के जरिए add करो
    final context = _navigatorKey.currentContext;
    if (context != null) {
      Provider.of<NotificationProvider>(
        _navigatorKey.currentContext!,
        listen: false,
      ).addNotification(notification1);
    } else {
      // अगर context नहीं मिला तो fallback
      await NotificationStorage.saveNotification(notification1);
    }

    debugPrint("🌙 Background notification saved: ${message.messageId}");
    _handlePayloadNavigation(
      payload: safeData['category'] ?? '',
      data: safeData,
    );
  }

  /// Handle navigation from notification
  static Future<void> _handlePayloadNavigation({
    required String payload,
    required Map<String, dynamic> data,
  }) async {
    debugPrint('Handling payload: $payload');
    debugPrint('Handling payload: ${data['id']}');

    switch (data['category']) {
      case 'join_class':
        _navigatorKey.currentState?.pushNamed(RouteName.loginScreen);
        break;
      case 'create_class':
        _navigatorKey.currentState?.pushNamed(RouteName.loginScreen);
        break;
      case 'update_class':
        _navigatorKey.currentState?.pushNamed(RouteName.loginScreen);
        break;
      case 'chat':
        /* _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              currentUserId: user?.sId ?? '',
              currentName: user?.displayName ?? '',
              currentPhoto: user?.avatar ?? '',
              otherUserId: data['otherUserId'],
              otherName: data['otherName'],
              otherPhoto: data['otherPhoto'],
            ),
          ),
        );*/
        _navigatorKey.currentState?.pushNamed(RouteName.loginScreen);
        break;
      default:
        _navigatorKey.currentState?.pushNamed(RouteName.loginScreen);
    }
  }
}
