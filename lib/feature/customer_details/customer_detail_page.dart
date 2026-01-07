import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';

import 'package:neeknots/provider/order_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../models/customer_model.dart';
import 'common_customer_widget.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {

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
    await customerProvider.getOrderById(orderID: widget.customer.lastOrderId);
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      appBar: commonAppBar(
        title: "Customer Detail",
        context: context,
        centerTitle: true,
      ),
      body: commonAppBackground(
        child: ListView(
          children: [
            customerDetailsInfo(customer: widget.customer),
            customerProductInfo(customer: widget.customer),
            commonInkWell(
              onTap: () => Navigator.pushNamed(
                context,
                RouteName.customerOrders,
                arguments: "${widget.customer.id}",
              ),
              child: Container(
                decoration: commonBoxDecoration(
                  borderColor: colorBorder,
                  borderRadius: 8,
                ),
                margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                padding: const EdgeInsets.all(16),
                child: Row(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonText(
                      text: "All Orders",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    Icon(Icons.chevron_right_outlined, color: colorBorder),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
