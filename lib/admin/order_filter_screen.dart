import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/main.dart';
import 'package:provider/provider.dart';

import '../provider/admin_dashboard_provider.dart';

class OrderFilterScreen extends StatefulWidget {
  const OrderFilterScreen({super.key});

  @override
  State<OrderFilterScreen> createState() => _OrderFilterScreenState();
}

class _OrderFilterScreenState extends State<OrderFilterScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
    });
  }

  Future<void> init() async {
    final productProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    productProvider.getAllFilterOrderList();
  }

  void _showAddFilterDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool status = false;

    showCommonDialog(
      title: "Add New Filter",
      context: context,
      confirmText: "Save",
      onPressed: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a filter name")),
          );
          return;
        }

        final provider = context.read<AdminDashboardProvider>();
        final message = await provider.addNewOrderFilter(name: name,status: status,storeName: '');

        if (message != null) {
          ScaffoldMessenger.of(
            navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        } else {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(content: Text("Filter added successfully!")),
          );
          Navigator.pop(navigatorKey.currentContext!);
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
                    Checkbox(
                      value: status,
                      onChanged: (value) {
                        setState(() => status = value ?? false);
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

    return commonScaffold(
      appBar: commonAppBar(
        title: "Filter Order",
        actions: [
          IconButton(
            onPressed: () {
              _showAddFilterDialog(context);
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
          SizedBox(width: 8),
        ],
        context: context,
        centerTitle: true,
      ),
      body: commonAppBackground(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
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
                                borderColor: colorBorder,
                              ),
                              margin: EdgeInsets.all(5),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0.0),
                                child: commonListTile(
                                  contentPadding: EdgeInsetsGeometry.zero,
                                  title: item["title"] ?? "No Name",
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showCommonDialog(
                                        confirmText: "Yes",
                                        cancelText: "No",
                                        title: "Delete",
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await context
                                              .read<AdminDashboardProvider>()
                                              .deleteOrderFilter(
                                                uid: item["uid"],
                                                storeName: '',
                                              );
                                          ScaffoldMessenger.of(
                                            navigatorKey.currentContext!,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Deleted \"${item["title"]}\"",
                                              ),
                                            ),
                                          );
                                        },
                                        context: context,
                                        content:
                                            "Are you sure you want to delete ${item["title"]}",
                                      );
                                    },
                                  ),
                                  leadingIcon: Checkbox(
                                    value: item["status"] ?? false,
                                    onChanged: (value) {
                                      provider.toggleStatus(
                                        item["uid"],
                                        value ?? false,
                                      );
                                    },
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
                          left: 16,
                          right: 16,
                        ),
                        child: commonButton(
                          text: "Update",
                          onPressed: () async {
                            await provider.updateAllStatusesToFirebase(storeName: '');
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
    );
  }
}
