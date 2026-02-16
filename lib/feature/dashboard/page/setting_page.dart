import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/dashboard_provider.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/profile_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/firebase/auth_service.dart';
import '../../../core/hive/app_config_cache.dart';
import '../../../main.dart';
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

                /*CachedNetworkImage(
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
                ),*/
                Container(
                  decoration: commonBoxDecoration(
                    //  borderColor: colorBorder
                  ),
                  child: CachedNetworkImage(
                    height: 150,
                    fit: BoxFit.cover,
                    width: size.width * 0.6,
                    // imageUrl: provider.userData?.logoUrl??'',
                    imageUrl: '',

                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: commonBoxDecoration(
                          color: colorButton1.withValues(alpha: 0.09),
                          borderColor: colorButton1,
                          borderWidth: 2,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: commonText(
                            fontSize: 30,
                            color: colorButton1,
                            fontWeight: FontWeight.w700,
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
                commonText(
                  text: "Personal Details",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colorButton1,
                ),
                Container(
                  decoration: commonBoxDecoration(
                    borderColor: colorBorder,
                    color: colorButton1.withValues(alpha: 0.04),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    spacing: 25,
                    children: [
                      _commonRow(
                        title: "Full Name",
                        value: '${provider.userData?['name'] ?? '-'}',
                      ),

                      _commonRow(
                        title: "Email",
                        value: provider.userData?['email'] ?? '-',
                      ),

                      _commonRow(
                        title: "Mobile Number",
                        value: provider.userData?['mobile'] ?? '-',
                      ),

                      _commonRow(
                        title: "Store Name",
                        value: provider.userData?['store_name'] ?? '-',
                      ),
                      _commonRow(
                        title: "Version Name",
                        value: provider.userData?['version_code'] ?? '-',
                      ),
                      /* _commonRow(
                        value: '',
                        title: "Status",
                        view: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: commonBoxDecoration(
                                color: Colors.green.withValues(alpha: 0.09),
                                borderColor: Colors.green,
                                borderRadius: 8,
                              ),
                              child: commonText(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (provider.userData?['active_status'])
                                    ? Colors.green
                                    : Colors.red,

                                text: (provider.userData?['active_status'])
                                    ? "Active"
                                    : "Inactive",
                              ),
                            ),
                          ],
                        ),
                      ),*/
                      _commonRow(
                        value: '',
                        title: "Status",
                        view: Builder(
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
                                    color: isActive ? Colors.green : Colors.red,
                                    text: isActive ? "Active" : "Inactive",
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),

                /*   commonButton(text: "Send", onPressed: (){

                    sendOtp("sameer@redefinesolutions.com");
                }),

                commonButton(text: "Verify", onPressed: (){

                  verifyOtp("sameer@redefinesolutions.com","896317");
                }),*/
                SizedBox(height: 18),
                Column(
                  spacing: 20,
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
                            navigatorKey.currentContext!
                                .read<DashboardProvider>()
                                .resetTab();
                            navigatorKey.currentContext!
                                .read<ProductProvider>()
                                .reset();
                            navigatorKey.currentContext!
                                .read<OrdersProvider>()
                                .resetData();
                            navigatorKey.currentContext!
                                .read<CustomerProvider>()
                                .reset();
                            navigatorKey.currentContext!
                                .read<ProfileProvider>()
                                .resetState();
                            navigatorKey.currentContext!
                                .read<LoginProvider>()
                                .resetState();
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
                              uid: provider.userData?['id'] ?? '',
                            );
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

                /* commonButton(text: "Send Notification", onPressed: () async {

                  }),*/
                /*  _commonView(
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
                )*/
              ],
            ),

            provider.isLoading ? showLoaderList() : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _commonView({
    String? text,
    Widget? trailing,
    String? image,
    void Function()? onTap,
    required ThemeProvider provider,
  }) {
    return Container(
      decoration: commonBoxDecoration(
        borderColor: colorBorder,
        color: colorButton1.withValues(alpha: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
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
            width: 35,
            height: 35,
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

  Widget _commonRow({String? title, required String value, Widget? view}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: commonText(
            text: title ?? "Phone Number",
            fontWeight: FontWeight.w400,
          ),
        ),
        view ?? commonText(text: value, fontWeight: FontWeight.w400),
      ],
    );
  }
}
