import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:provider/provider.dart';

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
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        prefixIcon: commonPrefixIcon(image: icEmail),
        controller: provider.tetEmail,
        hintText: "Email",
      ),
      const SizedBox(height: 20),

      IntlPhoneField(
        initialCountryCode: 'US',
        controller: provider.tetPhone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: commonTextStyle(
          color: themeProvider.isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: "Phone Number",
          hintStyle: commonTextStyle(color: Colors.grey),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: commonTextFiledBorder(borderRadius: 12),
          enabledBorder: commonTextFiledBorder(borderRadius: 12),
          focusedBorder: commonTextFiledBorder(borderRadius: 12),
        ),
        onChanged: (phone) {
          print('=-=====phone$phone');
          provider.tetCountryCodeController.text = phone.countryCode;
        },
        onCountryChanged: (value) {
          print('=-=====value${value.dialCode}');
          print('=-=====value${value.fullCountryCode}');
          provider.tetCountryCodeController.text = value.dialCode;
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
