import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:neeknots/provider/admin_dashboard_provider.dart';
import 'package:neeknots/provider/admin_home_provider.dart';
import 'package:neeknots/provider/admin_menu_provider.dart';
import 'package:neeknots/provider/customer_provider.dart';
import 'package:neeknots/provider/image_picker_provider.dart';
import 'package:neeknots/provider/internet_provider.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/notification_provider.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/provider/product_provider.dart';
import 'package:neeknots/provider/profile_provider.dart';
import 'package:neeknots/provider/signup_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:neeknots/routes/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/firebase/firebase_options.dart';
import 'core/firebase/notification_service.dart';
import 'core/string/string_utils.dart';
import 'provider/dashboard_provider.dart';
import 'provider/theme_provider.dart';

@pragma('vm:entry-point') // important for background isolate
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  log(
    "📩 BG Notification received: ${message.messageId}, data: ${message.data}",
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
  ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
  ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
  ChangeNotifierProvider<OrdersProvider>(create: (_) => OrdersProvider()),
  ChangeNotifierProvider<CustomerProvider>(create: (_) => CustomerProvider()),
  ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
  ChangeNotifierProvider<SignupProvider>(create: (_) => SignupProvider()),
  ChangeNotifierProvider<ImagePickerProvider>(
    create: (_) => ImagePickerProvider(),
  ),
  ChangeNotifierProvider<NotificationProvider>(
    create: (_) => NotificationProvider(),
  ),

  ChangeNotifierProvider<InternetProvider>(create: (_) => InternetProvider()),
  ChangeNotifierProvider<AdminDashboardProvider>(
    create: (_) => AdminDashboardProvider(),
  ),
  ChangeNotifierProvider<AdminMenuProvider>(create: (_) => AdminMenuProvider()),
  ChangeNotifierProvider<AdminHomeProvider>(create: (_) => AdminHomeProvider()),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: apiUrl, anonKey: publicKey);

  try {
    await Hive.initFlutter();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await NotificationService.initializeApp(navigatorKey: navigatorKey);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, s) {
    debugPrint('🔥 Initialization error: $e\n$s');
  }
  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: RouteName.splashScreen,
      // home: AdminDashboardScreen(),
      onGenerateRoute: RouteGenerate.onGenerateRoute,
    );
  }
}
