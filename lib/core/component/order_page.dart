
import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';

import 'package:neeknots/provider/order_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/color/color_utils.dart';
import '../../../core/component/custom_tab_bar.dart';
import '../../feature/dashboard/order_widget/common_order_view.dart';


class OrderPageScreen extends StatefulWidget {
  const OrderPageScreen({super.key});

  @override
  State<OrderPageScreen> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrderPageScreen>  with TickerProviderStateMixin   {
  TabController? _tabController;
  int _previousTabLength = 0;
  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }
  void init() {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    //_tabController = TabController(length: 8, vsync: this);
   Future.microtask(
      () => Provider.of<OrdersProvider>(navigatorKey.currentContext!, listen: false).getAllFilterOrderList(),
    );
    if (provider.activeFilters.isNotEmpty) {
      _initTabController(provider.activeFilters.length);
    }
  }
  void _initTabController(int length) {
    if (_tabController == null || _previousTabLength != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
      _previousTabLength = length;
    }
  }
  @override
  Widget build(BuildContext context) {

    return commonScaffold(
      appBar: commonAppBar(title: "Order Demo", context: context),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          return commonRefreshIndicator(
            onRefresh: () async {
              init();
            },
            child: Column(
              children: [
                SizedBox(height: 0,),
                // Padding(
                //   padding: const EdgeInsets.only(top: 18.0, left: 12, right: 12),
                //   child: commonTextField(
                //     hintText: "Search by Order ID",
                //     prefixIcon: commonPrefixIcon(
                //       image: icProductSearch,
                //       width: 16,
                //       height: 16,
                //     ),
                //
                //     suffixIcon: IconButton(
                //       icon: commonPrefixIcon(
                //         image: icProductFilter,
                //         width: 20,
                //         height: 20,
                //       ),
                //       onPressed: () {
                //         final filters = [
                //           FilterItem(
                //             label: "Status",
                //             /* options: [
                //               "All",
                //               "Authorized",
                //               "Paid",
                //               "Partially Paid",
                //               "Refunded",
                //               "Voided",
                //             ],*/
                //             options: [
                //               /*   "All",
                //               "Today’s Order",
                //               "Open Order",
                //               "Closed Orders",
                //               "Pending to Charge",
                //               "Pending Shipment",
                //               "Shipped",
                //               "Awaiting Return",
                //               "Completed",*/
                //               "All",
                //               "Today’s Order",
                //               "Open Order",
                //               "Closed Orders",
                //               "Pending To Charge",
                //               "Pending Shipment",
                //               "Shipped",
                //               "Awaiting Return",
                //               "Completed",
                //             ],
                //             selectedValue: provider.selectedStatus
                //                 .toString()
                //                 .toCapitalize(), // 👈 provider से लो*/
                //             // selectedValue: provider.selectedStatus,
                //           ),
                //         ];
                //
                //         showCommonFilterDialog(
                //             context: context,
                //             title: "Filter Orders",
                //             filters: filters,
                //             onReset: () {
                //               provider.getOrderList(
                //                   loadMore: false,
                //                   financialStatus: null,
                //                   createdMinDate: null,
                //                   createdMaxDate: null,
                //                   status: null,
                //                   fulfillmentStatus: null
                //                 /*  financialStatus: null,*/
                //               );
                //             },
                //             onApply: () {
                //               final selectedStatus = filters.first.selectedValue.toLowerCase().trim();
                //
                //               final now = DateTime.now().toUtc();
                //               final todayStart = "${now.toIso8601String().split("T")[0]}T00:00:00Z";
                //               final todayEnd = "${now.toIso8601String().split("T")[0]}T23:59:59Z";
                //
                //               final statusMap = {
                //                 "closed orders": {"status": "closed"},
                //                 "open order": {"status": "open"},
                //                 "today's order": {
                //                   "createdMinDate": todayStart,
                //                   "createdMaxDate": todayEnd
                //                 },
                //                 "today’s order": { // handle special apostrophe
                //                   "createdMinDate": todayStart,
                //                   "createdMaxDate": todayEnd
                //                 },
                //                 "pending to charge": {"financialStatus": "pending"},
                //                 "pending shipment": {
                //                   "status": "open",
                //                   "fulfillmentStatus": "unshipped,partial"
                //                 },
                //                 "shipped": {"fulfillmentStatus": "fulfilled"},
                //                 "awaiting return": {"financialStatus": "refunded"},
                //                 "completed": {
                //                   "financialStatus": "paid",
                //                   "fulfillmentStatus": "fulfilled"
                //                 },
                //               };
                //
                //               final params = statusMap[selectedStatus];
                //               if (params != null) {
                //                 provider.filterByStatus(
                //                   value: selectedStatus,
                //                   status: params["status"],
                //                   financialStatus: params["financialStatus"],
                //                   fulfillmentStatus: params["fulfillmentStatus"],
                //                   createdMinDate: params["createdMinDate"],
                //                   createdMaxDate: params["createdMaxDate"],
                //                 );
                //               }
                //
                //             }
                //
                //         );
                //       },
                //     ),
                //     onChanged: (value) => provider.setSearchQuery(value),
                //   ),
                // ),
           /*     Expanded(
                  child: Container(
      
                    margin: EdgeInsets.all(0),
                    child: CustomTabBar(
      
                      fontSize: 14,
      
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      labelColor: colorLogo,
                      dividerColor: colorBorder,
                      decoration: BoxDecoration(),
                      selectedColor: colorLogo,
                      unselectedColor:colorTextDesc,
                      tabController: _tabController,
                      tabTitles: ["Today’s Order", "Open Order","Closed Orders", "Pending To Charge","Pending Shipment","Shipped","Awaiting Return","Completed"],
                      tabViews: [
                        CommonOrderView(createdMinDate: todayStart,createdMaxDate: todayEnd,),
                        CommonOrderView(status: "open",),
                        CommonOrderView(status: "closed",),
                        CommonOrderView(financialStatus: "pending",),
                        CommonOrderView(status: "open",fulfillmentStatus: "unshipped,partial",),
                        CommonOrderView(fulfillmentStatus: "fulfilled",),
                        CommonOrderView(fulfillmentStatus: "refunded",),
                        CommonOrderView(fulfillmentStatus: "paid",financialStatus: "fulfilled",),
      
                      ],
                    ),
                  ),
                ),*/
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(0),
                    child: Consumer<OrdersProvider>(
                      builder: (context, filterProvider, _) {
                        if (filterProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
      
                        final activeFilters = filterProvider.activeFilters;
      
                        if (activeFilters.isEmpty) {
                          return const Center(
                            child: Text("No active filters found"),
                          );
                        }
      
                        final now = DateTime.now().toUtc();
                        final todayStart = "${now.toIso8601String().split("T")[0]}T00:00:00Z";
                        final todayEnd = "${now.toIso8601String().split("T")[0]}T23:59:59Z";
      
                        /// Mapping filter names to order parameters
                        final statusMap = {
                          "closed orders": {"status": "closed"},
                          "open order": {"status": "open"},
                          "today's order": {
                            "createdMinDate": todayStart,
                            "createdMaxDate": todayEnd
                          },
                          "today’s order": { // handle special apostrophe
                            "createdMinDate": todayStart,
                            "createdMaxDate": todayEnd
                          },
                          "pending to charge": {"financialStatus": "pending"},
                          "pending shipment": {
                            "status": "open",
                            "fulfillmentStatus": "unshipped,partial"
                          },
                          "shipped": {"fulfillmentStatus": "fulfilled"},
                          "awaiting return": {"financialStatus": "refunded"},
                          "completed": {
                            "financialStatus": "paid",
                            "fulfillmentStatus": "fulfilled"
                          },
                        };
      
                        /// Build tab titles and views dynamically
                        final tabTitles =
                        activeFilters.map((filter) => filter["title"].toString()).toList();
      
                        final tabViews = activeFilters.map((filter) {
                          final name = filter["title"].toString().toLowerCase().trim();
                          final params = statusMap[name];
      
                          if (params == null) {
                            return const Center(child: Text("Invalid filter config"));
                          }
      
                          return CommonOrderView(
                            status: params["status"],
                            financialStatus: params["financialStatus"],
                            fulfillmentStatus: params["fulfillmentStatus"],
                            createdMinDate: params["createdMinDate"],
                            createdMaxDate: params["createdMaxDate"],
                          );
                        }).toList();
                        _initTabController(tabTitles.length);
                        /// Dynamically create tab controller
                        // _tabController = TabController(
                        //   length: tabTitles.length,
                        //   vsync: this,
                        // );
                        _initTabController(tabTitles.length);
                        return CustomTabBar(
                          fontSize: 14,
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          labelColor: colorLogo,
                          dividerColor: colorBorder,
                          decoration: const BoxDecoration(),
                          selectedColor: colorLogo,
                          unselectedColor: colorTextDesc,
                          tabController: _tabController!,
                          tabTitles: tabTitles,
                          tabViews: tabViews,
                        );
                      },
                    ),
                  ),
                ),
      
                /*
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
                    child:provider.filterOrderList.isNotEmpty? ListView.builder(
                      padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
                      itemCount:
                          provider.filterOrderList.length +
                          (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.filterOrderList.length) {
                          final data = provider.filterOrderList[index];
                          return commonOrderView(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
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
                            child: Center(child: CupertinoActivityIndicator()),
                          );
                        }
                      },
                    ):commonErrorView(text: "Order Not Found."),
                  ),
                ),*/
              ],
            ),
          );
        },
      ),
    );
  }
}
/*
final now = DateTime.now().toUtc();
final todayStart = "${now.toIso8601String().split("T")[0]}T00:00:00Z";
final todayEnd = "${now.toIso8601String().split("T")[0]}T23:59:59Z";

final statusMap = {
  "closed orders": {"status": "closed"},
  "open order": {"status": "open"},
  "today's order": {
    "createdMinDate": todayStart,
    "createdMaxDate": todayEnd
  },
  "today’s order": { // handle special apostrophe
    "createdMinDate": todayStart,
    "createdMaxDate": todayEnd
  },
  "pending to charge": {"financialStatus": "pending"},
  "pending shipment": {
    "status": "open",
    "fulfillmentStatus": "unshipped,partial"
  },
  "shipped": {"fulfillmentStatus": "fulfilled"},
  "awaiting return": {"financialStatus": "refunded"},
  "completed": {
    "financialStatus": "paid",
    "fulfillmentStatus": "fulfilled"
  },
};
*/
