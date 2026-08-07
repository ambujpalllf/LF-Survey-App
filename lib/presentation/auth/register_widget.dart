import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/auth/auth_cubit.dart';
import 'package:lf_survey/cubit/auth/auth_state.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _SignWidgetState();
}

class _SignWidgetState extends State<RegisterWidget> {
  bool isLoading = false;
  late FocusNode empFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode mobileFocusNode;

  TextEditingController empCodeC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController mobileC = TextEditingController();

  @override
  void initState() {
    super.initState();
    empFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    mobileFocusNode = FocusNode();
    empFocusNode.addListener(() {
      context.read<AuthCubit>().onEmpRegisterFocusChange(empFocusNode.hasFocus);
    });
    emailFocusNode.addListener(() {
      context.read<AuthCubit>().onEmailFocusChange(emailFocusNode.hasFocus);
    });
    mobileFocusNode.addListener(() {
      context.read<AuthCubit>().onMobFocusChange(mobileFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    empFocusNode.dispose();
    emailFocusNode.dispose();
    mobileFocusNode.dispose();
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
          bool isEmail = false;
          bool isMobile = false;
          bool empFocused = false;
          bool emailFocused = false;
          bool mobFocused = false;
          String? empMsg;
          String? emailMsg;
          String? mobMsg;
          if (state is ValidationState) {
            isEmpCode = state.isEmpCodeEmpty;
            isEmail = state.isEmailEmpty;
            isMobile = state.isMobEmpty;
            empFocused = state.empCodeFocused;
            emailFocused = state.emailFocused;
            mobFocused = state.mobFocused;
            empMsg = state.empCodeMessage;
            emailMsg = state.emailMessage;
            mobMsg = state.mobMessage;
          }
          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    TextFormField(
                      controller: empCodeC,
                      focusNode: empFocusNode,
                      cursorColor: AppColors.white,
                      style: AppTextStyle.ts14RW,
                      onChanged: (value) {
                        authCubit.onEmpCodeRegisterChanged(value);
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(emailFocusNode);
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
                      focusNode: emailFocusNode,
                      cursorColor: AppColors.white,
                      controller: emailC,
                      style: AppTextStyle.ts14RW,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        authCubit.onEmailChanged(value);
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(mobileFocusNode);
                      },
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: AppTextStyle.ts14RW,
                        suffixIcon: isEmail ? Icon(Icons.error, color: AppColors.red) : null,
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.black)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryBlack)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryWhite)),
                      ),
                    ),
                    if (emailMsg != null && isEmail && emailFocused)
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
                              child: Text(emailMsg, style: AppTextStyle.ts12RW),
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
                      focusNode: mobileFocusNode,
                      cursorColor: AppColors.white,
                      style: AppTextStyle.ts14RW,
                      controller: mobileC,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        authCubit.onMobChanged(value);
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Mobile Number",
                        labelStyle: AppTextStyle.ts14RW,
                        suffixIcon: isMobile ? Icon(Icons.error, color: AppColors.red) : null,
                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.black)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryBlack)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryWhite)),
                      ),
                    ),
                    if (mobMsg != null && isMobile && mobFocused)
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
                              child: Text(mobMsg, style: AppTextStyle.ts12RW),
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
                        text: "REGISTER",
                        onPressed: () {
                          final isValid = authCubit.validateRegistrationFields(
                            empCode: empCodeC.text,
                            email: emailC.text,
                            mobile: mobileC.text,
                          );
                          if (!isValid) return;
                          authCubit.registerUser(empCode: empCodeC.text, email: emailC.text, mobileNo: mobileC.text);
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
          if (state is ErrorState) {
            isLoading = false;
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
              toastGravity: ToastGravity.CENTER,
            );
          } else if (state is LoadingState) {
            isLoading = true;
          } else if (state is SuccessState) {
            empCodeC.clear();
            emailC.clear();
            mobileC.clear();
            isLoading = false;
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
              toastGravity: ToastGravity.CENTER,
            );
          } else if (state is LoadingState) {
            isLoading = true;
          }
        },
      ),
    );
  }
}
