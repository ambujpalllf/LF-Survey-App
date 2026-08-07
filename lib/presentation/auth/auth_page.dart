import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/presentation/auth/pams_signin_widget.dart';
import 'package:lf_survey/presentation/auth/register_widget.dart';
import 'package:lf_survey/presentation/auth/sign_in_widget.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/notification_services.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class AuthPage extends StatefulWidget {
  final String userType;
  const AuthPage({super.key, required this.userType});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationServices().requestNotificationPermission();
      checkLoginStatus();
      checkAutoLogout();
    });
  }

  void checkLoginStatus() async {
    final result = await StorageFunction.readBoolData(StorageKey.isLogin);
    final loginType = await StorageFunction.readStringData(StorageKey.loginType);
    if (result == true && loginType != "pams") {
      if (!mounted) return;
      // context.goNamed(AppRoutesName.projectCategoryPage);
      context.pushReplacementNamed(AppRoutesName.projectCategoryPage);
    } else if (result == true && loginType == "pams") {
      if (!mounted) return;
      // context.pushReplacementNamed(AppRoutesName.psCategoryPage);
      context.pushReplacementNamed(AppRoutesName.psPrjPage);
    }
  }

  void checkAutoLogout() async {
    try {
      int? logoutDuration = await StorageFunction.readIntData(StorageKey.tokenExpire);
      int? loginDuration = await StorageFunction.readIntData(StorageKey.loginTime);
      String? loginType = await StorageFunction.readStringData(StorageKey.loginType);
      if (logoutDuration == null || loginDuration == null) return;
      int expiryTime = loginDuration + (logoutDuration * 1000);
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final remainingTime = expiryTime - currentTime;
      if (remainingTime <= 0 && loginType == "pams") {
        await StorageFunction.clearStorage();
        if (!mounted) return;
        context.pushReplacementNamed(AppRoutesName.loginPage, extra: {"userType": "Pams"});
      } else if (remainingTime <= 0 && loginType != "pams") {
        await StorageFunction.clearStorage();
        if (!mounted) return;
        context.pushReplacementNamed(AppRoutesName.loginPage, extra: {"userType": ""});
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackHelper.customToastMsg(
        context: context,
        message: e.toString(),
        bgColor: AppColors.white,
        textColor: AppColors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        centerTile: true,
        titleWidget: Text(widget.userType == "Pams" ? "Pams Survey" : "LF Survey", style: AppTextStyle.ts18MB),
        bgColor: AppColors.white,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 700;
            return CustomScrollView(
              slivers: [
                /// LOGO SECTION
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 0 : size.height * 0.1),
                    child: Column(
                      children: [
                        Image.asset(
                          widget.userType == "Pams" ? AppImages.pamsLogo : AppImages.logoImg,
                          width: isTablet ? size.width * 0.25 : size.width * 0.7,
                        ),
                        const SizedBox(height: 16),
                        Text("Version 4.8.1", style: AppTextStyle.ts18MB),
                      ],
                    ),
                  ),
                ),

                /// TAB SECTION (NO SliverFillRemaining)
                SliverToBoxAdapter(
                  child: Container(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight * 0.7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkColor,
                      borderRadius: isTablet
                          ? const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                          : BorderRadius.zero,
                    ),
                    child: widget.userType == "Pams"
                        ? PamsSigninWidget()
                        : DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  indicatorColor: AppColors.red,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: AppColors.primaryDarkColor,
                                  labelColor: AppColors.red,
                                  unselectedLabelColor: AppColors.white,
                                  tabs: const [
                                    Tab(text: "Sign in"),
                                    Tab(text: "Register"),
                                  ],
                                ),

                                /// FIXED HEIGHT instead of Expanded
                                SizedBox(
                                  height: constraints.maxHeight * 0.6,
                                  child: const TabBarView(children: [SignInWidget(), RegisterWidget()]),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
