import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomSnackHelper {
  static succesSnackbar({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        content: Text(message, style: AppTextStyle.ts14MW),
      ),
    );
  }

  static errorSnackbar({required BuildContext context, required String message, Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor ?? AppColors.red,
        content: Text(message, style: AppTextStyle.ts14MW),
      ),
    );
  }

  static warningSnackbar({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber.shade400,
        content: Text(message, style: AppTextStyle.ts14MW),
      ),
    );
  }

  static successToast({required String message, ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: AppColors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static errorToast({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color? bgColor,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      backgroundColor: bgColor ?? AppColors.red,
      toastLength: Toast.LENGTH_LONG,
      textColor: textColor ?? Colors.white,
      fontSize: 14.0,
    );
  }

  static customToastMsg({
    required BuildContext context,
    required String message,
    Color? bgColor,
    Color? textColor,
    ToastGravity? toastGravity,
  }) {
    FToast fToast = FToast()..init(context);

    Widget toast = _buildToastWidget(
      icon: Icons.error_outline,
      color: bgColor ?? AppColors.red,
      textColor: textColor ?? AppColors.white,
      message: message,
    );

    fToast.showToast(
      child: toast,
      gravity: toastGravity ?? ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 3),
    );
  }

  static Widget _buildToastWidget({
    required IconData icon,
    required Color color,
    required String message,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(message, style: AppTextStyle.ts14MB.copyWith(color: textColor)),
    );
  }

  static warnningToast({required String message, ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.amber.shade400,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static Widget errorWidget({required String messgage}) {
    return Align(
      alignment: Alignment.topRight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: AppDimens.paddingAllSM,
            decoration: BoxDecoration(
              color: AppColors.black,
              border: Border(top: BorderSide(color: AppColors.red)),
            ),
            child: Text(messgage, style: AppTextStyle.ts12RW),
          ),
          Positioned(top: -20, right: 5, child: Icon(Icons.arrow_drop_up, color: AppColors.red, size: 35)),
        ],
      ),
    );
  }
}
