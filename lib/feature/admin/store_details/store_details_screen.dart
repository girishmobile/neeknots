import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/firebase/auth_service.dart';
import 'package:neeknots/feature/admin/store_details/all_user_list_page.dart';
import 'package:neeknots/feature/admin/store_details/product_list_page.dart';
import '../../../core/color/color_utils.dart';
import '../../../core/component/custom_tab_bar.dart';

import 'contact_list_page.dart';
import '../admin_view1/order_filter_list_page.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({super.key, required this.storeName});

  final String storeName;

  @override
  State<StoreDetailsScreen> createState() => StoreListPageState();
}

class StoreListPageState extends State<StoreDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController here
    _tabController = TabController(length: 4, vsync: this);
  }


  void init() {
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final AuthService authService = AuthService();
    return commonScaffold(
      body: Row(
        children: [
          /*  CommonAdminLeftMenu(
            selectedMenu: menuProvider.selectedMenu,
            menuItems: menuProvider.menuItems,
            onMenuSelect: (menu) => menuProvider.setSelectedMenu(menu),
          ),*/
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Expanded(
                    child: CustomTabBar(
                      isScrollable: false,

                      tabAlignment: TabAlignment.fill,
                      selectedColor: colorLogo,
                      unselectedColor: Colors.grey[700]!,
                      tabController: _tabController,
                      tabTitles: [
                        "All Users",
                        "Product",
                        "ContactUs",
                        "Order Filter",
                      ],
                      tabViews: [
                        AllUserListPage(storeName: widget.storeName),
                        ProductListPage(storeName:widget.storeName ,collectionName:authService.productCollection),
                        ContactListPage( storeName:widget.storeName ,collectionName:authService.contactUsCollection),
                        OrderFilterListPage( storeName:widget.storeName ,collectionName:authService.orderFilterCollection),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*  */
        ],
      ),
    );
  }
}
