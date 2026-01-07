import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

Widget commonProductListView({
  required String image,
  String? textInventory1,
  String? textInventory2,
  double ? width,
  void Function()? onTap,
  String? price,
  EdgeInsetsGeometry? imageMargin,
  Color? colorStatusColor,
  EdgeInsetsGeometry? margin,
  required String productName,
  Decoration? decoration,
  required String status,
}) {
  return Consumer<ThemeProvider>(
    builder: (context, provider, child) {
      return Container(
        width: width,

        decoration: commonBoxDecoration(borderColor: colorBorder),
        margin: margin??const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: commonInkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              spacing: 10,
              children: [
                Container(
                  width: 100,
                  height: 100,

                  margin: imageMargin,
                  clipBehavior: Clip.antiAlias,
                  decoration: commonBoxDecoration(borderRadius: 10),
                  child: commonNetworkImage(
                    image,
                  ) /*Image.network(fit: BoxFit.cover, image)*/,
                ),
                Expanded(
                  child: Column(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonText(
                        text: productName,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: provider.isDark ? Colors.white : colorLogo,
                      ),
                      commonText(
                        text: price ?? '',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),

                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$textInventory1 ", // first part
                              style: commonTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorOffline,
                              ),
                            ),
                            TextSpan(
                              text: textInventory2, // second part
                              style: commonTextStyle(
                                fontSize: 10,
                                color: provider.isDark
                                    ? Colors.white
                                    : colorText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: colorStatusColor != null
                        ? colorStatusColor.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: commonText(
                    text: status,
                    color: colorStatusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
      );
    },
  );
}
