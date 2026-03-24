import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/string/string_utils.dart';
import 'package:neeknots/provider/product_provider.dart';
import 'package:provider/provider.dart';

class CommonDateRangePicker {
  static void show({
    required dynamic Function(DateTime, DateTime) onApplyClick,
    required dynamic Function() onCancelClick,
    required BuildContext context,
  }) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    showCustomDateRangePicker(
      context,

      dismissible: true,
      minimumDate: DateTime(2020), // ✅ full past allowed

      maximumDate: DateTime.now(), // ✅ only till today
      startDate: provider.startDate,
      endDate: provider.endDate,
      fontFamily: fontPoppins,

      backgroundColor: Colors.white,
      primaryColor: colorMenu,
      onApplyClick: (start, end) {
        provider.setDateRange(start, end);
        onApplyClick(start, end); // ✅ callback to outside
      },
      onCancelClick: () {
        provider.clearDateRange();
        onCancelClick(); // ✅ callback to outside
      },
    );
  }
}
