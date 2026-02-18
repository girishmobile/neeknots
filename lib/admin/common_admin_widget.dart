import 'package:flutter/material.dart';
import 'package:neeknots/core/component/CommonSwitch.dart';
import 'package:neeknots/provider/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

import '../core/component/component.dart';
import '../core/component/phone_number_field.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.setStatus(widget.data["active_status"] ?? false);
      });
    }else
      {
        widget.provider.tetStoreName.text = widget.data["store_name"];
        widget.provider.tetAccessToken.text = widget.data["accessToken"];
        widget.provider.tetVersionCode.text = widget.data["version_code"];
      }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                commonTextField(
                  keyboardType: TextInputType.name,
                  prefixIcon: commonPrefixIcon(image: icUser),
                  controller: widget.provider.tetFullName,
                  hintText: "Full Name",
                ),
                const SizedBox(height: 20),

                commonTextField(
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  readOnly: widget.isEdit ? true : false,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  filled: widget.isEdit ? true : false,

                  prefixIcon: commonPrefixIcon(image: icEmail),
                  controller: widget.provider.tetEmail,
                  hintText: "Email Address",
                ),

                const SizedBox(height: 20),
                PhoneNumberField(
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  filled: widget.isEdit ? true : false,
                  phoneController: widget.provider.tetPhone,
                  countryCodeController:
                      widget.provider.tetCountryCodeController,
                  prefixIcon: commonPrefixIcon(image: icPhone),
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return "Enter 10 digit phone number";
                    }
                    return null;
                  },
                  isCountryCodeEditable: widget.isEdit ? false : true,
                  // fixed +1
                  isPhoneEditable: widget.isEdit ? false : true, // fixed +1
                ),
                /*commonTextField(
                  hintText: "Phone No",
                  controller: widget.provider.tetPhone,
                  readOnly: true,
                  maxLines: 1,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  filled: true,

                  keyboardType: TextInputType.phone,
                  validator: validateTenDigitPhone,
                  prefixIcon: commonPrefixIcon(image: icPhone),
                ),*/
                const SizedBox(height: 20),
                commonTextField(
                  hintText: "Store Name",
                  controller: widget.provider.tetStoreName,

                  maxLines: 1,

                  keyboardType: TextInputType.text,

                  prefixIcon: commonPrefixIcon(image: icStore),
                ),
                const SizedBox(height: 20),
                commonTextField(
                  hintText: "Access Token",
                  controller: widget.provider.tetAccessToken,

                  maxLines: 1,

                  keyboardType: TextInputType.text,

                  prefixIcon: commonPrefixIcon(image: icAccessToken),
                ),

                const SizedBox(height: 20),
                commonTextField(
                  hintText: "App Version Code",
                  controller: widget.provider.tetVersionCode,

                  maxLines: 1,

                  keyboardType: TextInputType.text,

                  prefixIcon: commonPrefixIcon(image: icVersionCode),
                ),
                const SizedBox(height: 20),
                commonTextField(
                  hintText: "App Logo Url",
                  controller: widget.provider.tetAppLogo,

                  maxLines: 1,

                  keyboardType: TextInputType.text,

                  prefixIcon: commonPrefixIcon(image: icAppLogoImage),
                ),
                const SizedBox(height: 20),
                commonTextField(
                  hintText: "Website Url",
                  controller: widget.provider.tetWebsiteUrl,

                  maxLines: 1,

                  keyboardType: TextInputType.url,

                  prefixIcon: commonPrefixIcon(image: icNetwork),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonText(text: "Account Status:"),
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

                const SizedBox(height: 20),
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
                        versionCode: widget.provider.tetVersionCode
                            .text,
                        accessToken: widget.provider.tetAccessToken
                            .text,
                        logoUrl: widget.provider.tetAppLogo
                            .text,
                        countryCode:    widget.provider.tetCountryCodeController.text,
                        email:  widget.provider.tetEmail.text,

                        storeName: widget.provider.tetStoreName.text,
                        websiteUrl: widget.provider.tetAppLogo.text,
                        mobile: widget.provider.tetPhone.text,
                        name: widget.provider.tetFullName.text,

                      );
                     widget.provider.getUsersByStoreName(widget.provider.tetStoreName.text.trim(),);

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
              colorIcon: Colors.white,
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
