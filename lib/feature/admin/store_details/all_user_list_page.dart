import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../admin/common_admin_widget.dart';
import '../../../core/color/color_utils.dart';
import '../../../core/component/component.dart';
import '../../../core/image/image_utils.dart';
import '../../../provider/admin_dashboard_provider.dart';

class AllUserListPage extends StatefulWidget {
  const AllUserListPage({super.key, required this.storeName});

  final String storeName;

  @override
  State<AllUserListPage> createState() => _AllUserListPageState();
}

class _AllUserListPageState extends State<AllUserListPage> {
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

    setState(() {
      customerProvider.getUsersByStoreName(widget.storeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        final users = provider.allUsers;
        return commonRefreshIndicator(
          onRefresh: () async {
            init();
          },
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 10),

                  /*Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: commonTextField(
                      hintText: 'Search by name or email',
                      onChanged: (value) {
                        provider.applySearch(value);
                      },
                    ),
                  ),*/
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final data = users[index];
                        return Container(
                          decoration: commonBoxDecoration(
                            borderColor: colorBorder,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              ClipRRect(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 100,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  imageUrl: data["logo_url"],
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      width: 20, // 👈 yahan size set kijiye
                                      height: 20, // 👈 yahan size set kijiye
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: commonAssetImage(
                                      borderRadius: BorderRadius.circular(10),
                                      icErrorImage,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  spacing: 5,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _commonText(
                                      fontWeight: FontWeight.w600,
                                      title: "Name",
                                      value:
                                          data["name"] ??
                                          data["email"] ??
                                          "No Name",
                                    ),

                                    _commonText(
                                      title: "Mobile",
                                      value:
                                          "${data["country_code"] ?? "N/A"}${data["mobile"] ?? "N/A"}",
                                    ),
                                    _commonText(
                                      title: "Email",
                                      value: "${data["email"] ?? "N/A"}",
                                    ),

                                    _commonText(
                                      title: "Store Name",
                                      value: "${data["store_name"] ?? "N/A"}",
                                    ),
                                    _commonText(
                                      title: "Staus",
                                      view: Row(
                                        spacing: 20,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: commonBoxDecoration(
                                              borderColor:
                                                  data["active_status"] == true
                                                  ? Colors.green.withValues(
                                                      alpha: 0.5,
                                                    )
                                                  : Colors.red.withValues(
                                                      alpha: 0.5,
                                                    ),
                                              color:
                                                  data["active_status"] == true
                                                  ? Colors.green.withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : Colors.red.withValues(
                                                      alpha: 0.1,
                                                    ),
                                            ),
                                            child: Center(
                                              child: commonText(
                                                fontSize: 10,
                                                color:
                                                    data["active_status"] ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
                                                text:
                                                    data["active_status"] ==
                                                        true
                                                    ? "Active".toUpperCase()
                                                    : "Inactive".toUpperCase(),
                                              ),
                                            ),
                                          ),
                                          commonInkWell(
                                            onTap: () {
                                              showCommonBottomSheet(
                                                context: context,
                                                content: SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).height *
                                                      0.8,
                                                  child: ListView(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          commonHeadingText(
                                                            text:
                                                                "Edit Information",
                                                          ),
                                                          commonInkWell(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 35,
                                                              height: 35,
                                                              decoration:
                                                                  commonBoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20),
                                                      CommonAdminWidget(
                                                        data: data,
                                                        provider: provider,
                                                        onPressed: () {},
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 5,
                                              ),
                                              decoration: commonBoxDecoration(
                                                borderColor: colorLogo,
                                                color: colorLogo,
                                              ),
                                              child: Center(
                                                child: commonText(
                                                  fontSize: 10,
                                                  color: Colors.white,

                                                  fontWeight: FontWeight.w500,
                                                  text: "Edit Info"
                                                      .toUpperCase(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                ],
              ),

              provider.isLoading || provider.isUpdated
                  ? showLoaderList()
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _commonText({
    String? title,
    String? value,
    FontWeight? fontWeight,
    Widget? view,
  }) {
    return Row(
      spacing: 10,
      children: [
        commonText(
          fontSize: 12,
          fontWeight: fontWeight ?? FontWeight.w400,
          text: "$title:",
        ),
        Flexible(
          child:
              view ??
              commonText(
                fontSize: 12,
                fontWeight: fontWeight ?? FontWeight.w400,
                text: value ?? '',
              ),
        ),
      ],
    );
  }
}
