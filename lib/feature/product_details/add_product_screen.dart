import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:provider/provider.dart';

import '../../core/component/common_dropdown.dart';
import '../../core/component/price_input_format.dart';
import '../../core/image_picker/image_pick_and_crop_widget.dart';
import '../../provider/product_provider.dart';
import '../../provider/theme_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    return commonScaffold(
      appBar: commonAppBar(
        title: "ADD NEW PRODUCT",
        context: context,
        centerTitle: true,
      ),
      body: commonPopScope(
        onBack: () {
          provider.reset();
        },
        child: commonAppBackground(
          child: ListView(
            padding: EdgeInsets.all(16),

            children: [
              Column(
                spacing: 24,
                children: [
                  uploadImageView(),
                  commonInputBoxView(),
                  commonInputBoxView(title: "Description", maxLine: 5),

                  Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: commonInputBoxView(
                          title: "Quantity",
                          keyboardType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      Expanded(
                        child: commonInputBoxView(
                          title: "Price",
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatter: [PriceInputFormatter()],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: dropDownView(
                          title: "Status",
                          selectedValue: provider.addProductStatus,
                          items: ["Active", "Draft"],
                          enabled: true,
                          onChanged: (value) {
                            provider.setStatus(value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: dropDownView(
                          title: "Category",
                          selectedValue: provider.category,
                          items: [
                            "Category 1",
                            "Category 2",
                            "Category 3",
                            "Category 4",
                            "Category 5",
                          ],
                          enabled: true,
                          onChanged: (value) {
                            provider.setCategory(value!);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2),
                  commonButton(
                    width: MediaQuery.sizeOf(context).width,
                    text: "Create Product",
                    onPressed: () {
                      provider.reset();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 9),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonInputBoxView({
    List<TextInputFormatter>? inputFormatter,
    String? title,
    int? maxLine,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        commonText(
          text: title ?? "Title",
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        commonTextField(
          keyboardType: keyboardType,
          inputFormatters: inputFormatter,

          hintText: '',
          maxLines: maxLine ?? 1,
        ),
      ],
    );
  }

  Widget uploadImageView({String? title, int? maxLine}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(
              text: "Product Images",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            provider.imageFiles.isEmpty
                ? Container(
                    height: 200,
                    decoration: commonBoxDecoration(
                      borderColor: colorBorder,
                      borderRadius: 12,
                    ),
                    child: Center(
                      child: commonInkWell(
                        onTap: () async {
                          final path = await CommonImagePicker.pickImage(
                            context,
                            themeProvider,
                          );
                          if (path != null) {
                            provider.addImage(File(path));
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            commonAssetImage(
                              icUpload,
                              width: 50,
                              height: 50,
                              color: themeProvider.isDark
                                  ? CupertinoColors.white
                                  : Colors.black,
                            ),
                            commonText(
                              text: "Upload Images",
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            provider.imageFiles.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // ek row me kitni images
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: provider.imageFiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.imageFiles.length) {
                        // Add button
                        return commonInkWell(
                          onTap: () async {
                            final path = await CommonImagePicker.pickImage(
                              context,
                              themeProvider,
                            );
                            if (path != null) {
                              provider.addImage(File(path));
                            }
                          },
                          child: Container(
                            decoration: commonBoxDecoration(
                              borderColor: colorBorder,
                              borderRadius: 8,
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  commonAssetImage(
                                    icUpload,
                                    width: 30,
                                    height: 30,
                                    color: themeProvider.isDark
                                        ? CupertinoColors.white
                                        : Colors.black,
                                  ),
                                  commonText(
                                    text: "Upload Images",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  /*   Icon(Icons.add,
                                color: themeProvider.isDark
                                    ? CupertinoColors.white
                                    : Colors.black,
                                size: 30),*/
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              provider.imageFiles[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: commonInkWell(
                              onTap: () {
                                provider.removeImage(index);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: commonBoxDecoration(
                                  color: themeProvider.isDark
                                      ? CupertinoColors.black
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget dropDownView({
    required String title,
    required String selectedValue,
    required List<String> items,
    required bool enabled,
    required Function(String?) onChanged,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonText(text: title, fontSize: 14, fontWeight: FontWeight.w600),
        CommonDropdown(
          initialValue: selectedValue,
          items: items,
          enabled: enabled,
          onChanged: enabled ? onChanged : (value) {},
        ),
      ],
    );
  }
}
