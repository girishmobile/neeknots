import 'package:flutter/material.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/main.dart';
import 'package:provider/provider.dart';

import '../../../core/color/color_utils.dart';
import '../../../core/component/CommonSwitch.dart';
import '../../../core/component/component.dart';
import '../../../core/component/responsive.dart';
import '../../../provider/admin_dashboard_provider.dart';

class OrderFilterListPage extends StatefulWidget {
  final String storeName;
  final String collectionName;

  const OrderFilterListPage({
    super.key,
    required this.storeName,
    required this.collectionName,
  });

  @override
  State<OrderFilterListPage> createState() => _StoreCollectionTabState();
}

class _StoreCollectionTabState extends State<OrderFilterListPage> {
   @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() {
    final customerProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    customerProvider.getStoreCollectionData(
      storeName: widget.storeName,
      collectionName: widget.collectionName,
    );
  }

  void _showAddFilterDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool status = false;

    showCommonDialog(
      title: "Add New Filter",
      context: context,
      confirmText: "Add",
      onPressed: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a filter name")),
          );
          return;
        }

        final provider = context.read<AdminDashboardProvider>();
        final message = await provider.addNewOrderFilter(name: name,status: status,storeName: widget.storeName);

        if (message != null) {
          ScaffoldMessenger.of(
            navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        } else {
          ScaffoldMessenger.of(  navigatorKey.currentContext!).showSnackBar(
            const SnackBar(content: Text("Filter added successfully!")),
          );
          Navigator.pop(  navigatorKey.currentContext!);
        }
      },
      contentView: StatefulBuilder(
        builder: (context, setState) {
          return Material(
            color: Colors.transparent,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                commonText(text: "Title"),
                commonTextField(hintText: '', controller: nameController),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonText(text: "Status:"),
                    CommonSwitch(
                      activeThumbColor: Colors.green,      // when ON
                      inactiveThumbColor: Colors.grey, // thumb when OFF
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.4), // track when OFF

                      value: status,
                      onChanged: (value) {
                        setState(() => status = value );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        Row(


          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            commonButton(
                height: 45,
                colorBorder: colorBorder,
                color: Colors.white,
                textColor: colorLogo,
                padding: EdgeInsets.symmetric(horizontal: 30),
                fontSize: 12,

                text: "Add New Order Filter", onPressed: (){
              _showAddFilterDialog(context);
            }),
          ],
        ),
        Expanded(
          child: Consumer<AdminDashboardProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return SizedBox.shrink();
              }
              if (provider.allOrderFilterList.isEmpty) {
                return commonErrorView();
              }

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                    child: Column(
                      children: [

                        SizedBox(height: 10),


                        SizedBox(height: 10),
                        Expanded(
                          child: commonListViewBuilder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            items: provider.allOrderFilterList,
                            itemBuilder: (context, index, data) {
                              final item = provider.allOrderFilterList[index];
                              return Container(
                                decoration: commonBoxDecoration(
                                  color: Colors.white,
                                  borderColor: colorBorder,
                                ),
                                margin: EdgeInsets.all(5),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical:15),
                                  child: commonListTile(

                                    titleFontSize: isMobile?14:16,

                                    contentPadding: EdgeInsetsGeometry.zero,
                                    title: item["title"].toString().toCapitalize(),
                                    trailing: Row(

                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        CommonSwitch(
                                          value: item["status"] ?? false,
                                          activeThumbColor: Colors.green,
                                          inactiveThumbColor: Colors.grey,
                                          inactiveTrackColor: Colors.grey.withValues(alpha: 0.4),
                                          onChanged: (value) {
                                            provider.toggleStatus(
                                              item["id"],
                                              value,
                                            );
                                          },

                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            showCommonDialog(
                                              confirmText: "Yes",
                                              cancelText: "No",
                                              title: "Delete",
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await context.read<AdminDashboardProvider>().deleteOrderFilter(uid: item["id"],storeName: widget.storeName);
                                                ScaffoldMessenger.of(  navigatorKey.currentContext!).showSnackBar(
                                                  SnackBar(content: Text("Deleted \"${item["title"]}\"")),
                                                );
                                              },
                                              context: context,
                                              content:
                                              "Are you sure you want to delete ${item["title"]}",
                                            );

                                          },
                                        ),
                                      ],
                                    ),



                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(

                          padding: const EdgeInsets.only(
                            bottom: 30.0,
                            top: 30.0,
                            left: 16,
                            right: 16,
                          ),
                          child: commonButton(
                            width: isMobile?MediaQuery.sizeOf(context).width:MediaQuery.sizeOf(context).width*0.3,
                            text: "Update",

                            onPressed: () async {
                              await provider.updateAllStatusesToFirebase(storeName: widget.storeName);
                              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                                SnackBar(
                                  content: commonText(
                                    text: "Statuses updated!",
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  provider.isLoading ? showLoaderList() : SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
