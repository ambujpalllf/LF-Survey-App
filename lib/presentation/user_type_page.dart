import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/cubit/user_cubit/user_cubit.dart';
import 'package:lf_survey/cubit/user_cubit/user_state.dart';
import 'package:lf_survey/routes/app_routes_name.dart';

class UserTypePage extends StatefulWidget {
  const UserTypePage({super.key});

  @override
  State<UserTypePage> createState() => _UserTypePageState();
}

class _UserTypePageState extends State<UserTypePage> {
  String? userType;
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserCubit>().checkLogin();
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is LoginState) {
            userType = state.loginType;
          } else if (state is LogoutState) {
            userType = null;
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: AppDimens.hvPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      visualDensity: const VisualDensity(vertical: -4),
                      padding: EdgeInsets.zero,
                      onPressed: userType == null
                          ? null
                          : () {
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
                                        child: Text(
                                          "CANCEL",
                                          style: AppTextStyle.ts16BB.copyWith(color: AppColors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          context.pop();
                                          context.read<UserCubit>().logout();
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
                      icon: Icon(Icons.logout_rounded, color: userType == null ? Colors.grey.shade300 : AppColors.red),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (state is LoginState && state.loginType == "pams") {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(),
                                title: Text("Login Info", style: AppTextStyle.ts18BB),
                                content: Text(
                                  "You're currently logged in. Please log out first to access LF Survey.",
                                  style: AppTextStyle.ts14RB,
                                ),
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
                                      context.read<UserCubit>().logout();
                                    },
                                    child: Text(
                                      "Logout",
                                      style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        } else {
                          context.pushNamed(AppRoutesName.loginPage, extra: {"userType": "LF Survey"});
                        }
                      },
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 25,
                            children: [
                              Image.asset(AppImages.residentialImg, height: height * 0.3, fit: BoxFit.fill),
                              Text("LF Survey", style: AppTextStyle.ts18BB, textAlign: TextAlign.center),
                            ],
                          ),
                          if (userType == "pams") Positioned.fill(child: Container(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (state is LoginState && state.loginType == "lfSurvey") {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(),
                                title: Text("Login Info", style: AppTextStyle.ts18BB),
                                content: Text(
                                  "You're currently logged in. Please log out first to access PAMS Survey.",
                                  style: AppTextStyle.ts14RB,
                                ),
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
                                      context.read<UserCubit>().logout();
                                    },
                                    child: Text(
                                      "Logout",
                                      style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        } else {
                          context.pushNamed(AppRoutesName.loginPage, extra: {"userType": "Pams"});
                        }
                      },
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 25,
                            children: [
                              Image.asset(AppImages.pamsLogo, height: height * 0.2),
                              Text("PAMS Survey", style: AppTextStyle.ts18BB, textAlign: TextAlign.center),
                            ],
                          ),
                          if (userType != null && userType != "pams")
                            Positioned.fill(child: Container(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
