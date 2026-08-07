import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomDatePickerFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? calendarhintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool? filled;
  final bool? enabled;
  final Color? fillColor;
  final BoxConstraints? suffixIconConstraints;
  final Function(DateTime)? onDateSelected;
  final TextStyle? lableTextStyle;
  final TextStyle? hintTextStyle;
  final Color? lableTextColor;
  final Color? hintTextColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? borderColor;

  const CustomDatePickerFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.filled,
    this.enabled,
    this.fillColor,
    this.suffixIconConstraints,
    this.lableTextStyle,
    this.hintTextStyle,
    this.hintTextColor,
    this.lableTextColor,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.calendarhintText,
  });

  @override
  State<CustomDatePickerFormField> createState() => _CustomDatePickerFormFieldState();
}

class _CustomDatePickerFormFieldState extends State<CustomDatePickerFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialDate != null) {
      _controller.text = DateFormat('dd MMM yyyy').format(widget.initialDate!);
    }
  }

  void _pickDate() async {
    if (widget.enabled == false) return;
    DateTime initialDate = widget.initialDate ?? DateTime.now();
    DateTime firstDate = widget.firstDate ?? DateTime(1900);
    DateTime lastDate = widget.lastDate ?? DateTime(2100);

    // it is check for when user enter last date before current date
    // then set the initial date  as last date
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    } else if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePickerDialog(
      context: context,
      initialDate: initialDate,
      maxDate: lastDate,
      minDate: firstDate,
      currentDate: DateTime.now(),
      daysOfTheWeekTextStyle: AppTextStyle.ts12MB.copyWith(color: Colors.grey.shade500),
      currentDateDecoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
      currentDateTextStyle: AppTextStyle.ts14RW,
      disabledCellsTextStyle: AppTextStyle.ts16RW.copyWith(color: Colors.grey.shade500),
      enabledCellsTextStyle: AppTextStyle.ts16RB,
      selectedCellDecoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
      selectedCellTextStyle: AppTextStyle.ts16RW,
      slidersColor: AppColors.red,
      leadingDateTextStyle: AppTextStyle.ts16MB.copyWith(color: AppColors.red),
    );

    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controller.text = formattedDate;
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled ?? true,
      onTap: _pickDate,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        suffixIconConstraints: widget.suffixIconConstraints,
        filled: widget.filled,
        fillColor: widget.fillColor,
        labelText: widget.labelText ?? 'Select Date',
        labelStyle:
            widget.lableTextStyle ?? AppTextStyle.ts14MB.copyWith(color: widget.lableTextColor ?? AppColors.black),
        hintText: widget.hintText ?? 'YYYY-MM-DD',
        hintStyle: widget.hintTextStyle ?? AppTextStyle.ts14RB.copyWith(color: widget.hintTextColor ?? AppColors.black),
        prefixIcon: widget.prefixIcon,
        errorText: widget.errorText,
        suffixIcon:
            widget.suffixIcon ??
            Icon(
              Icons.calendar_month_outlined,
              color: (widget.enabled ?? true) ? AppColors.primaryColor : AppColors.greyLite,
            ),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.borderColor ?? AppColors.greyLite)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.borderColor ?? AppColors.black)),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red)),
        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red)),
      ),
    );
  }
}
