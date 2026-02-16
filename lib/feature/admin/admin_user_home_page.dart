import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/feature/admin/admin_view1/order_filter_list_page.dart';
import 'package:neeknots/feature/admin/store_details/contact_list_page.dart';
import 'package:provider/provider.dart';

import '../../core/component/responsive.dart';
import '../../core/firebase/auth_service.dart';
import '../../main.dart';
import '../../provider/admin_dashboard_provider.dart';
import '../../routes/app_routes.dart';
import 'admin_view1/admin_all_userlist.dart';
import 'admin_view1/admin_product_list.dart';
import 'admin_view1/common_admin_list_view.dart';

class AdminUserModel {
  final String name;
  final String email;
  final String phone;
  bool isActive; // for switch toggle

  AdminUserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.isActive = true,
  });
}

class AdminUserHomePage extends StatefulWidget {
  const AdminUserHomePage({super.key,this.storeName});

final   String? storeName;
  @override
  State<AdminUserHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminUserHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    final provider =
    Provider.of<AdminDashboardProvider>(context, listen: false);

    await provider.getAdminStoreUsers();
  }
  // 🔹 Detail page for selected section (e.g., Orders, Products)
  Widget _buildSectionContent({
    required BuildContext context,
    required String section,
    required AdminDashboardProvider provider,
  }) {
    final AuthService authService = AuthService();
    switch (section) {
      case "Orders":
        return OrderFilterListPage(
          storeName: provider.storeList [provider.selectedIndex]['store_name'],
          collectionName: authService.orderFilterCollection,
        );
      case "Products":
        return AdminProductList(
          storeName: provider.storeList [provider.selectedIndex]['store_name'],
          collectionName: authService.productCollection,
        );
      case "Users":
        return AdminAllUserlist(
          storeName: provider.storeList [provider.selectedIndex]['store_name'],
        );
      case "Contacts":
        return ContactListPage(
          storeName: provider.storeList [provider.selectedIndex]['store_name'],
          collectionName: authService.contactUsCollection,
        );
      default:
        return AdminAllUserlist(
          storeName: provider.storeList [provider.selectedIndex]['store_name'],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = Responsive.isMobile(context);
    return commonScaffold(
      backgroundColor: colorBg,
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.white,
              child: Consumer<AdminDashboardProvider>(
                builder: (context, provider, child) {
                  return _commonLiftView(provider: provider);
                },
              ),
            )
          : SizedBox.shrink(),
      appBar: isMobile
          ? AppBar(
              centerTitle: true,
              title: commonText(
                text:widget.storeName?.toUpperCase()?? appName,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: colorBg,
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox.shrink(),
            ),
      body: commonAppBackground(
        child: Consumer<AdminDashboardProvider>(
          builder: (context, provider, child) {
            // 🟡 STEP 1: Handle loading / empty state

            if (provider.storeList .isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // 🟢 STEP 2: Make sure selectedIndex is valid

            if (provider.selectedIndex >= provider.storeList .length) {
              provider.setSelectedStore(0);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                double screenHeight = constraints.maxHeight;

                double screenWidth = constraints.maxWidth;
                double sidebarWidth = screenWidth >= 1200
                    ? screenWidth * 0.20
                    : screenWidth >= 800
                    ? screenWidth * 0.25
                    : screenWidth * 0.30;

                return Row(
                  children: [
                    // 🟪 LEFT PANEL (Sidebar)
                    isMobile
                        ? SizedBox.shrink()
                        : Container(
                            width: sidebarWidth,
                            height: screenHeight,
                            decoration: commonBoxDecoration(
                              borderRadius: 0,
                              borderColor: colorBorder,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _commonLiftView(provider: provider),
                          ),
                    isMobile
                        ? SizedBox.shrink()
                        : Container(
                            width: 2, // slightly thicker for 3D effect
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey.shade300, // light top edge
                                  Colors.grey.shade400, // middle
                                  Colors.grey.shade500, // bottom shadow
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade600.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(
                                    2,
                                    0,
                                  ), // shadow to the right
                                ),
                              ],
                            ),
                          ),
                    // 🟩 RIGHT PANEL (Main content)
                    Expanded(
                      child: Container(
                        color: colorBg,
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Header with store name
                            // 🏷 Top header with back arrow
                            Row(
                              children: [
                                if (provider.selectedSection != null)
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      // provider.setSelectedStore(index);
                                      provider.setSelectedSection(null);
                                      // setState(() => selectedSection = null);
                                    },
                                  ),
                                commonText(
                                  text: provider.selectedSection == null
                                      ? provider
                                            .storeList [provider
                                                .selectedIndex]['store_name']
                                            .toString()
                                            .toUpperCase() // optional
                                      : "${provider.storeList [provider.selectedIndex]['store_name'].toString().toCapitalize()} / ${provider.selectedSection!}",
                                  fontSize: isMobile ? 16 : 20,
                                  fontWeight: isMobile
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 10 : 24),
                            // 🧩 Main content (grid or detail)
                            Expanded(
                              child: provider.selectedSection == null
                                  ? CommonAdminListView(
                                      storeName:
                                          provider.storeList [provider
                                              .selectedIndex]['store_name'],
                                    )
                                  : _buildSectionContent(
                                      context: context,
                                      provider: provider,
                                      section: provider.selectedSection ?? '',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _commonLiftView({required AdminDashboardProvider provider}) {
    var isMobile = Responsive.isMobile(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0),

          Container(
            height: 150,
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              child: commonAssetImage(icAppLogo, fit: BoxFit.scaleDown),
            ),
          ),
          SizedBox(height: isMobile ? 0 : 56),
          commonText(
            text: "My Stores",
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: isMobile ? 10 : 24),

          GestureDetector(
            onTap: () async {
              if (isMobile) {
                Navigator.pop(context); // closes the drawer
              }


            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
             decoration: BoxDecoration(
                color:Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:  Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color:Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: commonText(
                      text: widget.storeName.toString().toCapitalize(),
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                           FontWeight.normal,
                      //overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),


          Spacer(),
          commonButton(
            height: 45,
            color: Colors.red,
            width: double.infinity,
            text: "LogOut",
            onPressed: () {
              showCommonDialog(
                confirmText: "Logout",
                cancelText: "No",
                content: "Are you sure want to logout",
                title: "Logout",
                context: context,
                onPressed: () {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    RouteName.adminLoginPage,
                    (Route<dynamic> route) => false,
                  );
                },
              );
            },
          ),
          SizedBox(height: 40,)
        ],
      ),
    );
  }
}
