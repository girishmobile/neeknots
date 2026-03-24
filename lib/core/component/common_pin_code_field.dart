import 'package:flutter/material.dart';
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
  final PinInputController? pinController;

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
    this.pinController,
    this.fieldWidth = 50,
    this.borderRadius = 5,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialPinField(
      pinController: pinController,
      length: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      keyboardType: TextInputType.number,
      hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
      theme: MaterialPinTheme(
        // Shape
        shape: MaterialPinShape.outlined,
        cellSize: Size(56, 64),
        spacing: 12,
        borderRadius: BorderRadius.circular(borderRadius),

        // Border
        borderWidth: 1.5,
        focusedBorderWidth: 2.0,
        borderColor: Colors.grey,
        focusedBorderColor: Colors.black54,
        filledBorderColor: Colors.black,
        errorColor: Colors.red,

        // Fill
        fillColor: Colors.transparent,
        focusedFillColor: Colors.black45,
        filledFillColor: Colors.black87,

        // Text
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        showCursor: true,
        cursorColor: Colors.black,
        cursorWidth: 2,
        animateCursor: true,

        // Animation
        entryAnimation: MaterialPinAnimation.scale,
        animationDuration: Duration(milliseconds: 150),
        animationCurve: Curves.easeOut,

        // Error
        enableErrorShake: true,
        errorAnimationDuration: Duration(milliseconds: 500),
      ),
    );
  }
}
