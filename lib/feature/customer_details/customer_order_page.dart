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

import '../../core/image/image_utils.dart';

class CustomerOrderPage extends StatefulWidget {
  final String customerId;

  const CustomerOrderPage({super.key, required this.customerId});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  @override
  void initState() {
    super.initState();
    getOrders();
  }

  void getOrders() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrdersProvider>(context, listen: false);
      provider.getOrdersByCustomerId(customerId: widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      appBar: commonAppBar(title: "Customer Orders", context: context,centerTitle: true),
      body: commonAppBackground(
        child: Consumer<OrdersProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18.0,
                        left: 12,
                        bottom: 8,
                        right: 12,
                      ),
                      child: commonTextField(
                        hintText: "Search by Order ID",
                        prefixIcon: commonPrefixIcon(
                          image: icProductSearch,
                          width: 16,
                          height: 16,
                        ),

                        onChanged: (value) => provider.setSearchQuery(value),
                      ),
                    ),
                    Expanded(
                      child: provider.isFetching
                          ? SizedBox.shrink()
                          : provider.filterCustomerOrderList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              // padding: const EdgeInsets.all(4),
                              itemCount:
                                  provider.filterCustomerOrderList.length,
                              // null to [] convert
                              itemBuilder: (context, index) {
                                if (index <
                                    provider.filterCustomerOrderList.length) {
                                  var data =
                                      provider.filterCustomerOrderList[index];
                                  return commonOrderView(
                                    invisibleCustomer: false,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    onTap: () {
                                      navigatorKey.currentState?.pushNamed(
                                        RouteName.orderDetailsScreen,
                                        arguments: data.id ?? '',
                                      );
                                    },
                                    colorTextStatus: provider
                                        .getPaymentStatusColor(
                                          data.financialStatus
                                              .toString()
                                              .toCapitalize(),
                                        ),
                                    decoration: commonBoxDecoration(
                                      borderRadius: 4,

                                      color: provider
                                          .getPaymentStatusColor(
                                            data.financialStatus
                                                .toString()
                                                .toCapitalize(),
                                          )
                                          .withValues(alpha: 0.1),
                                    ),

                                    image: data.name ?? '',

                                    productName:
                                        '${data.lineItems?.length} Items',
                                    status: data.financialStatus
                                        .toString()
                                        .toCapitalize(),
                                    price: double.parse(
                                      data.subtotalPrice?.toString() ?? '0',
                                    ),
                                    date: formatDateTime(
                                      data.createdAt ?? '',
                                    ), //data.date.toLocal().toString(),
                                  );
                                } else {
                                  // 🔹 Loader sirf infinite scroll (search off) me
                                  if (provider.searchQuery.isEmpty &&
                                      provider.hasMore) {
                                    // Trigger next page
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          provider.getOrderList();
                                        });

                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CupertinoActivityIndicator(
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 🔹 Agar search ya no more data
                                    return const SizedBox.shrink();
                                  }
                                }
                              },
                            )
                          : commonErrorView(text: "Order not found"),
                    ),
                  ],
                ),

                provider.isFetching ? showLoaderList() : SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }
}
