import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/validation/validation.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/component/common_intl_phone_field.dart';
import '../../../main.dart';
import '../../../provider/theme_provider.dart';

Widget commonSignUpView({
  required LoginProvider provider,
  required void Function() onPressed,
  GestureRecognizer? onPressSignUp,
}) {
  final themeProvider = Provider.of<ThemeProvider>(
    navigatorKey.currentContext!,
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      commonTextField(
        keyboardType: TextInputType.name,
        prefixIcon: commonPrefixIcon(image: icUser),
        controller: provider.tetFullName,
        validator: (value) =>
            emptyError(value, errorMessage: "Full Name is required"),
        hintText: "Full Name",
      ),
      const SizedBox(height: 20),

      commonTextField(
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,

        prefixIcon: commonPrefixIcon(image: icEmail),
        controller: provider.tetEmail,
        hintText: "Email Address",
      ),

      const SizedBox(height: 20),
      CommonIntlPhoneField(
        phoneController: provider.tetPhone,
        onCountryChanged: (value) {
          final dialCode = "+${value.dialCode}";

          provider.tetCountryCodeController.text = dialCode;
        },
        onChanged: (phone) {
          provider.tetCountryCodeController.text = phone.countryCode;
        },
      ),

      const SizedBox(height: 10),
      commonTextField(
        keyboardType: TextInputType.name,
        validator: (value) =>
            emptyError(value, errorMessage: "App Name is required"),

        prefixIcon: commonPrefixIcon(image: icStore),
        controller: provider.tetAppName,
        hintText: "App Name",
      ),
      const SizedBox(height: 20),
      commonTextField(
        hintText: "Store Name/Website Url",
        controller: provider.tetStoreName,
        validator: (value) =>
            emptyError(value, errorMessage: "Store name is required"),
        maxLines: 1,

        keyboardType: TextInputType.text,

        prefixIcon: commonPrefixIcon(image: icStore),
      ),

      const SizedBox(height: 50),
      commonButton(text: "Create", onPressed: onPressed),
      const SizedBox(height: 20),
      commonTextRich(
        onTap: onPressSignUp,
        text1: "Already have an account? ",
        text2: "Login",
        textStyle1: commonTextStyle(
          color: themeProvider.isDark ? Colors.white : Colors.black,
        ),
        textStyle2: commonTextStyle(
          color: themeProvider.isDark ? Colors.white : colorLogo,
          fontWeight: FontWeight.w600,
        ),
      ),

      //commonText(text: "Don't have an account? Signup"),
    ],
  );
}
