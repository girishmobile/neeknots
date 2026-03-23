import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../provider/customer_provider.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      await customerProvider.getCustomerList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);

    return commonRefreshIndicator(
      onRefresh: () async {
        init();
      },
      child: ListView(
        padding: EdgeInsets.only(left: 16,right: 16,bottom: 80,top: 10),
        children: [
          SizedBox(height: 10),
          commonTextField(
            hintText: "Search customers...",
            fillColor: colorBgNew,
            filled: true,
            prefixIcon: commonPrefixIcon(
              image: icProductSearch,
              width: 16,
              height: 16,
            ),

            onChanged: (value) => provider.setSearchQuery(value),
          ),

          SizedBox(height: 10),
          commonRefreshIndicator(
            onRefresh: () async {
              init();
            },
            child: provider.isFetching
                ? SizedBox.shrink()
                : provider.customers?.isNotEmpty == true
                ? commonListViewBuilder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              items: provider.customers ?? [],
              itemBuilder: (context, index, data1) {
                var data = provider.customers?[index];
                return Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Container(
                      decoration: commonBoxDecoration(

                    borderColor: colorBorder,
                        borderRadius: 8,

                        color: colorBgNew,

                            ),
                    margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(10),
                      child: commonInkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteName.customerDetail,
                            arguments: data,
                          );
                        },
                        child: Column(
                          spacing: 8,
                          children: [
                            // Name
                            infoRowBox(
                              text: 'Name',
                              value:
                              '${data?.firstName?.toCapitalize() ?? ''} ${data?.lastName?.toCapitalize() ?? ''}',

                              colorText: colorLogo,
                            ),
                            infoRowBox(
                              text: 'Email',
                              value: data?.email?.toCapitalize() ?? '',

                              colorText: colorLogo,
                            ),

                            infoRowBox(
                              text: 'Total Spent',
                              valueView: Container(
                                decoration: commonBoxDecoration(
                                  borderRadius: 8,
                                  color: Colors.green.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: commonText(
                                  text:
                                  '$rupeeIcon${data?.totalSpent ?? "0.00"}',
                                  fontSize: 10,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            infoRowBox(
                              text: 'Total Orders',
                              valueView: Container(
                                decoration: commonBoxDecoration(
                                  borderRadius: 8,
                                  color: Colors.grey.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: commonText(
                                  text: '${data?.ordersCount ?? 0}',
                                  fontSize: 10,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              colorText: colorLogo,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
                : SizedBox(
              width: MediaQuery
                  .sizeOf(context)
                  .width,
              height: MediaQuery
                  .sizeOf(context)
                  .height * 0.7,
              child: commonErrorView(text: "Customer Not Found"),
            ),
          ),
        ],
      ),
    );
  }


  Widget _commonItemView({String? title, required String value}) {
    return Row(
      spacing: 5,
      children: [
        commonText(text: '$title : ',fontWeight: FontWeight.w500),
        commonText(text: value),
      ],
    );
  }
}
