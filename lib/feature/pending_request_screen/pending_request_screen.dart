import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:provider/provider.dart';

import '../../core/component/date_utils.dart';
import '../../provider/product_provider.dart';

class PendingRequestScreen extends StatefulWidget {
  const PendingRequestScreen({super.key});

  @override
  State<PendingRequestScreen> createState() => _PendingRequestScreenState();
}

class _PendingRequestScreenState extends State<PendingRequestScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ProductProvider>(context, listen: false);

      provider.getAllPendingRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return commonScaffold(
      appBar: commonAppBar(
        title: "Pending Request",
        context: context,
        centerTitle: true,
      ),
      body: commonRefreshIndicator(
        onRefresh: ()async{
          init();
        },
        child: commonAppBackground(
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return SizedBox.shrink();
              }

              return Stack(
                children: [
                  provider.allPendingRequest.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.allPendingRequest.length,
                          itemBuilder: (context, index) {
                            var data = provider.allPendingRequest[index];
                            Uint8List? imageBytes;
                            if (data['image'] != null &&
                                data['image'].isNotEmpty) {
                              imageBytes = base64Decode(data['image']);
                            }
                            return Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: commonBoxDecoration(
                                borderColor: colorBorder,
                              ),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(8.0),
                              child: Column(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadiusGeometry.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Image.memory(
                                            imageBytes,
                                            width: size.width,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SizedBox.shrink(),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8,
                                      top: 5,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      spacing: 8,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        commonText(
                                          text: data['name'],
                                          fontWeight: FontWeight.w500,
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: commonText(
                                                text: formatTimestamp(
                                                  data['created_date'],
                                                ),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                            _commonButton(
                                              color: Colors.green,
                                              onTap: () {
                                                showCommonDialog(
                                                  confirmText: "Upload",
                                                  title: "Approve",
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                    provider
                                                        .uploadProductImageViaAdmin(
                                                          imagePath:
                                                              data['image'],
                                                          productId:
                                                              data['product_id'],
                                                          uid: data['id'],
                                                        );
                                                  },
                                                  context: context,
                                                  content:
                                                      "Are you sure you want to approve this image?",
                                                );
                                              },
                                            ),
                                            SizedBox(width: 8),
                                            _commonButton(
                                              color: Colors.red,
                                              onTap: () {
                                                showCommonDialog(
                                                  confirmText: "Yes",
                                                  title: "Decline",
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    print('=======${ data['id']}');
                                                     provider.updateProductStatus(
                                                      uid: data['id'],
                                                      title: "disapproved_date",
                                                    );
                                                  },
                                                  context: context,
                                                  content:
                                                      "Are you sure you want to disapprove this image?",
                                                );
                                              },
                                              text: "Disapprove",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            );
                          },
                        )
                      : commonErrorView(),

                  provider.isLoading || provider.isImageUpdating
                      ? showLoaderList()
                      : SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _commonButton({
    String? text,
    required Color color,
    void Function()? onTap,
  }) {
    return commonInkWell(
      onTap: onTap,
      child: Container(
        decoration: commonBoxDecoration(
          borderColor: color,
          color: color.withValues(alpha: 0.05),
          borderRadius: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: Center(
            child: commonText(
              color: color,
              text: text ?? "Approve",
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
