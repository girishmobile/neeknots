import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/component/context_extension.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/models/product_details_model.dart';
import 'package:neeknots/provider/product_provider.dart';
import 'package:neeknots/service/gloable_status_code.dart';
import 'package:provider/provider.dart';

import '../../core/component/common_dropdown.dart';
import '../../core/image_picker/image_pick_and_crop_widget.dart';
import '../../main.dart';
import '../../provider/theme_provider.dart';
import 'common_product_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    //Update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.setIsImageUpdating(true);
      if (widget.productId.isNotEmpty) {
        provider
            .getProductById(productId: widget.productId)
            .then((value) {
              if (globalStatusCode == 200) {
                provider.productImages =
                    provider.productDetailsModel?.images ?? [];
                provider.fetchImagesForProduct(
                  provider.productDetailsModel ?? ProductDetailsModel(),
                );
                //For Update
                provider.tetName.text =
                    provider.productDetailsModel?.title ?? '';
                provider.tetDesc.text = removeHtmlTags(
                  provider.productDetailsModel?.bodyHtml ?? '',
                );
                final stockInfo = _stockCalculation(provider);
                provider.tetQty.text = stockInfo["inventory"] ?? '';
                provider.tetPrice.text =
                    provider.productDetailsModel?.variants?.first.price ?? "0";

                provider.initializeVariantController(
                  provider.productDetailsModel?.variants,
                );
              }
              provider.setIsImageUpdating(false);
            })
            .catchError((onError) {
              provider.setIsImageUpdating(false);
            });
      }
    });
  }

  void getProductDetail() {}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(
      navigatorKey.currentContext!,
    );
    final stockInfo = _stockCalculation(provider);
    final inventory = "${stockInfo["inventory"]} in stock";
    final variants = "for ${stockInfo["variants"]} variants";
    final textPrice = _priceCalculation(provider);
    return commonScaffold(
      appBar: commonAppBar(
        title: "Product Details",
        backgroundColor: Colors.transparent,
        context: context,
        centerTitle: true,
      ),
      body: commonAppBackground(
        child: Stack(
          children: [
            if (provider.productDetailsModel != null)
              commonRefreshIndicator(
                onRefresh: () async {
                  // Add your refresh logic here if needed
                  init();
                },
                child: ListView(
                  children: [
                    commonBannerView(
                      provider: provider,
                      images: provider.productImages,
                      onTap: () async {
                        final path = await CommonImagePicker.pickImage(
                          context,
                          themeProvider,
                        );
                        if (path != null) {
                          provider.uploadProductImage(
                            imagePath: path,
                            productName:
                                provider.productDetailsModel?.title ?? '',
                            productId: int.parse(widget.productId),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: commonText(
                                      text:
                                          provider.productDetailsModel?.title ??
                                          '',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.isDark
                                          ? Colors.white
                                          : colorLogo,
                                    ),
                                  ),
                                  commonText(
                                    text: textPrice,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: commonBoxDecoration(
                                      borderColor: colorBorder,
                                      color: colorBgNew
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 5,
                                    ),
                                    child: _commonRichText(
                                      str1: inventory ,
                                      str2: variants ,
                                      provider: themeProvider,
                                    ),
                                  ),

                                  Spacer(),
                                  Container(
                                    decoration: commonBoxDecoration(
                                      borderColor: colorBorder,
                                        color: colorBgNew
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        commonText(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          text: "Status : ",
                                        ),
                                        commonText(
                                          textAlign: TextAlign.right,
                                          text:
                                              provider
                                                  .productDetailsModel
                                                  ?.status ??
                                              '',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: provider.getStatusColor(
                                            provider.productDetailsModel?.status
                                                    ?.toCapitalize() ??
                                                'Grey',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),

                              commonText(
                                text:
                                    "Description", //widget.product.desc ?? '',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),

                              commonText(
                                text: removeHtmlTags(
                                  provider.productDetailsModel?.bodyHtml ?? '',
                                ),
                              ),
                            ],
                          ),
                          // commonFormView(provider: provider),
                          SizedBox(height: 15),
                          commonOtherVariants(
                            provider: provider,
                            products:
                                provider.productDetailsModel ??
                                ProductDetailsModel(),
                          ),
                          commonVariants(
                            provider: provider,
                            products:
                                provider.productDetailsModel ??
                                ProductDetailsModel(),
                          ),
                          SizedBox(height: 30),

                          commonButton(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            text: "Edit",
                            //text: provider.isEdit ? "Update" : "Edit",
                            onPressed: () {
                              final navigator = Navigator.of(context);
                              appBottomSheetWithSafeArea(
                                context: context,
                                child: Consumer<ProductProvider>(
                                  builder: (context, provider, _) {
                                    return Stack(
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  commonInkWell(
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration:
                                                          commonBoxDecoration(
                                                            color: Colors.black,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Center(
                                                        child: Icon(
                                                          size: 15,
                                                          Icons.close,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              commonFormView(
                                                provider: provider,
                                              ),
                                              SizedBox(height: 16),
                                              // updateVariant(
                                              //   provider: provider,
                                              //   variants:
                                              //       provider
                                              //           .product
                                              //           ?.variants ??
                                              //       [],
                                              // ),
                                              /**
                                               * provider
                                                  .priceControllers[variant
                                                  .id]
                                               */
                                              _commonHeading(text: "Status"),
                                              SizedBox(height: 16),
                                              CommonDropdown(
                                                initialValue: provider.status,
                                                items: ["Active", "Draft"],
                                                enabled: provider.isEdit,
                                                onChanged: provider.isEdit
                                                    ? (value) {
                                                        provider.setFilter(
                                                          value!,
                                                        );
                                                      }
                                                    : (value) {},
                                              ),
                                              SizedBox(height: 30),
                                              commonButton(
                                                text: "Update",
                                                onPressed: () {
                                                  provider.setIsImageUpdating(
                                                    true,
                                                  );
                                                  final variantsPayload = provider
                                                      .productDetailsModel
                                                      ?.variants
                                                      ?.map((variant) {
                                                        return {
                                                          "id": variant.id,
                                                          "price": provider
                                                              .tetPrice
                                                              .text,
                                                          "inventory_quantity":
                                                              int.tryParse(
                                                                provider
                                                                    .qtyControllers[variant
                                                                        .id]!
                                                                    .text,
                                                              ) ??
                                                              0,
                                                        };
                                                      })
                                                      .toList();
                                                  provider
                                                      .updateProductById(
                                                        title: provider
                                                            .tetName
                                                            .text,
                                                        description: provider
                                                            .tetDesc
                                                            .text,
                                                        productId: int.parse(
                                                          widget.productId,
                                                        ),
                                                        variants:
                                                            variantsPayload,
                                                      )
                                                      .then((onValue) {
                                                        init();
                                                        provider
                                                            .setIsImageUpdating(
                                                              false,
                                                            );
                                                        navigator.pop();
                                                      })
                                                      .catchError((onError) {
                                                        provider
                                                            .setIsImageUpdating(
                                                              false,
                                                            );
                                                      });
                                                },
                                              ),
                                              SizedBox(height: 30),
                                            ],
                                          ),
                                        ),

                                        provider.isImageUpdating
                                            ? showLoaderList()
                                            : SizedBox.shrink(),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              commonErrorView(text: "Loading..."),
            provider.isImageUpdating ? showLoaderList() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Map<String, String> _stockCalculation(ProductProvider provider) {
    var data = provider.productDetailsModel?.variants ?? [];
    final totalVariants = data.length;
    //  final left = "${parts[0]}for";
    num? totalInventory = data.isNotEmpty == true
        ? data.fold(
            0,
            (sum, variant) => sum! + (variant.inventoryQuantity ?? 0),
          )
        : 0;

    return {"inventory": "$totalInventory", "variants": "$totalVariants"};
  }

  String _priceCalculation(ProductProvider provider) {
    var data = provider.productDetailsModel?.variants ?? [];
    final priceText = data.isNotEmpty == true
        ? '$rupeeIcon${data.first.price}'
        : '$rupeeIcon 0';
    return priceText;
  }

Widget  _commonRichText({
    required String str1,
    required String str2,
    required ThemeProvider provider,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$str1 ", // first part
            style: commonTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorOffline,
            ),
          ),
          TextSpan(
            text: str2, // second part
            style: commonTextStyle(
              fontSize: 12,
              color: provider.isDark ? Colors.white : colorText,
            ),
          ),
        ],
      ),
    );
  }


 Widget _commonHeading({String? text}) {
    return commonText(
      text: text ?? "Product Description",
      fontWeight: FontWeight.w600,
    );
  }
}
