import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showLeading;
  final bool isDrawer;
  final bool? centerTile;
  final Color? bgColor;
  final Color? icColor;
  final Color? titleColor;
  final VoidCallback? onPressesed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showLeading = true,
    this.isDrawer = false,
    this.bgColor,
    this.icColor,
    this.titleColor,
    this.onPressesed,
    this.actions,
    this.centerTile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: bgColor ?? AppColors.primaryDarkColor,
      centerTitle: centerTile,
      // systemOverlayStyle: const SystemUiOverlayStyle(
      //   statusBarColor: Colors.white, //  status bar color
      //   statusBarIconBrightness: Brightness.dark, // Android icons
      //   statusBarBrightness: Brightness.dark, // iOS
      // ),
      leading: showLeading
          ? IconButton(
              onPressed:
                  onPressesed ??
                  () {
                    if (isDrawer) {
                      Scaffold.of(context).openDrawer();
                    } else {
                      context.pop(true);
                    }
                  },
              icon: Icon(isDrawer ? Icons.menu : Icons.arrow_back_ios, color: icColor ?? AppColors.red, size: 22),
            )
          : null,
      title: titleWidget ?? Text(title ?? "", style: AppTextStyle.ts18BW.copyWith(color: titleColor)),
      actions: actions,
    );
  }
}
