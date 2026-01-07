import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../order_widget/common_order_view.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        // Align(
        //   alignment: AlignmentGeometry.topRight,
        //   child: Padding(
        //     padding: EdgeInsets.only(right: 10),
        //     child: commonButton(
        //       fontSize: 12,

        //         height: 45,

        //         width: MediaQuery.sizeOf(context).width*0.5,
        //         text: "Order Filter Screen", onPressed: (){
        //       Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderPageScreen()));
        //     }),
        //   ),
        // ),
        Expanded(child: CommonOrderView()),
      ],
    );
  }
}
