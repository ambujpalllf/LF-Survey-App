import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextStyle? style;
  final TextStyle? lableTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;
  final bool obscureText;
  final bool readOnly;
  final bool disable;
  final bool? filled;
  final Color? fillColor;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final BoxConstraints? suffixIconConstraints;
  final Function(String)? onChanged;
  final double? borderWidth;
  final Color? borderColor;
  final Color? lableTextColor;
  final Color? hintTextColor;
  final Color? cursorColor;
  final VoidCallback? onTap;
  final int? maxHintLines;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final int? errorMaxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final double? borderRadius;
  final String? counterText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool isRequired;
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.style,
    this.lableTextStyle,
    this.hintTextStyle,
    this.errorTextStyle,
    this.obscureText = false,
    this.readOnly = false,
    this.disable = false,
    this.filled,
    this.fillColor,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.suffixIconConstraints,
    this.onChanged,
    this.borderWidth,
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
    this.counterText,
    this.focusNode,
    this.textInputAction,
    this.errorMaxLines,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      style: style,
      cursorColor: cursorColor ?? AppColors.black,
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
      textInputAction: textInputAction,
      decoration: InputDecoration(
        counterText: counterText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        suffixIconConstraints: suffixIconConstraints,
        filled: filled ?? disable,
        fillColor: fillColor ?? AppColors.greyLite,
        label: RichText(
          text: TextSpan(
            text: labelText ?? '',
            style: lableTextStyle ?? AppTextStyle.ts14MB.copyWith(color: lableTextColor ?? AppColors.black),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        // labelText: labelText,
        // labelStyle: lableTextStyle ?? AppTextStyle.ts14MB.copyWith(color: lableTextColor ?? AppColors.black),
        hintText: hintText,
        hintMaxLines: maxHintLines,
        hintStyle: hintTextStyle ?? AppTextStyle.ts14RB.copyWith(color: hintTextColor ?? AppColors.black),
        prefixIcon: prefixIcon,
        suffix: suffix,
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorMaxLines: errorMaxLines,
        errorStyle: errorTextStyle ?? AppTextStyle.ts14RB.copyWith(color: hintTextColor ?? AppColors.red),
        border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyLite, width: borderWidth ?? 1.0),
        ),
        enabledBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyLite, width: borderWidth ?? 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: borderColor ?? AppColors.black, width: borderWidth ?? 1.0),
        ),
        errorBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: AppColors.red, width: borderWidth ?? 1.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          borderSide: BorderSide(color: AppColors.red, width: borderWidth ?? 1.0),
        ),
      ),
    );
  }
}
