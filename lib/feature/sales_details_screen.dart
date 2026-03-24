import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import '../core/color/color_utils.dart';
import '../core/component/date_utils.dart';
import '../main.dart';
import '../provider/order_provider.dart';
import '../routes/app_routes.dart';
import 'dashboard/home_widget/common_home_widget.dart';
import 'dashboard/order_widget/common_order_widget.dart';

class SalesDetailsScreen extends StatefulWidget {
  final int todaySales;

  const SalesDetailsScreen({super.key, required this.todaySales});

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);
    DateTime now = DateTime.now();

    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    await Future.wait([
      orderProvider.getOrderByDate(
        startDate: startDate,
        endDate: endDate,
        isDashboard: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    return commonScaffold(
      appBar: commonAppBar(
        title: "Sales Detail",
        context: context,
        centerTitle: true,
      ),
      body: commonAppBackground(
        child: Consumer2<ThemeProvider, OrdersProvider>(
          builder: (context, provider, orderProvider, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with animated count
                      commonBoxView(
                        title: "Today Orders & Price",
                        contentView: SizedBox(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          commonText(
                                            text: "Orders",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: provider.isDark
                                                ? Colors.white
                                                : colorLogo,
                                          ),
                                          commonText(
                                            //   leftText: '',
                                            text:
                                                '${orderProvider.orderModelByDate?.orders?.length ?? 0}',
                                            //  duration: Duration(seconds: 2),
                                            style: commonTextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                              color: provider.isDark
                                                  ? Colors.white
                                                  : colorTextDesc1,
                                            ),
                                            /*  prefix: "",
                                            suffix: "",*/
                                          ),
                                        ],
                                      ),
                                    ),

                                    VerticalDivider(),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          commonText(
                                            text: "Price",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: provider.isDark
                                                ? Colors.white
                                                : colorLogo,
                                          ),
                                          commonText(
                                            text:
                                                '$rupeeIcon${orderProvider.totalOrderPrice}',
                                            style: commonTextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                              color: provider.isDark
                                                  ? Colors.white
                                                  : colorTextDesc1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      commonBoxView(
                        color: Colors.orange.shade100.withValues(alpha: 0.2),
                        title: "Today Sales",
                        contentView: SizedBox(
                          height: 320,
                          child: homeGraphView(isSaleDetails: true),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,

                        physics: NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount:
                            orderProvider.orderModelByDate?.orders?.length ?? 0,
                        // null to [] convert
                        itemBuilder: (context, index) {
                          var data =
                              orderProvider.orderModelByDate?.orders?[index];
                          return commonOrderView(
                            index: index,
                            errorImageView: Container(
                              margin: EdgeInsets.only(
                                left: 5,
                                top: 5,
                                bottom: 5,
                              ),
                              child: commonErrorBoxView(text: data?.name ?? ''),
                            ),

                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 0,
                            ),
                            onTap: () {
                              navigatorKey.currentState?.pushNamed(
                                RouteName.orderDetailsScreen,
                                arguments: data,
                              );
                            },
                            colorTextStatus: orderProvider.getPaymentStatusColor(
                              '${data?.financialStatus.toString().toCapitalize()}',
                            ),
                            decoration: commonBoxDecoration(
                              borderRadius: 4,

                              color: orderProvider
                                  .getPaymentStatusColor(
                                    '${data?.financialStatus.toString().toCapitalize()}',
                                  )
                                  .withValues(alpha: 0.1),
                            ),

                            orderID: data?.customer?.firstName != null
                                ? '${data?.customer?.firstName}  ${data?.customer?.lastName}'
                                : noCustomer,
                            image: data?.name ?? '',
                            //productName:'${ data?.customer?.firstName}  ${ data?.customer?.lastName}',
                            productName: '${data?.lineItems?.length} Items',
                            status:
                                '${data?.financialStatus.toString().toCapitalize()}',
                            price: double.parse(
                              data?.subtotalPrice?.toString() ?? '0',
                            ),
                            date: formatDateTime(
                              data?.createdAt ?? '',
                            ), //data.date.toLocal().toString(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                orderProvider.isFetching ? showLoaderList() : SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SalesData {
  final String month;
  final double sales;

  SalesData(this.month, this.sales);
}

class RegionSales {
  final String region;
  final double sales;
  final Color color;

  RegionSales(this.region, this.sales, this.color);
}
