import 'package:flutter/material.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:provider/provider.dart';

import '../../../core/color/color_utils.dart';
import '../../../core/component/component.dart';
import '../../../core/component/date_utils.dart';
import '../../../core/component/responsive.dart';
import '../../../core/component/url_launcher_service.dart';
import '../../../provider/admin_dashboard_provider.dart';
import '../../../provider/theme_provider.dart';

class ContactListPage extends StatefulWidget {
  final String storeName;
  final String collectionName;

  const ContactListPage({
    super.key,
    required this.storeName,
    required this.collectionName,
  });

  @override
  State<ContactListPage> createState() => _StoreCollectionTabState();
}

class _StoreCollectionTabState extends State<ContactListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() {
    final customerProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    customerProvider.getStoreCollectionData(
      storeName: widget.storeName,
      collectionName: widget.collectionName,
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = Responsive.isMobile(context);
    return Consumer2<AdminDashboardProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, child) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 12,
                  childAspectRatio: isMobile
                      ? 1.7
                      : 3.1, // adjust roughly for initial layout
                ),
                itemCount: provider.contacts.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  var data = provider.contacts[index];
                  return Container(
                    decoration: commonBoxDecoration(
                      borderColor: colorBorder,
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            commonText(
                              text: 'Name:',
                              fontWeight: FontWeight.w600,
                            ),
                            commonText(
                              text: data['name'].toString().toCapitalize(),
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            commonText(
                              text: 'Mobile:',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            commonText(
                              text: data['mobile'],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            commonText(
                              text: 'Date:',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            commonText(
                              text: formatTimestamp(data['created_at']),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ],
                        ),

                        Flexible(
                          child: commonText(
                            text: data['message'],
                            maxLines: 5,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            color: colorTextDesc1,
                          ),
                        ),

                        Divider(thickness: 0.5),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            spacing: 10,
                            children: [
                              _commonView(
                                color: colorSale,
                                title: "Call",
                                onTap: () {
                                  UrlLauncherService.launchPhoneCall(
                                    data['mobile'],
                                  );
                                },
                              ),
                              _commonView(
                                color: colorUser,
                                icon: Icons.email_outlined,
                                title: "Email",
                                onTap: () {
                                  UrlLauncherService.launchEmail(
                                    data['email'],
                                    body: "Test",
                                    subject: "Test",
                                  );
                                },
                              ),
                              _commonView(
                                color: colorProduct,
                                icon: Icons.info_outline,
                                title: "Info",
                                onTap: () {
                                  showCommonDialog(
                                    title: "Info",
                                    showCancel: false,
                                    confirmText: "Close",
                                    context: context,
                                    content: data['message'],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            provider.isLoading ? showLoaderList() : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _commonView({
    Color? color,
    IconData? icon,
    String? title,
    void Function()? onTap,
  }) {
    return Column(
      spacing: 5,
      children: [
        commonInkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,

            decoration: commonBoxDecoration(
              color: color ?? colorTextDesc1,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon ?? Icons.call_outlined, color: Colors.white),
            ),
          ),
        ),

        commonText(
          text: title ?? '',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
