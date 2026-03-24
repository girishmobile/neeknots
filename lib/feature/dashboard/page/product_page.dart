import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/custom_tab_bar.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/provider/product_provider.dart';
import 'package:provider/provider.dart';

import '../product_widget/active_draft_view.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  Future<void> init() async {
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return commonRefreshIndicator(
      onRefresh: () async {
        init();
      },
      child: Padding(
        padding: EdgeInsets.only(left: 16,right: 16,bottom: 0,top: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
                  child: commonTextField(

                    fillColor: Colors.pink.shade100.withValues(alpha: 0.2),
                    filled: true,
                    hintText: "Search products by name...",
                    prefixIcon: commonPrefixIcon(
                      image: icProductSearch,
                      width: 16,
                      height: 16,
                    ),
                    onChanged: (value) => provider.setSearchQuery(value),
                  ),
                );
              },
            ),
            SizedBox(height: 15),
            Expanded(
              child: CustomTabBar(
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                selectedColor: colorMenu.withValues(alpha: 0.7),
                unselectedColor: Colors.grey[700]!,
                tabController: _tabController,
                tabTitles: ["Active", "Draft"],
                tabViews: [
                  ActiveDraftView(status: "active"),
                  ActiveDraftView(status: "draft"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
