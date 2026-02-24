import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/feature/auth/signup/bio_metric_view.dart';
import 'package:neeknots/provider/dashboard_provider.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/profile_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/firebase/auth_service.dart';
import '../../../core/hive/app_config_cache.dart';
import '../../../main.dart';
import '../../../provider/admin_dashboard_provider.dart';
import '../../../provider/customer_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/product_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
    });
  }

  Future<void> init() async {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    await profile.loadUserData(); // <-- await here
    final customerProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    customerProvider.getStoreUserCounts();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Container(
      color: Colors.white,
      child: Consumer2<ThemeProvider, ProfileProvider>(
        builder: (context, themeProvider, provider, child) {
          return Stack(
            children: [
              ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 50),

                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorButton1.withValues(alpha: 0.09),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        imageUrl: provider.userData?['logo_url'] ?? '',
                        errorWidget: (context, url, error) => Center(
                          child: commonText(
                            fontSize: 45,
                            color: colorButton1,
                            fontWeight: FontWeight.w600,
                            text:
                                ((provider.userData?['name'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                ? provider.userData!['name'][0].toUpperCase()
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  commonText(
                    textAlign: TextAlign.center,
                    text: provider.userData?['name'] ?? '',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDark ? Colors.white : colorLogo,
                  ),
                  const SizedBox(height: 4),
                  commonText(
                    textAlign: TextAlign.center,
                    text: provider.userData?['email'] ?? '',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: themeProvider.isDark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 36),
                  commonText(
                    text: "Personal Details",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorButton1,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF4F6F8),
                      border: Border.all(color: colorBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // p//adding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      spacing: 24,
                      children: [
                        infoRowBox(
                          text: "Full Name",
                          value: '${provider.userData?['name'] ?? '-'}',
                        ),

                        infoRowBox(
                          text: "Email",
                          value: provider.userData?['email'] ?? '-',
                        ),

                        infoRowBox(
                          text: "Mobile Number",
                          value: provider.userData?['mobile'] ?? '-',
                        ),
                        infoRowBox(
                          text: "App Name",
                          value: provider.userData?['app_name'] ?? '-',
                        ),
                        infoRowBox(
                          text: "Store Name",
                          value: provider.userData?['store_name'] ?? '-',
                        ),
                        infoRowBox(
                          text: "Version Name",
                          value: provider.userData?['version_code'] ?? '-',
                        ),

                        infoRowBox(
                          value: '',
                          text: "Status",
                          valueView: Builder(
                            builder: (_) {
                              final isActive =
                                  provider.userData?['active_status'] ?? false;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 5,
                                    ),
                                    decoration: commonBoxDecoration(
                                      color:
                                          (isActive ? Colors.green : Colors.red)
                                              .withValues(alpha: 0.09),
                                      borderColor: isActive
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: 8,
                                    ),
                                    child: commonText(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.red,
                                      text: isActive ? "Active" : "Inactive",
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        BioMetricView(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [],
                  ),

                  const SizedBox(height: 18),
                  Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      commonInkWell(
                        onTap: () {
                          _handleLogout();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 60,
                          ),
                          decoration: commonBoxDecoration(
                            color: themeProvider.isDark
                                ? Colors.white
                                : colorLogo,
                          ),
                          child: Center(
                            child: commonText(
                              text: "Logout".toUpperCase(),
                              color: themeProvider.isDark
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      commonInkWell(
                        onTap: () {
                          showCommonDialog(
                            title: "Delete",
                            context: context,
                            content: "Are you sure want to delete account",
                            onPressed: () async {
                              final authService = AuthService();
                              await authService.deleteCurrentUser(
                                context: context,
                                uid: provider.userData?['uid'] ?? '',
                              );
                              await _clearAppState();
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 30,
                          ),
                          decoration: commonBoxDecoration(
                            color: themeProvider.isDark
                                ? Colors.white
                                : Colors.red,
                          ),
                          child: Center(
                            child: commonText(
                              text: "Delete Account".toUpperCase(),
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  commonButton(
                    text: "Admin",
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.adminLoginPage);
                    },
                  ),
                  SizedBox(height: 18),
                ],
              ),

              provider.isLoading ? showLoaderList() : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  void _handleLogout() {
    showCommonDialog(
      context: context,
      title: "Logout?",
      content: "Are you sure want to logout",
      confirmText: "Yes",
      cancelText: "No",
      onPressed: _clearAppState,
    );
  }

  Future<void> _clearAppState() async {
    await AppConfigCache.clearAll();
    await AppConfigCache.clearConfig();

    final context = navigatorKey.currentContext!;

    context.read<DashboardProvider>().resetTab();
    context.read<ProductProvider>().reset();
    context.read<OrdersProvider>().resetData();
    context.read<CustomerProvider>().reset();
    context.read<ProfileProvider>().resetState();
    context.read<LoginProvider>().resetState();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteName.loginScreen,
      (route) => false,
    );
  }
}
