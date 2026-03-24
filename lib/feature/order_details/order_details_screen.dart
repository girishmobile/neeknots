import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:provider/provider.dart';

import '../../models/order_details_model.dart';
import '../../provider/order_provider.dart';
import 'order_common_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderID});

  final int orderID;

  //final Order order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    final customerProvider = Provider.of<OrdersProvider>(
      context,
      listen: false,
    );
    await customerProvider.clearOrderDetailsData();
    await customerProvider.getOrderById(orderID: widget.orderID);

  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      appBar: commonAppBar(
        title: "Order Details",
        context: context,
        centerTitle: true,
      ),
      body: commonAppBackground(
        child: Consumer<OrdersProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                ListView(

                  children: [
                    orderInfo(

                      order:
                          provider.orderDetailsModel?.orderData ?? OrderData(),
                    ),

                    customerInfo(
                      order:
                          provider.orderDetailsModel?.orderData ?? OrderData(),
                    ),
                    productInfo(
                      order:
                          provider.orderDetailsModel?.orderData ?? OrderData(),
                    ),
                    paymentSummery(
                      order:
                          provider.orderDetailsModel?.orderData ?? OrderData(),
                    ),
                  ],
                ),

                provider.isFetching?showLoaderList():SizedBox.shrink()
              ],
            );
          },
        ),
      ),
    );
  }
}
