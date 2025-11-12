import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/string/string_utils.dart';

import 'package:neeknots/feature/admin/store_details/contact_list_page.dart';
import 'package:provider/provider.dart';

import '../../core/component/responsive.dart';
import '../../provider/admin_dashboard_provider.dart';
import 'admin_view/admin_all_userlist.dart';
import 'admin_view/admin_product_list.dart';
import 'admin_view/common_admin_list_view.dart';
import 'admin_view/order_filter_list_page.dart';

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

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  /*@override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }
*/@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        init();
      });
    });
  }

  Future<void> init() async {
    final adminProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    await adminProvider.getAllStoreName(); // wait until data loads
    // ✅ Auto-select first store and fetch data
    if (adminProvider.allStoreNameModel?.stores?.isNotEmpty == true) {
      adminProvider.setSelectedStore(0);
      await adminProvider.countByAllStoreName(
        storeRoom: adminProvider.allStoreNameModel?.stores?[0].storeName ?? '',
      );
    }
    setState(() {}); // 🟢 ensure UI rebuilds after async load
  }

  // 🔹 Detail page for selected section (e.g., Orders, Products)
  Widget _buildSectionContent({
    required BuildContext context,
    required String section,
    required AdminDashboardProvider provider,
  }) {
    switch (section) {
      case "orders":
        return OrderFilterListPage(
          storeName:
              provider
                  .allStoreNameModel
                  ?.stores?[provider.selectedIndex]
                  .storeName ??
              '',
        );
      case "products":
        return AdminProductList(
          storeName:
              provider
                  .allStoreNameModel
                  ?.stores?[provider.selectedIndex]
                  .storeName ??
              '',
        );
      case "users":
        return AdminAllUserlist(
          storeName:
              provider
                  .allStoreNameModel
                  ?.stores?[provider.selectedIndex]
                  .storeName ??
              '',
        );
      case "contacts":
        return ContactListPage(
          storeName:
              provider
                  .allStoreNameModel
                  ?.stores?[provider.selectedIndex]
                  .storeName ??
              '',
        );
      default:
        return AdminAllUserlist(
          storeName:
              provider
                  .allStoreNameModel
                  ?.stores?[provider.selectedIndex]
                  .storeName ??
              '',
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
                text: appName,
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

            if (provider.allStoreNameModel?.stores?.isEmpty == true) {
              return const Center(child: CircularProgressIndicator());
            }

            // 🟢 STEP 2: Make sure selectedIndex is valid

            if (provider.selectedIndex >=
                (provider.allStoreNameModel?.stores?.length ?? 0)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.setSelectedStore(0);
              });
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
                                      ? (provider
                                                .allStoreNameModel
                                                ?.stores?[provider
                                                    .selectedIndex]
                                                .storeName
                                                ?.toString()
                                                .toUpperCase() ??
                                            "")
                                      : "${(provider.allStoreNameModel?.stores?[provider.selectedIndex].storeName?.toString().toCapitalize() ?? '')} / ${provider.selectedSection.toString().toCapitalize()}",
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
                                          provider
                                              .allStoreNameModel
                                              ?.stores?[provider.selectedIndex]
                                              .storeName ??
                                          '',
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
          provider.allStoreNameModel?.stores?.isNotEmpty==true?   Expanded(
            child: ListView.builder(
              itemCount: provider.allStoreNameModel?.stores?.length,
              itemBuilder: (context, index) {
                final store = provider.allStoreNameModel?.stores?[index];
                bool isSelected = provider.selectedIndex == index;
                return GestureDetector(
                  onTap: () async {
                    if (isMobile) {
                      Navigator.pop(context); // closes the drawer
                    }
                    provider.setSelectedStore(index);
                    provider.setSelectedSection(null);

                    await provider.countByAllStoreName(
                      storeRoom:
                          '${provider.allStoreNameModel?.stores?[index].storeName}',
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black
                          // ✅ subtle selection
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.store,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: commonText(
                            text:
                                store?.storeName.toString().toCapitalize() ??
                                '',
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                            //overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }
}
