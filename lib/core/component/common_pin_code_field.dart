import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CommonPinCodeField extends StatelessWidget {
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color activeFillColor;
  final Color inactiveFillColor;
  final Color selectedFillColor;
  final Color inactiveBorderColor;
  final Color selectedBorderColor;
  final Color activeBorderColor;
  final double fieldHeight;
  final double fieldWidth;
  final double borderRadius;
  final TextEditingController? controller;
  const CommonPinCodeField({
    super.key,

    this.onCompleted,
    this.onChanged,
    this.textStyle,
    this.hintStyle,
    this.activeFillColor = Colors.blue,
    this.inactiveFillColor = Colors.grey,
    this.selectedFillColor = Colors.blueGrey,
    this.inactiveBorderColor = Colors.grey,
    this.selectedBorderColor = Colors.black,
    this.activeBorderColor = Colors.transparent,
    this.fieldHeight = 50,
    this.controller,
    this.fieldWidth = 50,
    this.borderRadius = 5,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialPinField(
      appContext: context,
      length: 4,

      controller: controller,
      autoDisposeControllers: false,
      mainAxisAlignment: MainAxisAlignment.center,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      textStyle:
          textStyle ??
          commonTextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
      hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        fieldOuterPadding: EdgeInsets.symmetric(horizontal: 20),
        borderRadius: BorderRadius.circular(borderRadius),
        fieldHeight: fieldHeight,
        fieldWidth: fieldWidth,
        activeFillColor: activeFillColor,
        inactiveFillColor: inactiveFillColor,
        selectedFillColor: selectedFillColor,
        inactiveColor: inactiveBorderColor,
        selectedColor: selectedBorderColor,
        activeColor: activeBorderColor,
        borderWidth: 0.5,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      onCompleted: onCompleted,
      onChanged: onChanged,
      beforeTextPaste: (text) => true,
    );
  }
}
