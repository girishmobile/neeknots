import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/order_provider.dart';
import 'package:provider/provider.dart';

import 'dashboard/order_widget/common_order_view.dart';

class TotalOrderScreen extends StatefulWidget {
  const TotalOrderScreen({super.key});

  @override
  State<TotalOrderScreen> createState() => _TotalOrderScreenState();
}

class _TotalOrderScreenState extends State<TotalOrderScreen> {
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
      body: CommonOrderView(),
    );
  }
}
