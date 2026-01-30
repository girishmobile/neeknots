import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/component/date_utils.dart';
import 'package:neeknots/feature/dashboard/order_widget/common_order_widget.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../core/color/color_utils.dart';
import '../core/component/animated_counter.dart';
import '../core/string/string_utils.dart';
import '../provider/theme_provider.dart';
import 'dashboard/order_widget/common_order_view.dart';

class TotalOrderScreen extends StatefulWidget {
  const TotalOrderScreen({super.key});

  @override
  State<TotalOrderScreen> createState() => _TotalOrderScreenState();
}

class _TotalOrderScreenState extends State<TotalOrderScreen> {
  /*
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final postMdl = Provider.of<OrdersProvider>(
        navigatorKey.currentContext!,
        listen: false,
      );

      postMdl.resetData();
      postMdl.orderCountStatusValue();
      postMdl.getAllFilterOrderList();
    });
  }
*/

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final postMdl = Provider.of<OrdersProvider>(context, listen: false);
      postMdl.resetData1();
      Future.microtask(
        () => Provider.of<OrdersProvider>(
          navigatorKey.currentContext!,
          listen: false,
        ).getAllFilterOrderList(),
      );

      await postMdl.getAllFilterOrderList1();
      await postMdl.orderCountStatusValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      appBar: commonAppBar(
        title: "Total Orders",
        context: context,
        centerTitle: true,
      ),
      body: CommonOrderView() /* commonAppBackground(
        child: Consumer2<ThemeProvider, OrdersProvider>(
          builder: (context, provider, orderProvider, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        child: commonListViewBuilder(
                          shrinkWrap: true,

                          scrollDirection: Axis.horizontal,
                          items: orderProvider.allOrderFilterList,
                          itemBuilder: (context, index, data) {
                            final data =
                                orderProvider.allOrderFilterList[index];
                            final title = data['title'];
                            final value =
                                orderProvider.orderStatusCounts[title] ?? 0;
                            return _commonDashboardView(
                              provider: provider,
                              onTap: () {
                                orderProvider.setSelectedTab(title);
                                debugPrint(
                                  "-- Selected Tab: $title, Value: $value",
                                );
                              },
                              value: value,
                              icon: icAppLogo,
                              title: title,
                              color: orderProvider.selectedTab == title
                                  ? Colors.green
                                  : Colors.grey,
                            );
                          },
                        ),
                      ),

                      // Use Expanded correctly
                      Expanded(child: _paidListWidget(orderProvider)),
                    ],
                  ),
                ),
                orderProvider.isFetching || orderProvider.isLoading ?showLoaderList():SizedBox.shrink()
              ],
            );
          },
        ),
      )*/,
    );
  }

  Widget _paidListWidget(OrdersProvider provider) {
    final orders = provider.selectedOrders; // ✅ selectedTab ki list aayegi

    return ListView.builder(
      shrinkWrap: true,

      padding: const EdgeInsets.all(0),
      itemCount: orders.length,

      itemBuilder: (context, index) {
        if (index < orders.length) {
          var data = orders[index];
          return commonOrderView(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
            //productName:'${ data?.customer?.firstName}  ${ data?.customer?.lastName}',
            productName: '${data.lineItems?.length} Items',
            status: data.financialStatus.toString().toCapitalize(),
            price: double.parse(data.subtotalPrice?.toString() ?? '0'),
            date: formatDateTime(
              data.createdAt ?? '',
            ), //data.date.toLocal().toString(),
          );
        } else {
          // 🔹 Loader sirf infinite scroll (search off) me
          if (provider.searchQuery.isEmpty && provider.hasMore) {
            // Trigger next page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.getOrderList();
            });

            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CupertinoActivityIndicator(color: Colors.black),
              ),
            );
          } else {
            // 🔹 Agar search ya no more data
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _commonDashboardView({
    Color? color,
    required ThemeProvider provider,
    required String icon,
    String? title,
    required int value,

    void Function()? onTap,
  }) {
    return commonInkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 0),
        decoration: commonBoxDecoration(
          color:
              color?.withValues(alpha: 0.05) ??
              Colors.green.withValues(alpha: 0.1),

          borderColor:
              color?.withValues(alpha: 0.2) ??
              Colors.green.withValues(alpha: 0.2),
          borderRadius: 10,
        ),
        child: Center(
          child: Column(
            spacing: 6,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(2),
                // border thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color ?? Colors.transparent, // border color
                    width: 1, // border width
                  ),
                ),
                child: Center(
                  child: AnimatedCounter(
                    leftText: '',
                    rightText: '',
                    endValue: value,
                    duration: Duration(seconds: 2),
                    style: commonTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
              commonText(
                textAlign: TextAlign.center,
                color: provider.isDark ? Colors.white : colorLogo,
                text: title?.toCapitalize() ?? "Paid".toCapitalize(),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
