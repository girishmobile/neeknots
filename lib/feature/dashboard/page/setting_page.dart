import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/admin/admin_dashboad.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/dashboard_provider.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/profile_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/component/common_switch.dart';
import '../../../core/firebase/auth_service.dart';
import '../../../core/hive/app_config_cache.dart';
import '../../../main.dart';
import '../../../provider/customer_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/product_provider.dart';
import '../../admin/admin_home_page.dart';

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

    /*print(
      '==userData===${profile.userData.toString()}',
    ); */ // Now it will have value
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Consumer2<ThemeProvider, ProfileProvider>(
      builder: (context, themeProvider, provider, child) {
        return Stack(
          children: [
            ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              children: [
                SizedBox(height: 50),
                CachedNetworkImage(
                  height: 150,
                  fit: BoxFit.cover,
                  width: size.width * 0.7,
                  imageUrl: provider.userData?['logo_url'] ?? '',

                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => Center(
                    child: Container(
                      child: commonAssetImage(
                        width: size.width * 0.7,
                        fit: BoxFit.scaleDown,
                        icAppLogo,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                commonText(
                  textAlign: TextAlign.center,
                  text: provider.userData?['name'] ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.isDark ? Colors.white : colorLogo,
                ),
                SizedBox(height: 4),
                commonText(
                  textAlign: TextAlign.center,
                  text: provider.userData?['email'] ?? '',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: themeProvider.isDark
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.8),
                ),
                SizedBox(height: 36),
                /*   _commonView(
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.editProfileScreen,
                    );
                  },
                  provider: themeProvider,
                  text: "Edit Information",
                  image: icInfo,
                ),*/
                SizedBox(height: 16),
                _commonView(
                  provider: themeProvider,
                  text: "Notification",
                  image: icNotification,
                  trailing: CommonSwitch(
                    value: themeProvider.isNotification,
                    onChanged: (value) => themeProvider.setNotification(true),
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: colorLogo,
                    activeTrackColor: colorLogo,
                    inactiveTrackColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _commonView(
                  text: themeProvider.isDark ? "Dark Theme" : "Light Theme ",
                  provider: themeProvider,
                  image: icTheme,
                  trailing: CommonSwitch(
                    value: themeProvider.isDark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: colorLogo,
                    activeTrackColor: colorLogo,
                    inactiveTrackColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                /*   _commonView(
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.changePasswordScreen,
                    );
                  },
                  image: icPassword,
                  provider: themeProvider,
                  text: "Change Password",
                ),*/
                _commonView(
                  onTap: () {
                    showCommonDialog(
                      title: "Delete",
                      context: context,
                      content: "Are you sure want to delete account",
                      onPressed: () async {
                        final authService = AuthService();
                        await authService.deleteCurrentUser(
                          context: context,
                          uid: provider.userData?['id'] ?? '',
                        );
                      },
                    );
                  },
                  image: icPassword,
                  provider: themeProvider,
                  text: "Delete Account",
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commonInkWell(
                      onTap: () {
                        showCommonDialog(
                          confirmText: "Yes",
                          onPressed: () async {
                            await AppConfigCache.clearAll();
                            context.read<DashboardProvider>().resetTab();
                            context.read<ProductProvider>().reset();
                            context.read<OrdersProvider>().resetData();
                            context.read<CustomerProvider>().reset();
                            context.read<ProfileProvider>().resetState();
                            context.read<LoginProvider>().resetState();
                            await AppConfigCache.clearConfig();
                            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              RouteName.loginScreen,
                              (Route<dynamic> route) => false,
                            );
                          },
                          cancelText: "No",
                          title: "Logout?",
                          context: context,
                          content: "Are you sure want to logout",
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 50,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                /*_commonView(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminHomePage(),
                      ),
                    );
                  },
                  provider: themeProvider,
                  text: "Edit Information",
                  image: icInfo,
                ),*/
              ],
            ),

            provider.isLoading ? showLoaderList() : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  _commonView({
    String? text,
    Widget? trailing,
    String? image,
    void Function()? onTap,
    required ThemeProvider provider,
  }) {
    return Container(
      decoration: commonBoxDecoration(
        color: Colors.transparent,
        borderColor: colorBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: commonListTile(
          onTap: onTap,
          titleFontWeight: FontWeight.w500,
          titleFontSize: 14,
          textColor: provider.isDark ? Colors.white : colorLogo,
          contentPadding: EdgeInsetsGeometry.zero,
          trailing:
              trailing ??
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 15,
                ),
              ),
          leadingIcon: Container(
            width: 45,
            height: 45,
            decoration: commonBoxDecoration(
              color: provider.isDark
                  ? Colors.transparent
                  : colorLogo.withValues(alpha: 0.05),
              borderColor: provider.isDark
                  ? Colors.white
                  : colorLogo.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: commonPrefixIcon(
                width: 20,
                colorIcon: provider.isDark ? Colors.white : colorLogo,
                height: 20,
                image: image ?? icTotalProduct,
              ),
            ),
          ),
          title: text ?? "Change Theme",
        ),
      ),
    );
  }
}
