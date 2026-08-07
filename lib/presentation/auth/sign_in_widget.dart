import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/auth/auth_cubit.dart';
import 'package:lf_survey/cubit/auth/auth_state.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignWidgetState();
}

class _SignWidgetState extends State<SignInWidget> {
  bool empFocused = false;
  bool isShowPass = true;
  bool isLoading = false;
  TextEditingController empCodeC = TextEditingController();
  TextEditingController passwwordC = TextEditingController();

  late FocusNode empFocusNode;
  late FocusNode passFocusNode;

  @override
  void initState() {
    super.initState();
    empFocusNode = FocusNode();
    passFocusNode = FocusNode();

    empFocusNode.addListener(() {
      context.read<AuthCubit>().onEmpFocusChange(empFocusNode.hasFocus);
    });
    passFocusNode.addListener(() {
      context.read<AuthCubit>().onPassFocusChange(passFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    empFocusNode.dispose();
    passFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final AuthCubit authCubit = context.read<AuthCubit>();
    return Padding(
      padding: AppDimens.hvPadding,
      child: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          bool isEmpCode = false;
          bool isPass = false;
          bool passFocused = false;
          String? empMsg;
          String? passMsg;
          if (state is ValidationState) {
            isEmpCode = state.isEmpCodeEmpty;
            isPass = state.isPassEmpty;
            empFocused = state.empCodeFocused;
            passFocused = state.passFocused;
            empMsg = state.empCodeMessage;
            passMsg = state.passMessage;
            isLoading = false;
          } else if (state is TogglePasswordState) {
            isShowPass = state.isShow;
            isLoading = false;
          }
          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    TextFormField(
                      focusNode: empFocusNode,
                      controller: empCodeC,
                      cursorColor: AppColors.secondaryWhite,
                      style: AppTextStyle.ts14RW,
                      onChanged: (value) {
                        authCubit.onEmpCodeChanged(value);
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passFocusNode);
                      },
                      decoration: InputDecoration(
                        labelText: "Employee Code",
                        labelStyle: AppTextStyle.ts14RW,
                        suffixIcon: isEmpCode ? Icon(Icons.error, color: AppColors.red) : null,
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.black)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryBlack)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryWhite)),
                      ),
                    ),
                    if (empMsg != null && isEmpCode && empFocused)
                      Align(
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
                              child: Text(empMsg, style: AppTextStyle.ts12RW),
                            ),
                            Positioned(
                              top: -20,
                              right: 5,
                              child: Icon(Icons.arrow_drop_up, color: AppColors.red, size: 35),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: AppDimens.spacingMD),
                    TextFormField(
                      obscureText: isShowPass,
                      focusNode: passFocusNode,
                      controller: passwwordC,
                      cursorColor: AppColors.secondaryWhite,
                      style: AppTextStyle.ts14RW,
                      onChanged: (value) {
                        authCubit.onPasswordChanged(value);
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: AppTextStyle.ts14RW,
                        suffix: InkWell(
                          onTap: () {
                            authCubit.togglePassword(showPass: isShowPass);
                          },
                          child: Icon(
                            isShowPass ? Icons.visibility_rounded : Icons.visibility_off,
                            color: AppColors.white,
                          ),
                        ),
                        suffixIcon: isPass ? Icon(Icons.error, color: AppColors.red) : null,
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.black)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryBlack)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryWhite)),
                      ),
                    ),
                    if (passMsg != null && isPass && passFocused)
                      Align(
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
                              child: Text(passMsg, style: AppTextStyle.ts12RW),
                            ),
                            Positioned(
                              top: -20,
                              right: 5,
                              child: Icon(Icons.arrow_drop_up, color: AppColors.red, size: 35),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: height * 0.02),
                    SizedBox(
                      width: width,
                      child: CustomElevatedButton(
                        borderRadius: 0.0,
                        backgroundColor: AppColors.red,
                        text: "SIGN IN",
                        onPressed: () {
                          final result = authCubit.validateFields(empCode: empCodeC.text, password: passwwordC.text);
                          if (result) {
                            authCubit.loginUser(empCode: empCodeC.text, password: passwwordC.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return isLoading
                        ? Center(child: CircularProgressIndicator(color: AppColors.red))
                        : SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
        listener: (context, state) {
          if (state is LoginState) {
            // context.goNamed(AppRoutesName.projectCategoryPage);
            context.pushReplacementNamed(AppRoutesName.projectCategoryPage);
            isLoading = false;
          } else if (state is LoadingState) {
            isLoading = true;
          } else if (state is ErrorState) {
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
              toastGravity: ToastGravity.CENTER,
            );
            isLoading = false;
          }
        },
      ),
    );
  }
}
