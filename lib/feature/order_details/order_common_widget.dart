import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../core/color/color_utils.dart';
import '../../main.dart';
import '../../models/order_details_model.dart';

Widget productInfo({required OrderData order}) {
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        commonHeadingView(isPayment: false),

        const Divider(height: 1),

        // Content
        Consumer<OrdersProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: commonListViewBuilder(
                shrinkWrap: true,
                padding: EdgeInsetsGeometry.zero,
                items: order.lineItems ?? [],
                itemBuilder: (context, index, data1) {
                  var data = order.lineItems?[index];
                  //final parts = data?.name?.split('-');
                  final parts =
                      data?.name?.split('-').map((e) => e.trim()).toList() ??
                      [];

                  // first part
                  final firstText = parts.isNotEmpty ? parts[0] : '';

                  // second part (rest join back if multiple parts)
                  final secondText = parts.length > 1
                      ? parts.sublist(1).join(' - ')
                      : '';

                  return Container(
                    decoration: commonBoxDecoration(borderColor: colorBorder),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.all(3.0),
                    child: Row(
                      spacing: 10,
                      children: [
                        commonNetworkImage(
                          borderRadius: 10,
                          fit: BoxFit.cover,
                          shape: BoxShape.rectangle,
                          data?.imageUrl,
                          size: 90,
                        ),
                        Expanded(
                          child: Column(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              commonText(
                                text: firstText,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              Container(
                                decoration: commonBoxDecoration(
                                  color: colorBorder.withValues(alpha: 0.1),
                                  borderRadius: 5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                child: commonText(
                                  fontWeight: FontWeight.w500,
                                  text: secondText,
                                  fontSize: 10,
                                ),
                              ),
                              Row(
                                spacing: 3,
                                children: [
                                  commonText(
                                    text: 'Qty:',
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Container(
                                    decoration: commonBoxDecoration(
                                      borderRadius: 5,
                                      color: colorBorder.withValues(alpha: 0.1),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 5,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      // important to shrink row
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      // ensures vertical center
                                      children: [
                                        commonText(
                                          text:
                                              '$rupeeIcon${data?.price ?? ''} ',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        SizedBox(width: 3),
                                        // spacing instead of Row.spacing
                                        commonText(
                                          text: "*",
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        SizedBox(width: 3),
                                        commonText(
                                          text: '${data?.quantity}',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: commonText(
                            text: '$rupeeIcon${data?.price ?? ''}',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget commonHeadingView({String? title, required bool isPayment}) {
  return Padding(
    padding: EdgeInsets.all(12.0),
    child: Row(
      children: [
        Expanded(
          child: commonText(
            text: title ?? "Product Information",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget orderInfo({required OrderData order}) {
  final themeProvider = Provider.of<ThemeProvider>(
    navigatorKey.currentContext!,
  );
  final provider = Provider.of<OrdersProvider>(navigatorKey.currentContext!);
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonHeadingView(title: "Order Information", isPayment: false),

        const Divider(height: 1),

        // Content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildRow(
                colorText: themeProvider.isDark ? Colors.white : colorLogo,
                title: "Order No",
                value: order.name ?? '',
                fontWeight: FontWeight.w600,
              ),
              _buildRow(
                fontSize: 14,

                fontWeight: FontWeight.w600,
                title: "Delivery Status",
                value: provider.getDeliveryStatus(order),
              ),
              _buildRow(
                fontSize: 14,

                fontWeight: FontWeight.w600,
                title: "Delivery Method",
                value:
                    order.shippingLine != null &&
                        order.shippingLine?.isNotEmpty == true
                    ? order.shippingLine![0].title
                    : 'Shipping',
              ),

              _buildRow(
                title: "Payment Status",
                value: provider.getPaymentStatus(order),
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget customerInfo({required OrderData order}) {
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        commonHeadingView(title: "Contact information", isPayment: false),

        const Divider(height: 1),

        // Content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildRow(
                title: "Name",
                value: order.customer?.firstName != null
                    ? '${order.customer?.firstName} ${order.customer?.lastName}'
                    : noCustomer,
              ),
              _buildRow(
                title: "Email",
                value: order.customer?.email != null
                    ? '${order.customer?.email}'
                    : "-",
              ),
              _buildRow(
                title: "Mobile",
                value: order.customer?.phone != null
                    ? '${order.customer?.phone}'
                    : "-",
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Footer text
        order.customer?.defaultAddress != null
            ? Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonText(
                      text: "Shipping address",
                      fontWeight: FontWeight.w600,
                    ),
                    commonText(
                      text:
                          '${order.customer?.defaultAddress?.company ?? ''}\n${order.customer?.defaultAddress?.address1 ?? ''} ${order.customer?.defaultAddress?.address2 ?? ''}\n${order.customer?.defaultAddress?.zip ?? ''} ${order.customer?.defaultAddress?.city ?? ''} ${order.customer?.defaultAddress?.province ?? ''}\n${order.customer?.defaultAddress?.country ?? ''}\n${order.customer?.defaultAddress?.phone ?? ''}',

                      fontSize: 12,
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
        order.billingAddress != null
            ? Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonText(
                      text: "Billing address",
                      fontWeight: FontWeight.w600,
                    ),
                    commonText(
                      text:
                          [
                                order.billingAddress?.address1,
                                order.billingAddress?.address2,
                                order.billingAddress?.zip,
                                order.billingAddress?.city,
                                order.billingAddress?.province,
                                order.billingAddress?.country,
                              ]
                              .where(
                                (e) => e != null && e.trim().isNotEmpty,
                              ) // null/empty remove
                              .join(' '), // single line with space
                      fontSize: 12,
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
      ],
    ),
  );
}

Widget paymentSummery({required OrderData order}) {
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        commonHeadingView(title: "Payment", isPayment: true),

        const Divider(height: 1),

        // Content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildRowPayment(
                title: "Subtotal",
                amount: "$rupeeIcon${order.currentTotalPrice ?? "0"}",
                value: "${order.lineItems?.length ?? "0"} items",
              ),

              const SizedBox(height: 8),
              const Divider(),
              _buildRowPayment(
                title: "Total",
                fontWeight: FontWeight.w600,
                amount: "$rupeeIcon${order.currentTotalPrice ?? "0"}",
                fontSize: 14,
              ),
              _buildRowPayment(
                title: "Paid",
                fontWeight: FontWeight.w400,
                amount: "$rupeeIcon${order.currentTotalPrice ?? "0"}",
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildRow({
  required String title,
  required String value,
  FontWeight? fontWeight,
  Color? colorText,
  Decoration? decoration,
  EdgeInsetsGeometry? padding,
  double? fontSize,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        commonText(text: title, fontWeight: FontWeight.w400, fontSize: 14),
        Container(
          padding: padding,
          decoration: decoration,
          child: commonText(
            text: value,
            fontWeight: fontWeight ?? FontWeight.w500,
            fontSize: fontSize ?? 14,
            color: colorText,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRowPayment({
  required String title,
  String? value,
  double? fontSize,
  FontWeight? fontWeight,
  required String amount,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Expanded(
          child: commonText(
            textAlign: TextAlign.left,
            text: title,
            fontWeight: fontWeight ?? FontWeight.w400,
            fontSize: fontSize ?? 12,
          ),
        ),

        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonText(
                text: value ?? '',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        Expanded(
          child: commonText(
            textAlign: TextAlign.right,
            text: amount,
            fontWeight: fontWeight ?? FontWeight.w500,
            fontSize: fontSize ?? 12,
          ),
        ),
      ],
    ),
  );
}
