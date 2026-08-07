import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<dynamic>? initialValues;
  final String labelKey;
  final void Function(List<dynamic>)? onChanged;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final int? errorMaxLines;
  final TextStyle? labelStyle;
  final double? borderRadius;
  final bool? filled;
  final Color? fillColor;
  final bool isRequired;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    required this.labelKey,
    this.initialValues,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.labelStyle,
    this.errorText,
    this.errorMaxLines,
    this.borderRadius,
    this.filled,
    this.fillColor,
    this.isRequired = false,
  });

  @override
  State<CustomMultiSelectDropdown> createState() => _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  late List<dynamic> _selectedValues = widget.initialValues ?? [];

  void _openMultiSelectDialog() async {
    final List<dynamic>? results = await showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        List<dynamic> tempSelected = List.from(_selectedValues);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
              title: Text(widget.labelText ?? "Select Options"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: widget.items.map((item) {
                    final isSelected = tempSelected.contains(item);

                    return CheckboxListTile(
                      value: isSelected,
                      visualDensity: VisualDensity.compact,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(item[widget.labelKey]),
                      activeColor: AppColors.red,
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("CLEAR ALL", style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryDarkColor)),
                  onPressed: () {
                    Navigator.pop(context, []); // return empty list
                  },
                ),
                TextButton(
                  child: Text("CANCEL", style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryDarkColor)),
                  onPressed: () => Navigator.pop(context, _selectedValues),
                ),
                TextButton(
                  child: Text("OK", style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryDarkColor)),
                  onPressed: () => Navigator.pop(context, tempSelected),
                ),
              ],
            );
          },
        );
      },
    );

    if (results != null) {
      setState(() {
        _selectedValues = results;
      });
      widget.onChanged?.call(_selectedValues);
    }
  }

  void _removeSelectedItem(dynamic item) {
    setState(() {
      _selectedValues.remove(item);
    });
    widget.onChanged?.call(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      borderSide: BorderSide(color: AppColors.greyLite),
    );
    final errorborder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      borderSide: BorderSide(color: AppColors.red),
    );
    return InkWell(
      onTap: _openMultiSelectDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          filled: widget.filled ?? false,
          fillColor: widget.fillColor ?? AppColors.greyLite,
          // labelText: widget.labelText,
          // labelStyle: widget.labelStyle ?? AppTextStyle.ts14MB,
          errorText: widget.errorText,
          errorMaxLines: widget.errorMaxLines,
          label: RichText(
            text: TextSpan(
              text: widget.labelText ?? '',
              style: widget.labelStyle ?? AppTextStyle.ts14MB,
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: errorborder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _selectedValues.isEmpty
                  ? Text(widget.hintText ?? "Select options", style: AppTextStyle.ts14MB.copyWith(color: Colors.grey))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: _selectedValues.map((item) {
                        return Chip(
                          label: Text(item[widget.labelKey]),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSelectedItem(item),
                          backgroundColor: Colors.blue.shade50,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
            ),

            const Icon(Icons.arrow_drop_down, size: 28, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
