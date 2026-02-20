import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../core/component/component.dart';
import '../../../core/component/context_extension.dart';
import '../../../core/component/date_utils.dart';
import '../../../core/image/image_utils.dart';
import '../../../core/string/string_utils.dart';
import '../../../main.dart';
import '../../../provider/order_provider.dart';
import '../../../routes/app_routes.dart';
import 'common_order_widget.dart';

class CommonOrderView extends StatefulWidget {
  const CommonOrderView({
    super.key,
    this.status,
    this.fulfillmentStatus,
    this.createdMinDate,
    this.createdMaxDate,
    this.financialStatus,
    this.limit,
  });

  final String? status;
  final String? financialStatus;
  final String? fulfillmentStatus;

  final String? limit;
  final String? createdMinDate;
  final String? createdMaxDate;

  @override
  State<CommonOrderView> createState() => _CommonOrderViewState();
}

class _CommonOrderViewState extends State<CommonOrderView> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    Future.microtask(
      () => Provider.of<OrdersProvider>(navigatorKey.currentContext!, listen: false).getOrderList(
        status: widget.status,
        createdMinDate: widget.createdMinDate,
        createdMaxDate: widget.createdMaxDate,
        fulfillmentStatus: widget.fulfillmentStatus,
        financialStatus: widget.financialStatus,
        loadMore: false,
      ),
    );
    Future.microtask(
          () => Provider.of<OrdersProvider>(navigatorKey.currentContext!, listen: false).getAllFilterOrderList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        final list = provider.filterOrderList;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 8),


              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
                child: commonTextField(
                  hintText: "Search by Order ID",
                  prefixIcon: commonPrefixIcon(
                    image: icProductSearch,
                    width: 16,
                    height: 16,
                  ),

                  suffixIcon: IconButton(
                    icon: commonPrefixIcon(
                      image: icProductFilter,
                      width: 20,
                      height: 20,
                    ),

                    onPressed: () {
                      final activeFilters =
                          provider.activeFilters; // from OrdersProvider

                      if (activeFilters.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No active filters available"),
                          ),
                        );
                        return;
                      }
                      final options = [
                        "All",
                        ...activeFilters
                            .map((f) => f["title"].toString())
                            .where((t) => t != "All"),
                      ];
                      // Convert to FilterItem options
                      final filterItem = FilterItem(
                        label: "Status",
                        options: options,
                        selectedValue: provider.selectedStatus
                            .toString()
                            .toCapitalize(),
                      );

                      showCommonFilterDialog(
                        context: context,
                        title: "Filter Orders",
                        filters: [filterItem],
                        onReset: () {
                          provider.getOrderList(
                            loadMore: false,
                            financialStatus: null,
                            createdMinDate: null,
                            createdMaxDate: null,
                            status: null,
                            fulfillmentStatus: null,
                          );
                        },
                        onApply: () {
                          final selectedStatus = filterItem.selectedValue
                              .toLowerCase()
                              .trim();

                          final now = DateTime.now().toUtc();
                          final todayStart =
                              "${now.toIso8601String().split("T")[0]}T00:00:00Z";
                          final todayEnd =
                              "${now.toIso8601String().split("T")[0]}T23:59:59Z";

                          final statusMap = {
                            "closed orders": {"status": "closed"},
                            "open order": {"status": "open"},
                            "today's order": {
                              "createdMinDate": todayStart,
                              "createdMaxDate": todayEnd,
                            },
                            "today’s order": {
                              "createdMinDate": todayStart,
                              "createdMaxDate": todayEnd,
                            },
                            "pending to charge": {"financialStatus": "pending"},
                            "pending shipment": {
                              "status": "open",
                              "fulfillmentStatus": "unshipped,partial",
                            },
                            "shipped": {"fulfillmentStatus": "fulfilled"},
                            "awaiting return": {"financialStatus": "refunded"},
                            "completed": {
                              "financialStatus": "paid",
                              "fulfillmentStatus": "fulfilled",
                            },
                          };

                          final params = statusMap[selectedStatus];
                          if (params != null) {
                            provider.filterByStatus(
                              value: selectedStatus,
                              status: params["status"],
                              financialStatus: params["financialStatus"],
                              fulfillmentStatus: params["fulfillmentStatus"],
                              createdMinDate: params["createdMinDate"],
                              createdMaxDate: params["createdMaxDate"],
                            );
                          }
                        },
                      );
                    },
                  ),
                  onChanged: (value) => provider.setSearchQuery(value),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // Load more only when not searching
                    if (provider.searchQuery.isEmpty &&
                        !provider.isFetching &&
                        provider.hasMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      provider.getOrderList(loadMore: true);
                    }
                    return false;
                  },
                  child: provider.filterOrderList.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 0,
                            right: 0,
                            top: 10,
                          ),
                          itemCount:
                              provider.filterOrderList.length +
                              (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < provider.filterOrderList.length) {
                              final data = provider.filterOrderList[index];
                              return commonOrderView(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 0,
                                ),
                                onTap: () {
                                  navigatorKey.currentState?.pushNamed(
                                    RouteName.orderDetailsScreen,
                                    arguments: data.id,
                                  );
                                },
                                colorTextStatus: provider.getPaymentStatusColor(
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
                                orderID: data.customer?.firstName != null
                                    ? '${data.customer?.firstName}  ${data.customer?.lastName}'
                                    : noCustomer,
                                image: data.name ?? '',
                                productName: '${data.lineItems?.length} Items',
                                status:
                                    '${data.financialStatus.toString().toCapitalize()} | ${data.fulfillmentStatus?.toCapitalize() ?? 'Unfulfilled'}',
                                price: double.parse(
                                  data.subtotalPrice?.toString() ?? '0',
                                ),
                                date: formatDateTime(data.createdAt ?? ''),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                          },
                        )
                      : provider.isFetching && provider.filterOrderList.isEmpty
                      ? SizedBox.shrink()
                      : commonErrorView(text: errorMsg),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
