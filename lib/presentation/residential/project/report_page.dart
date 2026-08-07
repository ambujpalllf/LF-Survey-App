import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Surveyor Summary"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Center(child: Text("No Report Found !", style: AppTextStyle.ts16RB)),
        ),
      ),
    );
  }
}
