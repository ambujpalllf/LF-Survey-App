import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpPage extends StatefulWidget {
  final String projectType;
  const HelpPage({super.key, required this.projectType});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String dos = "";
  String appVersion = "";
  @override
  void initState() {
    super.initState();
    getUserData();
    getAppVersion();
  }

  void getUserData() async {
    try {
      String? result = await StorageFunction.readStringData(StorageKey.userData);
      if (result != null) {
        Map<String, dynamic> userData = jsonDecode(result);
        List jsonstr = jsonDecode(userData['jsonstr']);
        if (jsonstr.isNotEmpty) {
          Map<String, dynamic> qtrInfo = jsonstr.first;
          String date = widget.projectType == "resi" ? qtrInfo['NEW_PRJ_ENTRY_QTR'] : qtrInfo['COM_NEW_PRJ_ENTRY_QTR'];
          dos = date.split('T').first;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;
      appVersion = version;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Help"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Container(
            color: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Version", style: AppTextStyle.ts18BB),
                    Text(appVersion, style: AppTextStyle.ts16RB.copyWith(color: Colors.grey.shade400)),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: VerticalDivider(color: Colors.grey),
                ),
                Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Current DOS", style: AppTextStyle.ts18BB),
                    Text(dos, style: AppTextStyle.ts16RB.copyWith(color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
