import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/url_launcher_service.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../core/component/date_utils.dart';
import '../../provider/admin_dashboard_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init();
    });
  }

  Future<void> init() async {
    final productProvider = Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    );

    productProvider.getAllContactList();
    productProvider.markAllAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      appBar: commonAppBar(
        title: "Notification",
        context: context,
        centerTitle: true,
      ),
      body: Consumer2<AdminDashboardProvider, ThemeProvider>(
        builder: (context, provider, themeProvider, child) {
          return commonAppBackground(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: commonListViewBuilder(
                items: provider.contacts,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemBuilder: (context, index, data) {
                  var data = provider.contacts[index];
                  return Container(
                    decoration: commonBoxDecoration(borderColor: getRandomColor(index),color: getRandomColor(index).withValues(alpha: 0.2)),
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            commonText(
                              text: 'Name:',
                              fontWeight: FontWeight.w600,
                            ),
                            commonText(
                              text: data['name'],
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

                        commonText(
                          text: data['message'],
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          color: colorTextDesc1,
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
                              _commonView(color: colorSale, title: "Call",onTap: (){
                                UrlLauncherService.launchPhoneCall( data['mobile']);
                              }),
                              _commonView(
                                color: colorUser,
                                icon: Icons.email_outlined,
                                title: "Email",
                                onTap: (){
                                  UrlLauncherService.launchEmail(  data['email'], body: "Test",subject: "Test");
                                }
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
          );
        },
      ),
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
