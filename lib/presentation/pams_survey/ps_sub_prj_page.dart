import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class PsSubPrjPage extends StatefulWidget {
  const PsSubPrjPage({super.key});

  @override
  State<PsSubPrjPage> createState() => _PsSubPrjPageState();
}

class _PsSubPrjPageState extends State<PsSubPrjPage> {
  TextEditingController searchC = TextEditingController();
  FocusNode searchFN = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    searchFN.addListener(() {
      setState(() {
        isFocused = searchFN.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(titleWidget: Text("Sub-Projects (0)", style: AppTextStyle.ts18BW)),
      body: Padding(
        padding: AppDimens.hvPadding,
        child: Column(
          spacing: 20,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 3)),
                ],
              ),
              child: CustomTextformField(
                focusNode: searchFN,
                controller: searchC,
                filled: true,
                fillColor: AppColors.white,
                hintText: isFocused ? "Project Id, Project Name, Builder Name, Road Name" : null,
                hintTextColor: Colors.grey,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: isFocused
                    ? IconButton(
                        onPressed: () {
                          searchC.clear();
                          searchFN.unfocus();
                        },
                        icon: Icon(Icons.close, color: Colors.grey),
                      )
                    : null,
                onChanged: (value) {},
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {},
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text("Sub Project Name", style: AppTextStyle.ts14RB)],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
