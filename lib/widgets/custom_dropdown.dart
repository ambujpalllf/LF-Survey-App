import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final dynamic initialValue;
  final String labelKey;
  final void Function(dynamic)? onChanged;
  final String? hintText;
  final String? lableText;
  final String? errorText;
  final int? errorMaxLines;
  final TextStyle? lableStyle;
  final double? borderRadius;
  final bool? filled;
  final Color? fillColor;
  final bool? disabled;
  final double? menuMaxHeight;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    required this.items,
    this.initialValue,
    required this.labelKey,
    this.onChanged,
    this.hintText,
    this.lableText,
    this.errorText,
    this.errorMaxLines,
    this.lableStyle,
    this.borderRadius,
    this.filled,
    this.fillColor,
    this.disabled,
    this.menuMaxHeight,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled ?? false,
      child: DropdownButtonFormField(
        isExpanded: true,
        key: ValueKey(initialValue),
        initialValue: initialValue,
        menuMaxHeight: menuMaxHeight,
        hint: hintText != null ? Text(hintText!, style: AppTextStyle.ts14MB.copyWith(color: Colors.grey)) : null,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item[labelKey]));
        }).toList(),
        onChanged: onChanged,
        iconSize: 28,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          filled: filled,
          fillColor: AppColors.greyLite,
          // labelText: lableText,
          labelStyle: lableStyle ?? AppTextStyle.ts14MB,
          label: RichText(
            text: TextSpan(
              text: lableText ?? '',
              style: lableStyle ?? AppTextStyle.ts14MB,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          errorText: errorText,
          errorMaxLines: errorMaxLines,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            borderSide: BorderSide(color: AppColors.greyLite),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            borderSide: BorderSide(color: AppColors.greyLite),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            borderSide: BorderSide(color: AppColors.greyLite),
          ),
        ),
      ),
    );
  }
}
