import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/routes/app_routes_name.dart';

class PsCategoryPage extends StatelessWidget {
  const PsCategoryPage({super.key});
  final List<Map<String, dynamic>> optionsList = const [
    {
      "title": "Construction Monitoring",
      "icons": "assets/images/construction_monitoring.png",
      "routes": "/constMPrjPage",
    },
    {"title": "Pams Survey", "icons": "assets/images/pam_logo.png", "routes": "/psPrjPage"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: AppDimens.spacingMD,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: AppDimens.spacingMD,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(),
                                title: Text("Logout", style: AppTextStyle.ts18BB),
                                content: Text("Are you sure want to logout ?", style: AppTextStyle.ts14RB),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: Text("CANCEL", style: AppTextStyle.ts16BB.copyWith(color: AppColors.red)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      context.pop();
                                      // context.go(AppRoutesName.loginPage, extra: {"userType": "Pams"});

                                      context.pushReplacementNamed(
                                        AppRoutesName.loginPage,
                                        extra: {"userType": "Pams"},
                                      );
                                      await FlutterForegroundTask.stopService();
                                      await StorageFunction.clearStorage();
                                    },
                                    child: Text(
                                      "OK",
                                      style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(Icons.logout_sharp, color: AppColors.red),
                      ),
                      Text("Select Project Type", style: AppTextStyle.ts18BB.copyWith(color: AppColors.red)),
                    ],
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     context.pushNamed(AppRoutesName.projectSearchPage);
                  //   },
                  //   icon: Icon(Icons.search_outlined, color: AppColors.red),
                  // ),
                ],
              ),
              // Expanded(
              //   child: GridView.builder(
              //     itemCount: optionsList.length,
              //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              //       maxCrossAxisExtent: 200,
              //       mainAxisSpacing: 16,
              //       crossAxisSpacing: 16,
              //       childAspectRatio: 0.85, // adjust height/width
              //     ),
              //     itemBuilder: (_, index) {
              //       var item = optionsList[index];
              //       return InkWell(
              //         onTap: () {
              //           if (item["routes"] != "") {
              //             context.pushNamed(item["routes"]);
              //           }
              //         },
              //         child: Container(
              //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Image.asset(item["icons"], height: 60),
              //               const SizedBox(height: 12),
              //               Text(item["title"], style: AppTextStyle.ts16BB, textAlign: TextAlign.center),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutesName.psPrjPage);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.grey.shade50,
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 1.0, spreadRadius: 1.0, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Image.asset(AppImages.ptiLogo, fit: BoxFit.fill),
                        // Text(
                        //   "Project Technical Information",
                        //   style: AppTextStyle.ts20MB.copyWith(fontStyle: FontStyle.italic),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutesName.cmPrjPage);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.grey.shade50,
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 1.0, spreadRadius: 1.0, offset: Offset(1, 2)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Image.asset(AppImages.cmLogo, fit: BoxFit.fill),
                        // Text("Com", style: AppTextStyle.ts20MB.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
