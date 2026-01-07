import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:provider/provider.dart';
import '../../core/component/responsive.dart';
import '../../provider/admin_menu_provider.dart';
import 'common_admin_left_menu.dart';
import 'all_store_page.dart';

class AdminHomeSameer extends StatefulWidget {
  const AdminHomeSameer({super.key});

  @override
  State<AdminHomeSameer> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomeSameer> {

  final List<Widget> screens = [
    AllStorePage(),
      Container(),
     Container(),
  ];

  @override
  Widget build(BuildContext context) {

    var menuProvider = Provider.of<AdminMenuProvider>(context);
    var isMobile = Responsive.isMobile(context);
    return commonScaffold(
      appBar: isMobile
          ? commonAppBar(
          context: context, title: appName)
          : const PreferredSize(
          preferredSize: Size.zero, child: SizedBox.shrink()),
      body: commonAppBackground(
        child: Row(
          children: [
            CommonAdminLeftMenu(
              selectedMenu: menuProvider.selectedMenu,
              menuItems: menuProvider.menuItems,
              onMenuSelect: (menu) {

                menuProvider.setSelectedMenu(menu);
              },
            ),
            Container(
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
                    color: Colors.grey.shade600.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(2, 0), // shadow to the right
                  ),
                ],
              ),
            ),
            /*Expanded(
              child: Container(
                color: Colors.white,
                child: Center(child: getPage(menuProvider.selectedMenu)),
              ),
            ),*/
            Expanded(
              child:screens[menuProvider.selectedIndex], // Else fallback to the selected screen
            )
          ],
        ),
      ),
    );
  }

  Widget getPage(String menu) {
    switch (menu) {
      case 'All Store':
        return AllStorePage();
      case 'Orders':
        return const Text('Orders Page', style: TextStyle(fontSize: 24));
      case 'Products':
        return const Text('Products Page', style: TextStyle(fontSize: 24));
      default:
        return const Text('Home Page', style: TextStyle(fontSize: 24));
    }
  }
}

