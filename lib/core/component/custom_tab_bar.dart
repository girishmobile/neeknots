import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabTitles;
  final List<Widget> tabViews;
  final Color selectedColor;
  final Color unselectedColor;
  final double borderRadius;
  final double ?fontSize;
  final Color? dividerColor;
  final bool isScrollable;
  final Color? labelColor;
  final TabAlignment? tabAlignment;
  final Decoration? decoration;
  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabTitles,
    required this.tabViews,
    this.decoration,
    this.dividerColor,
    this.tabAlignment,
    this.fontSize,
    required this.isScrollable,
    this.labelColor,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    assert(tabTitles.length == tabViews.length,
    "tabTitles and tabViews length must be same");

    return Column(
      children: [
        Container(
          height: 45,
          margin: const EdgeInsets.all(0),
          decoration:decoration?? BoxDecoration(
            color: colorBorder,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: TabBar(

            indicatorPadding: EdgeInsetsGeometry.zero,
            tabAlignment:tabAlignment,

            controller: tabController,
            dividerColor: dividerColor??Colors.transparent,
            labelStyle: commonTextStyle(
              fontSize: fontSize??12,
              fontWeight: FontWeight.w600
            ),
            unselectedLabelStyle: commonTextStyle(
                fontSize:fontSize??12,
                fontWeight: FontWeight.w600
            ),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            isScrollable: isScrollable,
            indicatorSize: TabBarIndicatorSize.tab,

            splashFactory: NoSplash.splashFactory,
            labelColor:labelColor?? Colors.white,
            unselectedLabelColor: unselectedColor,
            indicator:decoration?? BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            tabs: tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: tabViews,
          ),
        ),
      ],
    );
  }
}
