import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

Widget commonOrderView({
  required String image,
  String? date,
  String? orderID,
  double? width,
  Widget? errorImageView,

  EdgeInsetsGeometry? margin,
  Color? colorTextStatus,
  void Function()? onTap,
  required String productName,
  required double price,
  Decoration? decoration,
  required String status,
  bool? invisibleCustomer = true,
}) {
  return Consumer<ThemeProvider>(
    builder: (context, provider, child) {
      return Container(
        width: width, // 👈 fix width for horizontal card
        decoration: commonBoxDecoration(borderColor: colorBorder),
        margin:
            margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: commonInkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonOrderItemView(
                  fontWeight: FontWeight.w600,

                  colorValue: provider.isDark ? Colors.white : colorLogo,
                  text: "Order",
                  value: image,
                ),
                if (invisibleCustomer == true)
                  commonOrderItemView(text: "Customer", value: orderID),

                commonOrderItemView(text: "Items", value: productName),
                commonOrderItemView(
                  colorValue: provider.isDark ? Colors.white : colorTextDesc,
                  text: "Payment Status",

                  valueView: Container(
                    decoration:
                        decoration ??
                        commonBoxDecoration(
                          borderRadius: 8,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 5,
                      bottom: 5,
                    ),
                    child: commonText(
                      text: status,
                      fontSize: 10,
                      color: colorTextStatus,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                commonOrderItemView(
                  colorValue: Colors.blueAccent,
                  text: "Total",
                  fontWeight: FontWeight.w600,
                  value: '$rupeeIcon$price',
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget commonOrderItemView({
  String? text,
  String? value,
  Widget? valueView,
  FontWeight? fontWeight,
  Color? colorText,
  Color? colorValue,
}) {
  return Row(
    children: [
      Expanded(
        child: commonText(
          text: text ?? "Order No",
          fontWeight: fontWeight ?? FontWeight.w500,
          fontSize: 12,
          color: colorText,
        ),
      ),
      valueView ??
          commonText(
            textAlign: TextAlign.left,
            text: value ?? '',

            fontWeight: fontWeight ?? FontWeight.w500,
            fontSize: 12,
            color: colorValue,
          ),
    ],
  );
}
