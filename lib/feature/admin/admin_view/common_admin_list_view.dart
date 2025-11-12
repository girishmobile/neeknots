import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/component/animated_counter.dart';
import '../../../core/component/responsive.dart';
import '../../../provider/admin_home_provider.dart';

class CommonAdminListView extends StatefulWidget {
   const CommonAdminListView({super.key,required this.storeName});

   final String  storeName;
  @override
  State<CommonAdminListView> createState() => _CommonAdminListViewState();
}

class _CommonAdminListViewState extends State<CommonAdminListView> {

  final List<Map<String, dynamic>> dashboardItems = [
    {"title": "users", "icon": icTotalUser},
    {"title": "orders", "icon": icOrderMenu},
    {"title": "products", "icon": icProductMenu},
    {"title": "contacts", "icon": icContact},
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminDashboardProvider>();
      if (widget.storeName.isNotEmpty) {
        provider.clearCountData();
        provider.countByAllStoreName(storeRoom: widget.storeName);
      } else {
        debugPrint("⏳ Skipping countByAllStoreName — storeName empty");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<AdminDashboardProvider>();
    var isMobile = Responsive.isMobile(context);
    return    Consumer<AdminDashboardProvider>(
      builder: (context,provider,child) {
        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;

                // 🧩 Dynamic grid column count
                int crossAxisCount;
                if (screenWidth >= 1200) {
                  crossAxisCount = 4;
                } else if (screenWidth >= 800) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }
                return GridView.builder(
                  itemCount: dashboardItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile?0.9:1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];

                    final count = homeProvider.getCountForTitle(item["title"]);
                    final storeColor = provider.getProfessionColor(
                      item["title"],
                      index,
                    );
                    return InkWell(
                      onTap: () {

                     /* setState(() {
                        widget.selectedSection = item["title"];
                      });*/
                        homeProvider.setSelectedSection(item["title"]);

                        //  setState(() => widget.selectedSection = item["title"]);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: commonBoxDecoration(
                          color: storeColor.withValues(alpha: 0.03),
                          borderColor: storeColor,
                         // color: isSelected ? Colors.blue.shade50 : Colors.white,
                          //borderRadius: BorderRadius.circular(12),
                         /* border: isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,*/
                       /*   boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],*/
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            commonAssetImage(item["icon"],width:  isMobile?55:64,height: isMobile?55:64,color: storeColor),

                            const SizedBox(height: 10),
                            commonText(
                              text: item["title"].toString().toCapitalize(),
                              fontSize:  isMobile?14:16,
                              fontWeight: FontWeight.w600,
                              color: storeColor,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 50,
                              height: 50,
                              padding: EdgeInsets.all(2),
                              // border thickness
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: storeColor, // border color
                                  width: 1, // border width
                                ),
                              ),
                              child: Center(
                                child: AnimatedCounter(
                                  leftText: '',
                                  rightText: '',
                                  endValue: count,
                                  duration: Duration(milliseconds: 200),
                                  style: commonTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: storeColor,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            provider.isLoading?showLoaderList():SizedBox.shrink()
          ],
        );
      }
    );;
  }
}
