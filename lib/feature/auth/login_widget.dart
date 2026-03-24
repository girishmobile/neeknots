import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:provider/provider.dart';

import '../../core/component/common_intl_phone_field.dart';
import '../../core/validation/validation.dart';
import '../../main.dart';
import '../../provider/theme_provider.dart';

//https://neeknots-a8758.web.app
Widget commonLoginView({
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

        fillColor: Colors.white,
        filled: false,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        prefixIcon: commonPrefixIcon(image: icEmail),
        controller: provider.tetEmail,
        hintText: "Email",
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

      const SizedBox(height: 40),
      commonButton(text: "Login", onPressed: onPressed),
      const SizedBox(height: 20),
      commonTextRich(
        onTap: onPressSignUp,
        text1: "Don't have an account? ",
        text2: "Setup Account",
        textStyle1: commonTextStyle(
          color: themeProvider.isDark ? Colors.white : Colors.black,
        ),
        textStyle2: commonTextStyle(
          color: themeProvider.isDark ? Colors.white : colorLogo,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 20),
    ],
  );
}
