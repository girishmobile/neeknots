import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:provider/provider.dart';

import '../core/component/context_extension.dart';
import '../core/hive/app_config_cache.dart';
import '../provider/admin_dashboard_provider.dart';

class CommonAllStoreWidget extends StatefulWidget {
  const CommonAllStoreWidget({super.key, this.onStoreChanged});

  final Function(bool)? onStoreChanged;

  @override
  State<CommonAllStoreWidget> createState() => _CommonAllStoreWidgetState();
}

class _CommonAllStoreWidgetState extends State<CommonAllStoreWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
    });
  }

  Future<void> init() async {
    final provider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    await provider.getUserStoresByEmail();
    // 🔥 Saved store name getUserStoresByEmail
    final savedStoreName = await AppConfigCache.getStoreName();

    if (savedStoreName.isNotEmpty) {
      final index = provider.storeCounts.indexWhere(
        (e) => e['store_name'] == savedStoreName,
      );

      if (index != -1) {
        provider.setSelectedStore(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.storeCounts.length <= 1) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(
              text: "Select Store",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorBgNew,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  value: provider.selectedIndex,
                  hint: commonText(text: "Select Store"),
                  items: List.generate(provider.storeCounts.length, (index) {
                    final store = provider.storeCounts[index];
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: commonText(
                              fontWeight: FontWeight.w500,
                              text: store['store_name']
                                  .toString()
                                  .toCapitalize(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  onChanged: (index) async {
                    if (index == null) return;

                    provider.setSelectedStore(index);
                    provider.setSelectedSection(null);

                    final selectedStore = provider.storeCounts[index];

                    // ✅ Do async work OUTSIDE setState
                    await AppConfigCache.saveConfig(
                      accessToken: selectedStore['accessToken'] ?? '',
                      storeName: selectedStore['store_name'] ?? '',
                      versionCode: selectedStore['version_code'] ?? '',
                      logoUrl: selectedStore['logo_url'] ?? '',
                    );

                    if (widget.onStoreChanged != null) {
                      widget.onStoreChanged!(true);
                    }
                    // ✅ Only call setState if UI needs update
                    setState(() {});
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
