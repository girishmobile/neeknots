import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'component.dart';

class CommonIntlPhoneField extends StatelessWidget {
  final TextEditingController phoneController;

  final String initialCountryCode;

  final String hintText;
  final void Function(PhoneNumber) onChanged;
  final void Function(Country) onCountryChanged;

  const CommonIntlPhoneField({
    super.key,
    required this.phoneController,
    required this.onCountryChanged,
    this.initialCountryCode = 'US',
    this.hintText = "Phone Number",
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        double width = constraints.maxWidth;
        double containerWidth;
        double padding;
        if (width >= 1200) {
          // Desktop
          containerWidth = width * 0.25;
          padding = 36;
        } else if (width >= 800) {
          // Tablet
          containerWidth = width * 0.5;
          padding = 30;
        } else {
          // Mobile
          containerWidth = width * 0.9;
          padding = 24;
        }
        return IntlPhoneField(
          pickerDialogStyle: PickerDialogStyle(
            padding: EdgeInsets.all(padding),
            backgroundColor: Colors.white,
            width: containerWidth,
            countryNameStyle: commonTextStyle(),

            countryCodeStyle: commonTextStyle(),
          ),
          initialCountryCode: initialCountryCode,
          controller: phoneController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],

          style: TextStyle(color: Colors.black),

          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.white,
            filled: false,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: commonTextFiledBorder(borderRadius: 12),
            enabledBorder: commonTextFiledBorder(borderRadius: 12,borderColor: Colors.pinkAccent.withValues(alpha: 0.2)),
            focusedBorder: commonTextFiledBorder(borderRadius: 12,borderColor: Colors.pinkAccent.withValues(alpha: 0.5)),
          ),

          onChanged: onChanged,
          onCountryChanged: onCountryChanged,

        );
      }
    );
  }
}
