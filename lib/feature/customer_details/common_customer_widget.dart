import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/feature/order_details/order_common_widget.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:provider/provider.dart';

import '../../core/component/date_utils.dart';
import '../../models/customer_model.dart';

Widget customerDetailsInfo({required Customer customer}) {
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8,color: colorBgNew),
    margin: EdgeInsets.only(left: 16, right: 16, top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        commonHeadingView(title: "Customer  Information", isPayment: false),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildRow(
                title: "Name",
                value: "${customer.firstName} ${customer.lastName}",
              ),
              _buildRow(title: "email", value: customer.email ?? '-'),
              _buildRow(
                title: "Customer Since",
                value: timeAgo(customer.createdAt ?? DateTime.now().toString()),
              ),

              _buildRow(
                title: "Amount Spent",
                value: "$rupeeIcon${"${customer.totalSpent}"}",
              ),
              _buildRow(title: "Order", value: '${customer.ordersCount}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonText(text: "Default  address", fontWeight: FontWeight.w600),
              commonText(
                text:
                    '${customer.defaultAddress?.company ?? ''}\n${customer.defaultAddress?.address1 ?? ''} ${customer.defaultAddress?.address2 ?? ''}\n${customer.defaultAddress?.zip ?? ''} ${customer.defaultAddress?.city ?? ''} ${customer.defaultAddress?.province ?? ''}\n${customer.defaultAddress?.country ?? ''}\n${customer.defaultAddress?.phone ?? ''}',

                fontSize: 12,
              ),
            ],
          ),
        ),

        // Content
      ],
    ),
  );
}

Widget customerOrderDetailsInfo({required Customer customer}) {
  return Container(
    decoration: commonBoxDecoration(borderColor: colorBorder, borderRadius: 8),
    margin: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        commonHeadingView(title: "Details  Information", isPayment: false),
        const Divider(height: 1),

        // Content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildRow(title: "Customer Since", value: "7 Month"),
              _buildRow(title: "RFM Group", value: "Needs Attentions"),
            ],
          ),
        ),

        const Divider(height: 1),

        // Footer text
      ],
    ),
  );
}

Widget customerProductInfo({required Customer customer}) {
  return Consumer<OrdersProvider>(
    builder: (context, provider, child) {
      return Container(
        decoration: commonBoxDecoration(
          borderColor: colorBorder,
          color: colorBgNew,
          borderRadius: 8,
        ),
        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            commonHeadingView(isPayment: false, title: "Last Order Placed"),

            const Divider(height: 1),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 20,
                      children: [
                        commonText(
                          text: customer.lastOrderName ?? "",
                          fontWeight: FontWeight.w600,
                        ),
                        Container(
                          decoration: commonBoxDecoration(color: colorBorder),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 3,
                            ),
                            child: commonText(
                              text:
                                  provider
                                      .orderDetailsModel
                                      ?.orderData
                                      ?.financialStatus
                                      .toString()
                                      .toCapitalize() ??
                                  '',
                              fontSize: 10,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: commonBoxDecoration(
                            color:
                                provider
                                        .orderDetailsModel
                                        ?.orderData
                                        ?.fulfillmentStatus !=
                                    null
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.amber.withValues(alpha: 0.1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 3,
                          ),
                          child: commonText(
                            text:
                                provider
                                        .orderDetailsModel
                                        ?.orderData
                                        ?.fulfillmentStatus !=
                                    null
                                ? provider
                                          .orderDetailsModel
                                          ?.orderData
                                          ?.fulfillmentStatus
                                          .toString()
                                          .toCapitalize() ??
                                      ''
                                : "Unfulfilled",
                            fontSize: 10,

                            color:
                                provider
                                        .orderDetailsModel
                                        ?.orderData
                                        ?.fulfillmentStatus !=
                                    null
                                ? Colors.green
                                : Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      commonText(
                        text:
                            "$rupeeIcon${provider.orderDetailsModel?.orderData?.currentTotalPrice ?? "0"}",
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: commonText(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                text: formatCreatedAt(
                  provider.orderDetailsModel?.orderData?.createdAt ??
                      DateTime.now().toString(),
                  source: "Orders",
                ),
                //text: "13 Sept 2025 at 7:19 pm from  Draft Orders",
              ),
            ),
            SizedBox(height: 10),
            const Divider(height: 1),
            // Content
            Consumer<OrdersProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: commonListViewBuilder(
                    shrinkWrap: true,
                    padding: EdgeInsetsGeometry.zero,
                    items:
                        provider.orderDetailsModel?.orderData?.lineItems ?? [],
                    itemBuilder: (context, index, data1) {
                      var data = provider
                          .orderDetailsModel
                          ?.orderData
                          ?.lineItems?[index];
                      //final parts = data?.name?.split('-');
                      final parts =
                          data?.name
                              ?.split('-')
                              .map((e) => e.trim())
                              .toList() ??
                          [];

                      // first part
                      final firstText = parts.isNotEmpty ? parts[0] : '';

                      // second part (rest join back if multiple parts)
                      final secondText = parts.length > 1
                          ? parts.sublist(1).join(' - ')
                          : '';

                      return Container(
                        decoration: commonBoxDecoration(
                          borderColor: colorBorder,
                        ),
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
                                          color: colorBorder.withValues(
                                            alpha: 0.1,
                                          ),
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
    },
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
