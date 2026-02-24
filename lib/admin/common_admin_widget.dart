import 'package:flutter/material.dart';
import 'package:neeknots/core/component/common_switch.dart';
import 'package:neeknots/provider/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

import '../core/color/color_utils.dart';
import '../core/component/common_intl_phone_field.dart';
import '../core/component/component.dart';
import '../core/image/image_utils.dart';
import '../core/validation/validation.dart';
import '../main.dart';
import '../provider/dashboard_provider.dart';
import '../provider/signup_provider.dart';
import '../routes/app_routes.dart';

class CommonAdminWidget extends StatefulWidget {
  const CommonAdminWidget({
    super.key,
    required this.data,
    required this.provider,
    required this.isEdit,
    required this.onPressed,
  });

  final Map<String, dynamic> data;
  final AdminDashboardProvider provider;
  final VoidCallback onPressed;
  final bool isEdit;

  @override
  State<CommonAdminWidget> createState() => _State();
}

class _State extends State<CommonAdminWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      widget.provider.tetFullName.text = widget.data["name"];
      widget.provider.tetEmail.text = widget.data["email"];
      widget.provider.tetPhone.text = widget.data["mobile"];
      widget.provider.tetCountryCodeController.text =
          widget.data["country_code"];
      widget.provider.tetStoreName.text = widget.data["store_name"];
      widget.provider.tetAccessToken.text = widget.data["accessToken"];
      widget.provider.tetVersionCode.text = widget.data["version_code"];
      widget.provider.tetAppLogo.text = widget.data["logo_url"] ?? '';
      widget.provider.tetWebsiteUrl.text = widget.data["website_url"];
      widget.provider.tetAppName.text = widget.data["app_name"] ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.setStatus(widget.data["active_status"] ?? false);
      });
    } else {
      widget.provider.tetStoreName.text = widget.data["store_name"];
      widget.provider.tetAccessToken.text = widget.data["accessToken"];
      widget.provider.tetVersionCode.text = widget.data["version_code"];
      widget.provider.tetAppName.text = widget.data["app_name"] ?? '';
    }
  }

  Widget commonFormView({
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? view,
    String? Function(String?)? validator,
    TextEditingController? controller,
    bool readOnly = false,
    bool filled = false,
    int? maxLines,
    String? text,
    Color? fillColor,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonText(text: text ?? "Name", fontWeight: FontWeight.w500),

        view ??
            commonTextField(
              validator: validator,
              readOnly: false,
              filled: filled,
              maxLines: maxLines,
              fillColor: fillColor,
              keyboardType: keyboardType ?? TextInputType.name,
              prefixIcon: prefixIcon ?? commonPrefixIcon(image: icUser),
              controller: controller ?? widget.provider.tetFullName,
              hintText: "",
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                commonFormView(
                  text: "Full Name",
                  keyboardType: TextInputType.name,
                  prefixIcon: commonPrefixIcon(image: icUser),
                  controller: widget.provider.tetFullName,
                ),

                commonFormView(
                  text: "Email Address",
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  readOnly: widget.isEdit ? true : false,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  filled: widget.isEdit ? true : false,

                  prefixIcon: commonPrefixIcon(image: icEmail),
                  controller: widget.provider.tetEmail,
                ),

                commonFormView(
                  text: "Phone Number",
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  view: CommonIntlPhoneField(
                    initialCountryCode: widget.isEdit
                        ? getInitialCountryCode(widget.data["country_code"])
                        : 'US',
                    phoneController: provider.tetPhone,
                    onCountryChanged: (value) {
                      final dialCode = "+${value.dialCode}";

                      provider.tetCountryCodeController.text = dialCode;
                    },
                    onChanged: (phone) {
                      provider.tetCountryCodeController.text =
                          phone.countryCode;
                    },
                  ),

                  readOnly: widget.isEdit ? true : false,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  filled: widget.isEdit ? true : false,

                  prefixIcon: commonPrefixIcon(image: icEmail),
                  controller: widget.provider.tetEmail,
                ),

                commonFormView(
                  text: "Store Name",
                  controller: widget.provider.tetStoreName,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: commonPrefixIcon(image: icStore),
                ),

                commonFormView(
                  text: "App Name",
                  controller: widget.provider.tetAppName,

                  maxLines: 1,

                  keyboardType: TextInputType.text,

                  prefixIcon: commonPrefixIcon(image: icStore),
                ),

                commonFormView(
                  text: "Access Token",
                  controller: widget.provider.tetAccessToken,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: commonPrefixIcon(image: icAccessToken),
                ),

                commonFormView(
                  text: "App Version Code",
                  controller: widget.provider.tetVersionCode,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: commonPrefixIcon(image: icVersionCode),
                ),
                commonFormView(
                  text: "App Logo Url",
                  controller: widget.provider.tetAppLogo,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: commonPrefixIcon(image: icAppLogoImage),
                ),
                commonFormView(
                  text: "Website Url",
                  controller: widget.provider.tetWebsiteUrl,
                  maxLines: 1,
                  keyboardType: TextInputType.url,
                  prefixIcon: commonPrefixIcon(image: icNetwork),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonText(
                      text: "Account Status:",
                      fontWeight: FontWeight.w500,
                    ),
                    Consumer<AdminDashboardProvider>(
                      builder: (context, provider, child) {
                        return CommonSwitch(
                          value: provider.status,
                          onChanged: (val) {
                            provider.setStatus(val);
                          },
                        );
                      },
                    ),
                  ],
                ),

                commonButton(
                  text: widget.isEdit ? "Update" : "Add User",
                  width: MediaQuery.sizeOf(context).width,
                  onPressed: () async {
                    Navigator.pop(context);

                    if (widget.isEdit) {
                      await widget.provider.updateUser(
                        docId: widget.data["id"],
                        token: widget.data['fcm_token'],
                      );
                    } else {
                      final signUpProvider = Provider.of<SignupProvider>(
                        context,
                        listen: false,
                      );
                      await signUpProvider.signup(
                        appName: widget.provider.tetAppName.text,
                        versionCode: widget.provider.tetVersionCode.text,
                        accessToken: widget.provider.tetAccessToken.text,
                        logoUrl: widget.provider.tetAppLogo.text,
                        countryCode:
                            widget.provider.tetCountryCodeController.text,
                        email: widget.provider.tetEmail.text,

                        storeName: widget.provider.tetStoreName.text,
                        websiteUrl: widget.provider.tetAppLogo.text,
                        mobile: widget.provider.tetPhone.text,
                        name: widget.provider.tetFullName.text,
                      );
                      widget.provider.getUsersByStoreName(
                        widget.provider.tetStoreName.text.trim(),
                      );
                    }

                    //widget.provider.updateUser( widget.data["uid"]);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
            provider.isUpdated ? showLoaderList() : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

Widget notificationWidget({String? value, void Function()? onTap}) {
  return commonInkWell(
    onTap:
        onTap ??
        () {
          navigatorKey.currentState?.pushNamed(RouteName.notificationScreen);
        },
    child: Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            commonPrefixIcon(
              image: icNotification,
              width: 24,
              height: 24,
              colorIcon: colorText,
            ),

            Positioned(
              right: -4,
              top: -9,
              child: Container(
                width: 20,
                height: 20,
                decoration: commonBoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: commonText(
                    text: value ?? "0",
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
