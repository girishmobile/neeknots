import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/common_bottom_navbar.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/feature/dashboard/page/customer_page.dart';
import 'package:neeknots/feature/dashboard/page/home_page.dart';
import 'package:neeknots/feature/dashboard/page/order_page.dart';
import 'package:neeknots/feature/dashboard/page/product_page.dart';
import 'package:neeknots/feature/dashboard/page/setting_page.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/customer_provider.dart';
import 'package:neeknots/provider/dashboard_provider.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/provider/profile_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../admin/common_admin_widget.dart';
import '../../core/firebase/auth_service.dart';
import '../../core/hive/app_config_cache.dart';
import '../../provider/product_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget getPage(int index) {
    switch (index) {
      case 0:
        return ProductPage();
      case 1:
        return OrderPage();
      case 2:
        return HomePage();
      case 3:
        return CustomersPage();
      case 4:
        return SettingPage();
      default:
        return HomePage();
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      await profile.loadUserData(); // <-- a
      String? storedEmailOrMobile = await AppConfigCache.getName();
      String? id = await AppConfigCache.getID();
      final provider = Provider.of<DashboardProvider>(
        navigatorKey.currentContext!,
        listen: false,
      );
      provider.setName(storedEmailOrMobile);

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 🔹 Step 2: For iOS, wait for APNs token before calling getToken()
        String? apnsToken;
        if (Platform.isIOS) {
          apnsToken = await messaging.getAPNSToken();
          int retries = 0;
          while (apnsToken == null && retries < 5) {
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await messaging.getAPNSToken();
            retries++;
          }
          debugPrint('📱 APNs Token: $apnsToken');
        }
        // 🔹 Step 3: Now safely get FCM token
        String? fcmToken = await messaging.getToken();

        final authService = AuthService();
        await authService.updateFcm(userID: id ?? '', fcmToken: fcmToken ?? '');
      } else {
        debugPrint('❌ Notification permission denied');
      }
    });
  }

  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0]; // Only first name
    } else {
      return parts[0][0] + parts[1][0]; // First + Last initials
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        return Stack(
          children: [
            commonScaffold(
              appBar: commonAppBar(
                backgroundColor: Colors.transparent,

                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      navigatorKey.currentState?.pushNamed(
                        RouteName.contactUsScreen,
                      );
                    },
                    icon: commonAssetImage(
                      icContact,
                      color: colorText,
                      width: 30,
                      height: 30,
                    ),
                  ),
                  SizedBox(width: 10),
                  notificationWidget(
                    onTap: () {
                      navigatorKey.currentState?.pushNamed(
                        RouteName.notificationScreen,
                      );
                    },
                  ),
                  SizedBox(width: 16),
                ],
                title: provider.appbarTitle ?? "Home",
                context: context,
                leading: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Container(
                      padding: EdgeInsets.only(left: 10),
                      child: commonInkWell(
                        onTap: () {
                          provider.setIndex(4);
                        },
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withValues(alpha: 1),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover,
                              imageUrl:
                                  profileProvider.userData?['logo_url'] ?? '',
                              errorWidget: (context, url, error) => Center(
                                child: commonText(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  text:
                                      ((profileProvider.userData?['name'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                      ? profileProvider.userData!['name'][0]
                                            .toUpperCase()
                                      : '',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              body: getPage(provider.currentIndex),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red, // 👈 change here
                    boxShadow: [
                      BoxShadow(blurRadius: 2, color: colorMenu.withValues(alpha: 0.2)),
                    ],
                  ),
                  child: CommonBottomNavBar(
                    currentIndex: provider.currentIndex,
                    onTap: (index) {
                      provider.setIndex(index);

                      switch (index) {
                        case 0:
                          context.read<OrdersProvider>().resetData();
                          context.read<CustomerProvider>().reset();
                          context.read<ProfileProvider>().resetState();
                          break;
                        case 1:
                          context.read<ProductProvider>().reset();
                          context.read<CustomerProvider>().reset();
                          context.read<ProfileProvider>().resetState();
                          break;
                        case 2:
                          context.read<ProductProvider>().reset();
                          context.read<OrdersProvider>().resetData();
                          context.read<CustomerProvider>().reset();
                          context.read<ProfileProvider>().resetState();
                          break;
                        case 3:
                          context.read<ProductProvider>().reset();
                          context.read<OrdersProvider>().resetData();
                          context.read<ProfileProvider>().resetState();
                          break;
                        case 4:
                          context.read<ProductProvider>().reset();
                          context.read<OrdersProvider>().resetData();
                          context.read<CustomerProvider>().reset();
                          break;
                      }

                      if (index == 0) provider.setAppBarTitle("Products");
                      if (index == 1) provider.setAppBarTitle("Orders");
                      if (index == 2) provider.setAppBarTitle("Home");
                      if (index == 3) provider.setAppBarTitle("Customers");
                      if (index == 4) provider.setAppBarTitle("Account");
                    },
                    items: BottomNavItems.items,
                  ),
                ),
              ),
            ),
            context.watch<ProductProvider>().isFetching ||
                    context.watch<OrdersProvider>().isFetching ||
                    context.watch<CustomerProvider>().isFetching
                ? Container(
                    color: Colors.black.withValues(alpha: 0.01),
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: showLoaderList11(),
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
