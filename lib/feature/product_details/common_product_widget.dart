import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neeknots/core/component/price_input_format.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/core/string/string_utils.dart';

import 'package:neeknots/provider/product_provider.dart';
import 'package:provider/provider.dart';

import '../../core/color/color_utils.dart';
import '../../core/component/component.dart';
import '../../main.dart';
import '../../models/product_details_model.dart';
import '../../provider/theme_provider.dart';

Widget commonBannerView({
  required ProductProvider provider,
  required List<Images> images,
  void Function()? onTap,
  void Function()? onDelete,
}) {
  final themeProvider = Provider.of<ThemeProvider>(
    navigatorKey.currentContext!,
  );

  return images.isNotEmpty
      ? Column(
          children: [
            SizedBox(height: 8),
            CarouselSlider(
              options: CarouselOptions(
                height: 360.0,
                enlargeCenterPage: false,
                autoPlay: false,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                viewportFraction: images.length == 1
                    ? 1.0
                    : 0.7, // ek image ho to full width
                //enableInfiniteScroll: true,
                enableInfiniteScroll:
                    images.length > 1, // ek hi image ho to scroll band
                autoPlayAnimationDuration: const Duration(milliseconds: 800),

                onPageChanged: (index, reason) {
                  provider.setCurrentIndex(index); // update providercdvs
                },
              ),
              items: images.map((img) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade200,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: commonNetworkImage(
                              img.src,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: commonInkWell(
                              onTap: () {
                                showCommonDialog(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    provider
                                        .deleteProductImage(
                                          imageId: img.id ?? 0,
                                          productId: img.productId ?? 0,
                                          provider: provider,
                                        )
                                        .then((val) {});
                                  },
                                  confirmText: "Remove",
                                  title: "Remove",
                                  context: context,
                                  content:
                                      "Do you want to remove this image from our product.",
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: commonBoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorLogo.withValues(alpha: 0.5),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            /// Dots Indicator
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    // optionally jump to slide using controller
                  },
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (provider.currentIndex == entry.key
                                  ? colorLogo
                                  : Colors.grey)
                              .withValues(alpha: 0.9),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            _addImageButton(themeProvider: themeProvider, onTap: onTap),
          ],
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 360,
              child: commonAssetImage(icErrorImage, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            _addImageButton(themeProvider: themeProvider, onTap: onTap),
          ],
        );
}
//:39910815269055

Widget _addImageButton({
  required ThemeProvider themeProvider,
  VoidCallback? onTap,
}) {
  return Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        commonInkWell(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: commonBoxDecoration(
              borderWidth: 0.5,
              borderColor: themeProvider.isDark ? Colors.white : colorLogo,
            ),
            child: Center(
              child: commonText(
                text: "Add Image",
                color: themeProvider.isDark ? Colors.white : colorLogo,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget commonFormView({required ProductProvider provider}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _commonHeading(text: "Product Name"),
      SizedBox(height: 8),
      commonTextField(
        controller: provider.tetName,
        enabled: true,
        hintText: "Product name",
      ),
      SizedBox(height: 15),
      _commonHeading(text: "Product Description"),
      SizedBox(height: 8),
      commonTextField(
        controller: provider.tetDesc,
        enabled: true,
        hintText:
            "The Paraiso blouse embodies effortless warm-weather dressing. The unique cotton eyelet is enhanced by the volume of the tiers, which end in a high-low hem. The puff sleeves add just a touch of sweetness. Shown with the Norte short for a tonal look.",
      ),

      SizedBox(height: 15),

      Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commonHeading(text: "Qty"),
                SizedBox(height: 8),
                commonTextField(
                  hintText: "1",
                  enabled: false,
                  controller: provider.tetQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              spacing: 0,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commonHeading(text: "Price"),
                SizedBox(height: 8),
                commonTextField(
                  controller: provider.tetPrice,
                  hintText: "\$25",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [PriceInputFormatter()],
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget commonOtherVariants({
  required ProductProvider provider,
  required ProductDetailsModel products,
}) {
  return Column(
    spacing: 0,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _commonHeading(text: "Variants"),
      SizedBox(height: 8),
      commonListViewBuilder(
        shrinkWrap: true,
        padding: EdgeInsetsGeometry.zero,
        items: products.options ?? [],
        itemBuilder: (context, index, data1) {
          var data = products.options?[index];
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                decoration: commonBoxDecoration(borderColor: colorBorder),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: commonListTile(
                  textColor: themeProvider.isDark ? Colors.white : colorLogo,
                  contentPadding: EdgeInsetsGeometry.zero,
                  leadingIcon: commonAssetImage(
                    icDot,
                    width: 24,
                    height: 24,
                    color: Colors.grey,
                  ),
                  subtitleView: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              decoration: commonBoxDecoration(
                                color: colorBorder.withValues(alpha: 0.1),
                                borderRadius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 10,
                                ),
                                child: commonText(
                                  text: data?.values?.join(", ") ?? "",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  title: data?.name ?? '',
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

Widget commonVariants({
  required ProductProvider provider,
  required ProductDetailsModel products,
}) {
  return Column(
    spacing: 0,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _commonHeading(text: "Variants"),
      SizedBox(height: 8),
      commonListViewBuilder(
        shrinkWrap: true,
        padding: EdgeInsetsGeometry.zero,
        items: products.variants ?? [],
        itemBuilder: (context, index, data1) {
          var data = products.variants?[index];
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                decoration: commonBoxDecoration(borderColor: colorBorder),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: commonListTile(
                  textColor: themeProvider.isDark ? Colors.white : colorLogo,
                  contentPadding: EdgeInsetsGeometry.zero,
                  leadingIcon: commonNetworkImage(data?.imageUrl ?? ''),
                  subtitleView: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: commonBoxDecoration(
                              color: colorBorder.withValues(alpha: 0.1),
                              borderRadius: 5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 10,
                              ),
                              child: commonText(
                                text: '$rupeeIcon${data?.price}',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          Container(
                            decoration: commonBoxDecoration(
                              color: colorBorder.withValues(alpha: 0.1),
                              borderRadius: 5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 10,
                              ),
                              child: commonText(
                                text: 'Qty - ${data?.inventoryQuantity}',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  title: data?.title ?? '',
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

Widget updateVariant({
  required ProductProvider provider,
  required List<Variants> variants,
}) {
  return Column(
    spacing: 0,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _commonHeading(text: "Variants"),
      SizedBox(height: 8),
      commonListViewBuilder(
        shrinkWrap: true,
        padding: EdgeInsetsGeometry.zero,
        items: variants,
        itemBuilder: (context, index, data1) {
          var data = variants[index];
          final qtyCtrl = provider.qtyControllers[data.id];
          final priceCtrl = provider.priceControllers[data.id];

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                decoration: commonBoxDecoration(borderColor: colorBorder),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: commonListTile(
                  textColor: themeProvider.isDark ? Colors.white : colorLogo,
                  contentPadding: EdgeInsetsGeometry.zero,
                  leadingIcon: commonNetworkImage(data.imageUrl ?? ''),
                  subtitleView: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          commonText(text: "Price"),
                          SizedBox(width: 4),
                          Expanded(
                            child: customTextField(
                              controller: priceCtrl ?? TextEditingController(),
                              hintText: priceCtrl?.text ?? '',
                            ),
                          ),
                          SizedBox(width: 16),
                          commonText(text: "Qty"),
                          SizedBox(width: 4),
                          Expanded(
                            child: customTextField(
                              controller: qtyCtrl ?? TextEditingController(),
                              hintText: qtyCtrl?.text ?? '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  title: data.title ?? '',
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

Widget customTextField({
  required TextEditingController controller,
  String hintText = '',
}) {
  return TextField(
    style: commonTextStyle(),
    controller: controller,
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      hintText: hintText,
      isDense: true, // removes default vertical padding
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // control padding manually
      filled: true,
      fillColor: colorBorder.withValues(alpha: 0.1), // background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // rounded corners
        borderSide: BorderSide.none, // remove default border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey, // border color when focused
          width: 1.5,
        ),
      ),
    ),
  );
}

Widget _commonHeading({String? text}) {
  return commonText(
    text: text ?? "Product Description",
    fontWeight: FontWeight.w600,
  );
}
