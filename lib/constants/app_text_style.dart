import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_fonts.dart';

class AppTextStyle {
  //  Base text style builder
  static TextStyle _style({
    required String fontFamily,
    required double size,
    required Color color,
    required FontWeight weight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: 0.2,
      height: 1.3,
    );
  }

  //  Internal helpers for each font type
  static TextStyle _light(double size, Color color) =>
      _style(fontFamily: AppFonts.light, size: size, color: color, weight: FontWeight.w300);

  static TextStyle _regular(double size, Color color) =>
      _style(fontFamily: AppFonts.regular, size: size, color: color, weight: FontWeight.w400);

  static TextStyle _medium(double size, Color color) =>
      _style(fontFamily: AppFonts.medium, size: size, color: color, weight: FontWeight.w500);

  static TextStyle _bold(double size, Color color) =>
      _style(fontFamily: AppFonts.bold, size: size, color: color, weight: FontWeight.w700);

  // Light Black
  static TextStyle ts12LB = _light(12, AppColors.black);
  static TextStyle ts14LB = _light(14, AppColors.black);
  static TextStyle ts16LB = _light(16, AppColors.black);
  static TextStyle ts18LB = _light(18, AppColors.black);
  static TextStyle ts20LB = _light(20, AppColors.black);
  static TextStyle ts22LB = _light(22, AppColors.black);
  static TextStyle ts24LB = _light(24, AppColors.black);
  static TextStyle ts26LB = _light(26, AppColors.black);

  // Regular Black
  static TextStyle ts12RB = _regular(12, AppColors.black);
  static TextStyle ts14RB = _regular(14, AppColors.black);
  static TextStyle ts16RB = _regular(16, AppColors.black);
  static TextStyle ts18RB = _regular(18, AppColors.black);
  static TextStyle ts20RB = _regular(20, AppColors.black);
  static TextStyle ts22RB = _regular(22, AppColors.black);
  static TextStyle ts24RB = _regular(24, AppColors.black);
  static TextStyle ts26RB = _regular(26, AppColors.black);

  // Medium Black
  static TextStyle ts12MB = _medium(12, AppColors.black);
  static TextStyle ts14MB = _medium(14, AppColors.black);
  static TextStyle ts16MB = _medium(16, AppColors.black);
  static TextStyle ts18MB = _medium(18, AppColors.black);
  static TextStyle ts20MB = _medium(20, AppColors.black);
  static TextStyle ts22MB = _medium(22, AppColors.black);
  static TextStyle ts24MB = _medium(24, AppColors.black);
  static TextStyle ts26MB = _medium(26, AppColors.black);

  // Bold Black
  static TextStyle ts12BB = _bold(12, AppColors.black);
  static TextStyle ts14BB = _bold(14, AppColors.black);
  static TextStyle ts16BB = _bold(16, AppColors.black);
  static TextStyle ts18BB = _bold(18, AppColors.black);
  static TextStyle ts20BB = _bold(20, AppColors.black);
  static TextStyle ts22BB = _bold(22, AppColors.black);
  static TextStyle ts24BB = _bold(24, AppColors.black);
  static TextStyle ts26BB = _bold(26, AppColors.black);

  // Light White
  static TextStyle ts12LW = _light(12, AppColors.white);
  static TextStyle ts14LW = _light(14, AppColors.white);
  static TextStyle ts16LW = _light(16, AppColors.white);
  static TextStyle ts18LW = _light(18, AppColors.white);
  static TextStyle ts20LW = _light(20, AppColors.white);
  static TextStyle ts22LW = _light(22, AppColors.white);
  static TextStyle ts24LW = _light(24, AppColors.white);
  static TextStyle ts26LW = _light(26, AppColors.white);

  // Regular White
  static TextStyle ts12RW = _regular(12, AppColors.white);
  static TextStyle ts14RW = _regular(14, AppColors.white);
  static TextStyle ts16RW = _regular(16, AppColors.white);
  static TextStyle ts18RW = _regular(18, AppColors.white);
  static TextStyle ts20RW = _regular(20, AppColors.white);
  static TextStyle ts22RW = _regular(22, AppColors.white);
  static TextStyle ts24RW = _regular(24, AppColors.white);
  static TextStyle ts26RW = _regular(26, AppColors.white);

  // Medium White
  static TextStyle ts12MW = _medium(12, AppColors.white);
  static TextStyle ts14MW = _medium(14, AppColors.white);
  static TextStyle ts16MW = _medium(16, AppColors.white);
  static TextStyle ts18MW = _medium(18, AppColors.white);
  static TextStyle ts20MW = _medium(20, AppColors.white);
  static TextStyle ts22MW = _medium(22, AppColors.white);
  static TextStyle ts24MW = _medium(24, AppColors.white);
  static TextStyle ts26MW = _medium(26, AppColors.white);

  // Bold White
  static TextStyle ts12BW = _bold(12, AppColors.white);
  static TextStyle ts14BW = _bold(14, AppColors.white);
  static TextStyle ts16BW = _bold(16, AppColors.white);
  static TextStyle ts18BW = _bold(18, AppColors.white);
  static TextStyle ts20BW = _bold(20, AppColors.white);
  static TextStyle ts22BW = _bold(22, AppColors.white);
  static TextStyle ts24BW = _bold(24, AppColors.white);
  static TextStyle ts26BW = _bold(26, AppColors.white);
}
