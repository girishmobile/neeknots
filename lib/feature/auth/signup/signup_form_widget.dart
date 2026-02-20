import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/validation/validation.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/component/phone_number_field.dart';
import '../../../main.dart';
import '../../../provider/theme_provider.dart';

Widget commonSignUpView({
  required LoginProvider provider,
  required void Function() onPressed,
  GestureRecognizer? onPressSignUp,
}) {
  final themeProvider = Provider.of<ThemeProvider>(navigatorKey.currentContext!);
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
      /*  commonTextField(
        hintText: "Phone No",
        controller: provider.tetPhone,

        maxLines: 1,

        keyboardType: TextInputType.phone,
        validator: validateTenDigitPhone,
        prefixIcon: commonPrefixIcon(image: icPhone),
      ),*/
      /* Row(
        children: [
          SizedBox(
            width: 70,
            child: commonTextField(
              initialValue: "+1",
              keyboardType: TextInputType.phone, hintText: '',

            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: commonTextField(
              hintText: "Phone No",
              controller: provider.tetPhone,
              maxLines: 1,
              keyboardType: TextInputType.phone,
              validator: validateTenDigitPhone,
              prefixIcon: commonPrefixIcon(image: icPhone),
            ),
          ),
        ],
      ),*/

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
          provider.tetCountryCodeController.text = phone.countryCode;
        },
        onCountryChanged: (value) {
          provider.tetCountryCodeController.text = value.dialCode;
        },
      ),
  /*  PhoneNumberField(
        phoneController: provider.tetPhone,
        countryCodeController: provider.tetCountryCodeController,
        prefixIcon: commonPrefixIcon(image: icPhone),
        validator: (value) {
          if (value == null || value.length != 10) {
            return "Enter 10 digit phone number";
          }
          return null;
        },
          isCountryCodeEditable: true, // fixed +1
      ),*/
      const SizedBox(height: 10),
      commonTextField(
        hintText: "Store Name/Website Url",
        controller: provider.tetStoreName,
        validator: (value) =>
            emptyError(value, errorMessage: "Store name is required"),
        maxLines: 1,

        keyboardType: TextInputType.text,

        prefixIcon: commonPrefixIcon(image: icStore),
      ),
     /* const SizedBox(height: 20),
      commonTextField(
        hintText: "Logo Url",

        controller: provider.tetLogoUrl,

        maxLines: 1,

        keyboardType: TextInputType.url,

        prefixIcon: commonPrefixIcon(image: icNetwork),
      ),*/
     /* const SizedBox(height: 20),
      commonTextField(
        hintText: "Website Url",

        controller: provider.tetWebsiteUrl,

        maxLines: 1,

        keyboardType: TextInputType.url,

        prefixIcon: commonPrefixIcon(image: icNetwork),
      ),*/
      const SizedBox(height: 50),
      commonButton(text: "Create", onPressed: onPressed),
      const SizedBox(height: 20),
      commonTextRich(
        onTap: onPressSignUp,
        text1: "Already have an account? ",
        text2: "Login",
        textStyle1: commonTextStyle(color: themeProvider.isDark?Colors.white:Colors.black),
        textStyle2: commonTextStyle(
          color: themeProvider.isDark?Colors.white:colorLogo,
          fontWeight: FontWeight.w600,
        ),
      ),

      //commonText(text: "Don't have an account? Signup"),
    ],
  );
}
