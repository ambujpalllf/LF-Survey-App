import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomTextformField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? counterText;
  final String? suffixText;
  final TextStyle? textStyle;
  final TextStyle? lableTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;
  final bool obscureText;
  final bool readOnly;
  final bool? filled;
  final Color? fillColor;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final BoxConstraints? suffixIconConstraints;
  final Function(String)? onChanged;
  final Color? borderColor;
  final Color? lableTextColor;
  final Color? hintTextColor;
  final Color? cursorColor;
  final VoidCallback? onTap;
  final int? maxHintLines;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final double? borderRadius;
  final int? errorMaxLine;

  const CustomTextformField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.counterText,
    this.suffixText,
    this.textStyle,
    this.lableTextStyle,
    this.hintTextStyle,
    this.errorTextStyle,
    this.obscureText = false,
    this.readOnly = false,
    this.filled,
    this.fillColor,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.suffixIconConstraints,
    this.onChanged,
    this.borderColor,
    this.hintTextColor,
    this.lableTextColor,
    this.cursorColor,
    this.onTap,
    this.maxHintLines,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.borderRadius,
    this.errorMaxLine,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: textStyle,
      focusNode: focusNode,
      controller: controller,
      cursorColor: cursorColor,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        suffixIconConstraints: suffixIconConstraints,
        filled: filled,
        fillColor: fillColor,
        labelText: labelText,
        counterText: counterText,
        suffixText: suffixText,
        labelStyle: lableTextStyle ?? AppTextStyle.ts14MB.copyWith(color: lableTextColor ?? AppColors.black),
        hintText: hintText,
        hintMaxLines: maxHintLines,
        hintStyle: hintTextStyle ?? AppTextStyle.ts14RB.copyWith(color: hintTextColor ?? AppColors.black),
        prefixIcon: prefixIcon,
        suffix: suffix,
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorMaxLines: errorMaxLine ?? 1,
        errorStyle: errorTextStyle ?? AppTextStyle.ts14RB.copyWith(color: AppColors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyLite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyLite),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
