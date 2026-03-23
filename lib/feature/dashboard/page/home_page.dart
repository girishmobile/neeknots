import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/feature/dashboard/home_widget/common_home_widget.dart';
import 'package:neeknots/provider/customer_provider.dart';
import 'package:neeknots/provider/dashboard_provider.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:provider/provider.dart';

import '../../../provider/product_provider.dart';
import '../../common_all_store_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
    });
  }

  void call(bool isTure) {
    if (isTure) {
      init();
    }
  }

  Future<void> init() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrdersProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    DateTime now = DateTime.now();

    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    productProvider.resetProducts();
    Future.wait([
      productProvider.getProductList(limit: 5, context: context),
      productProvider.getCountPendingRequest(),
      productProvider.getTotalProductCount(),
      orderProvider.getOrderList(limit: "5"),
      customerProvider.getTotalCustomerCount(),
      orderProvider.getTotalOrderCount(),

      orderProvider.getTotalSaleOrder(startDate: startDate, endDate: endDate),
      orderProvider.getOrderByDate(
        startDate: startDate,
        endDate: endDate,
        isDashboard: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return commonRefreshIndicator(
      onRefresh: () async {
        init();
      },
      child: Consumer3<OrdersProvider, ProductProvider, CustomerProvider>(
        builder:
            (context, orderProvider, productProvider, customerProvider, child) {
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 16,right: 16,bottom: 80,top: 10),
                children: [
                  CommonAllStoreWidget(onStoreChanged: call),
                  homeTopView(
                    totalPendingRequest: productProvider.pendingCount,
                    totalOrderPrice: orderProvider.totalOrderPrice,
                    totalOrder: orderProvider.totalOrderCount,
                    totalProduct: productProvider.totalProductCount,
                    totalCustomer: customerProvider.totalCustomerCount,
                    totalSaleOrder: orderProvider.totalOrderSaleCount,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: homeGraphView(isSaleDetails: false),
                  ),
                  SizedBox(height: 24),
                  Consumer<DashboardProvider>(
                    builder: (context, provider, child) {
                      return commonTopProductListView(
                        onTap: () {
                          provider.setIndex(0);
                        },
                      );
                    },
                  ),

                  SizedBox(height: 24),
                  Consumer<DashboardProvider>(
                    builder: (context, provider, child) {
                      return commonTopOrderListView(
                        onTap: () {
                          provider.setIndex(1);
                        },
                      );
                    },
                  ),
                ],
              );
            },
      ),
    );
  }
}
