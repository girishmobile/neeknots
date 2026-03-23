import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/common_dropdown.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/provider/product_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/component/common_date_range_picker.dart';
import '../../../core/component/date_utils.dart';
import '../../../core/string/string_utils.dart';
import '../order_widget/common_order_widget.dart';
import '../product_widget/common_product_widget.dart';

Widget homeTopView({
  required int totalProduct,
  required int totalOrder,
  required int totalCustomer,
  required int totalSaleOrder,
  required double totalOrderPrice,
  required int totalPendingRequest,
}) {
  return Consumer<ThemeProvider>(
    builder: (context, provider, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: commonText(
                  text: "Store Summary",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _commonDashboardView(
                  color: colorSale,
                  provider: provider,
                  icon: icTotalSale,
                  title: "Today's Orders",
                  subtitle: "$rupeeIcon$totalOrderPrice",
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.salesDetailsScreen,
                      arguments: 278,
                    );
                  },
                  leftText: "",
                  rightText: "",
                  value: totalSaleOrder,
                ),
              ),
              Expanded(
                child: _commonDashboardView(
                  color: colorProduct,
                  provider: provider,
                  leftText: '',
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.totalProductScreen,
                    );
                  },
                  icon: icProductMenu,
                  title: "Total Products",

                  value: totalProduct,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _commonDashboardView(
                  color: Colors.blue.shade400,
                  icon: icOrderMenu,
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.totalOrderScreen,
                    );
                  },
                  provider: provider,
                  title: "Total  Orders",
                  leftText: '',

                  value: totalOrder,
                ),
              ),
              Expanded(
                child: _commonDashboardView(
                  color: colorUser,
                  onTap: () {
                    navigatorKey.currentState?.pushNamed(
                      RouteName.totalCustomerScreen,
                    );
                  },
                  provider: provider,
                  icon: icTotalUser,
                  leftText: '',
                  title: "Total Customers",

                  value: totalCustomer,
                ),
              ),
            ],
          ),
          commonInkWell(
            onTap: () {
              navigatorKey.currentState?.pushNamed(
                RouteName.pendingRequestScreen,
              );
            },
            child: Container(
              margin: EdgeInsets.all(5),
              padding: const EdgeInsets.all(16),
              decoration: commonBoxDecoration(
                color: Colors.amber.withValues(alpha: 0.05),
                borderColor: Colors.amber.withValues(alpha: 0.3),
                borderRadius: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2), // border thickness
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white, // border color
                              width: 1.5, // border width
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,

                            backgroundColor: Colors.white,
                            child: Center(
                              child: commonAssetImage(
                                icNotification,
                                width: 20,
                                height: 20,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        commonText(
                          text: "Pending Approval",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.left,
                          color: provider.isDark ? Colors.white : colorText,
                        ),
                      ],
                    ),
                  ),

                  commonText(
                    text: '$totalPendingRequest',
                    style: commonTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: provider.isDark ? Colors.white : colorTextDesc1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _commonDashboardView({
  Color? color,
  required ThemeProvider provider,
  required String icon,
  required String title,
  String? subtitle,
  required int value,
  String? leftText,
  String? rightText,
  void Function()? onTap,
}) {
  return commonInkWell(
    onTap: onTap,
    child: Container(
      width: 140,
      margin: EdgeInsets.all(5),
      padding: const EdgeInsets.all(16),
      decoration: commonBoxDecoration(
        color:
            color?.withValues(alpha: 0.05) ?? colorLogo.withValues(alpha: 0.1),

        borderColor:
            color?.withValues(alpha: 0.3) ?? colorLogo.withValues(alpha: 0.3),
        borderRadius: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2), // border thickness
            decoration: BoxDecoration(

              shape: BoxShape.circle,
              border: Border.all(
                color: color ?? Colors.transparent, // border color
                width: 1.5, // border width
              ),
            ),
            child: CircleAvatar(
              radius: 28,

              backgroundColor: Colors.white,
              child: Center(
                child: commonAssetImage(
                  icon,
                  width: 24,
                  height: 24,
                  color: color ?? Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          commonText(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: provider.isDark ? Colors.white : colorText,
          ),
          commonText(text: "$value", fontSize: 25, fontWeight: FontWeight.w600),
          commonText(
            text: subtitle ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: provider.isDark ? Colors.white : colorLogo,
          ),
        ],
      ),
    ),
  );
}

Widget homeGraphView({required bool isSaleDetails}) {
  return Consumer2<ThemeProvider, OrdersProvider>(
    builder: (context, themeProvider, orderProvider, child) {
      final data = orderProvider.orderModelByDate?.orders ?? [];
      final chartData = data.map((order) {
        return SalesData(
          orderNumber: order.name.toString(),
          totalPrice: double.tryParse(order.totalPrice ?? "0") ?? 0,
        );
      }).toList();
      return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            isSaleDetails
                ? SizedBox.shrink()
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: commonText(
                          text: "Order Summary",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Flexible(
                        flex: 4,
                        child: SizedBox(
                          height: 45,
                          child: CommonDropdown(
                            borderRadius: 5,
                            initialValue: orderProvider.selectedRange,
                            items: ["Today", "This Week", "This Month"],

                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                orderProvider.setRange(
                                  newValue,
                                ); // update Provider

                                orderProvider.fetchByRange(newValue);
                              }
                            },
                          ),
                        ),
                      ),

                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: commonBoxDecoration(
                            borderColor: colorBorder,
                            borderRadius: 5,
                          ),
                          child: Center(
                            child: IconButton(
                              alignment: Alignment.center,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                final provider = Provider.of<OrdersProvider>(
                                  context,
                                  listen: false,
                                );
                                final productProvider =
                                    Provider.of<ProductProvider>(
                                      context,
                                      listen: false,
                                    );
                                CommonDateRangePicker.show(
                                  context: context,
                                  onApplyClick: (start, end) {
                                    DateTime startDate = DateTime(
                                      start.year,
                                      start.month,
                                      start.day,
                                      0,
                                      0,
                                      0,
                                    );
                                    DateTime endDate = DateTime(
                                      end.year,
                                      end.month,
                                      end.day,
                                      23,
                                      59,
                                      59,
                                    );
                                    debugPrint(
                                      "Selected: $startDate → $endDate",
                                    );
                                    provider.getOrderByDate(
                                      isDashboard: false,
                                      startDate: startDate,
                                      endDate: endDate,
                                    );
                                    productProvider.clearDateRange();
                                  },
                                  onCancelClick: () {
                                    debugPrint("Date range cleared");
                                    productProvider.clearDateRange();
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

            SizedBox(height: 10),

            Flexible(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return orderProvider.isFetching
                      ? SizedBox.shrink()
                      : chartData.isNotEmpty
                      ? SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            interval: 5, // 👈 Show every 5th day label
                            labelStyle: commonTextStyle(
                              fontSize: 12,
                              color: themeProvider.isDark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: commonTextStyle(
                              color: themeProvider.isDark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            axisLine: const AxisLine(width: 0),

                            // hide right side line
                          ),
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            header: '',
                            builder:
                                (
                                  dynamic data,
                                  dynamic point,
                                  dynamic series,
                                  int pointIndex,
                                  int seriesIndex,
                                ) {
                                  final sales = data as SalesData;
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      sales.orderNumber,

                                      // "Orders: ${sales.orderIds.join(', ')}\nTotal: ${sales.y}",
                                      style: commonTextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                          ),
                          series: <CartesianSeries<SalesData, String>>[
                            SplineAreaSeries<SalesData, String>(
                              animationDuration: 1500,
                              // in milliseconds (1.5 seconds)
                              animationDelay: 300,

                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderColor: Colors.orange,
                              borderWidth: 2,
                              color: Colors.orange.withValues(alpha: 0.5),

                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                height: 6,
                                width: 6,
                                shape: DataMarkerType.circle,
                                borderWidth: 2,
                              ),
                              dataSource: chartData,
                              xValueMapper: (SalesData sales, _) =>
                                  sales.orderNumber,
                              yValueMapper: (SalesData sales, _) =>
                                  sales.totalPrice,

                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: commonTextStyle(
                                  fontWeight: FontWeight.w600, // ✅ Bold
                                  fontSize: 12, // optional size
                                  color:
                                      colorTextDesc1, // or Colors.white in dark mode
                                ),
                              ),
                              dataLabelMapper: (SalesData sales, _) =>
                                  "$rupeeIcon${sales.totalPrice.toStringAsFixed(0)}",
                            ),
                          ],
                        )
                      : commonErrorView(text: errorMsg);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget commonTopProductListView({void Function()? onTap}) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: commonText(
                  text: "Top Products",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Spacer(),
              commonInkWell(
                onTap: onTap,
                child: commonText(
                  text: "See All",
                  color: themeProvider.isDark ? Colors.white : colorTextDesc,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 130,
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return commonListViewBuilder(
                  padding: EdgeInsetsGeometry.zero,
                  shrinkWrap: true,
                  items: provider.products,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index, data) {
                    var data = provider.products[index];
                    final totalVariants = data.variants?.length;
                    //  final left = "${parts[0]}for";
                    num? totalInventory = data.variants?.isNotEmpty == true
                        ? data.variants?.fold(
                            0,
                            (sum, variant) =>
                                sum! + (variant.inventoryQuantity ?? 0),
                          )
                        : 0;

                    return commonProductListView(
                      margin: EdgeInsetsGeometry.only(right: 10),
                      imageMargin: EdgeInsetsGeometry.only(left: 10),

                      width: provider.products.length == 1
                          ? MediaQuery.sizeOf(context).width - 30
                          : MediaQuery.sizeOf(context).width - 80,
                      image: data.image?.src ?? '',
                      onTap: () {
                        if (data.id != null) {
                          navigatorKey.currentState?.pushNamed(
                            RouteName.productDetailsScreen,
                            arguments: data.id.toString(),
                          );
                        }
                      },
                      price: data.variants?.isNotEmpty == true
                          ? '$rupeeIcon${data.variants?.first.price}'
                          : '$rupeeIcon 0',
                      textInventory1: "$totalInventory in stock",
                      textInventory2: ' for $totalVariants variants',
                      productName: data.title ?? '',
                      status: data.status.toString().toCapitalize(),
                      colorStatusColor: data.status?.isNotEmpty == true
                          ? provider.getStatusColor(
                              data.status.toString().toCapitalize(),
                            )
                          : Colors.grey,
                      decoration: commonBoxDecoration(
                        borderRadius: 8,
                        borderWidth: 0.5,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget commonTopOrderListView({void Function()? onTap}) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: commonText(
                  text: "Top Orders",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Spacer(),
              commonInkWell(
                onTap: onTap,
                child: commonText(
                  text: "See All",
                  color: themeProvider.isDark ? Colors.white : colorTextDesc,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 180,
            width: MediaQuery.sizeOf(context).width,

            child: Consumer<OrdersProvider>(
              builder: (context, provider, child) {
                return commonListViewBuilder(
                  padding: EdgeInsetsGeometry.zero,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  items: provider.filterOrderList,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index, data) {
                    var data = provider.filterOrderList[index];
                    return commonOrderView(
                      margin: EdgeInsetsGeometry.only(right: 10),

                      width: provider.filterOrderList.length == 1
                          ? MediaQuery.sizeOf(context).width - 30
                          : MediaQuery.sizeOf(context).width - 80,
                      onTap: () {
                        navigatorKey.currentState?.pushNamed(
                          RouteName.orderDetailsScreen,
                          arguments: data.id,
                        );
                      },
                      colorTextStatus: provider.getPaymentStatusColor(
                        data.financialStatus.toString().toCapitalize(),
                      ),
                      decoration: commonBoxDecoration(
                        borderRadius: 4,

                        color: provider
                            .getPaymentStatusColor(
                              data.financialStatus.toString().toCapitalize(),
                            )
                            .withValues(alpha: 0.1),
                      ),

                      orderID: data.customer?.firstName != null
                          ? '${data.customer?.firstName}  ${data.customer?.lastName}'
                          : noCustomer,
                      image: data.name ?? '',

                      productName: '${data.lineItems?.length} Items',
                      status: data.financialStatus.toString().toCapitalize(),
                      price: double.parse(
                        data.subtotalPrice?.toString() ?? '0',
                      ),
                      date: formatDateTime(
                        data.createdAt ?? '',
                      ), //data.date.toLocal().toString(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
