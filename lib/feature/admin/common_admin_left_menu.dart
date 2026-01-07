import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';

class CommonAdminLeftMenu extends StatelessWidget {
  final String selectedMenu;
  final List<String> menuItems;
  final ValueChanged<String> onMenuSelect;

  const CommonAdminLeftMenu({
    super.key,
    required this.selectedMenu,
    required this.menuItems,
    required this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.14,
      color: Colors.black,
      child: Column(
        children: [


          Container(
            height: 250,
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(16.0),
                child: commonAssetImage(icAppLogo),
              )),
          const SizedBox(height: 20),
          ...menuItems.map((menu) {
            bool isSelected = menu == selectedMenu;
            return InkWell(
              onTap: () => onMenuSelect(menu),
              child: Container(
                color: isSelected ? Colors.grey[800] : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      menu == 'All Store'
                          ? Icons.home
                          : menu == 'Orders'
                          ? Icons.shopping_cart
                          : Icons.production_quantity_limits,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      menu,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
