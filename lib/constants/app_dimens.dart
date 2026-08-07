import 'package:flutter/material.dart';

class AppDimens {
  // Base spacing values
  static const double spacingNone = 0.0;
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // EdgeInsets – all sides
  static const EdgeInsets paddingAllNone = EdgeInsets.all(spacingNone);
  static const EdgeInsets paddingAllXXS = EdgeInsets.all(spacingXXS);
  static const EdgeInsets paddingAllXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingAllSM = EdgeInsets.all(spacingSM);
  static const EdgeInsets paddingAllMD = EdgeInsets.all(spacingMD);
  static const EdgeInsets paddingAllLG = EdgeInsets.all(spacingLG);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets paddingAllXXL = EdgeInsets.all(spacingXXL);
  static const EdgeInsets paddingAllXXXL = EdgeInsets.all(spacingXXXL);

  // EdgeInsets – horizontal & Vertical
  static const EdgeInsets hvPadding = EdgeInsets.symmetric(horizontal: 12, vertical: spacingSM);

  // EdgeInsets – horizontal only
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: spacingXS);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: spacingSM);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: spacingMD);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: spacingLG);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: spacingXL);

  // EdgeInsets – vertical only
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: spacingXS);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: spacingSM);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: spacingMD);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: spacingLG);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: spacingXL);

  //  EdgeInsets – only top/bottom/left/right
  static const EdgeInsets paddingTopSM = EdgeInsets.only(top: spacingSM);
  static const EdgeInsets paddingBottomSM = EdgeInsets.only(bottom: spacingSM);
  static const EdgeInsets paddingLeftSM = EdgeInsets.only(left: spacingSM);
  static const EdgeInsets paddingRightSM = EdgeInsets.only(right: spacingSM);

  static const EdgeInsets paddingTopMD = EdgeInsets.only(top: spacingMD);
  static const EdgeInsets paddingBottomMD = EdgeInsets.only(bottom: spacingMD);
  static const EdgeInsets paddingLeftMD = EdgeInsets.only(left: spacingMD);
  static const EdgeInsets paddingRightMD = EdgeInsets.only(right: spacingMD);
}
