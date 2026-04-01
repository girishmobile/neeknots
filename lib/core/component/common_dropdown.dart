import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class CommonDropdown extends StatefulWidget {
  final String? initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double? borderRadius;
  final bool enabled;

  const CommonDropdown({
    super.key,

    required this.items,
    this.initialValue,
    this.enabled = true, // default true
    this.borderRadius = 12.0,
    required this.onChanged,
  });

  @override
  State<CommonDropdown> createState() => _CommonDropdownState();
}

class _CommonDropdownState extends State<CommonDropdown> {
  late ValueNotifier<String?> selectedValue;

  @override
  void initState() {
    super.initState();

    selectedValue = ValueNotifier(
      widget.items.contains(widget.initialValue)
          ? widget.initialValue
          : (widget.items.isNotEmpty ? widget.items.first : null),
    );
  }

  @override
  void dispose() {
    selectedValue.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {

        return DropdownButtonFormField2<String>(
          valueListenable: selectedValue,
          decoration: InputDecoration(
            enabled: widget.enabled,
            border: commonTextFiledBorder(borderRadius: widget.borderRadius),
            enabledBorder: commonTextFiledBorder(borderRadius: widget.borderRadius),
            focusedBorder: commonTextFiledBorder(borderRadius: widget.borderRadius),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 2,
            ),
          ),
          isExpanded: true,
          items: widget.items
              .map(
                (item) => DropdownItem<String>(
              value: item,
              child: commonText(
                text: item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
              .toList(),
          onChanged: widget.enabled ? widget.onChanged : null,
          buttonStyleData: const FormFieldButtonStyleData(
            padding: EdgeInsets.only(right: 8),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              color: provider.isDark ? colorDarkBgColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      },
    );
  }
}
