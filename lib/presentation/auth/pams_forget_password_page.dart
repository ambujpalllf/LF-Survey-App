import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/auth/ps_forget_cubit.dart';
import 'package:lf_survey/cubit/auth/ps_forget_pass.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';

class PamsForgetPasswordPage extends StatefulWidget {
  const PamsForgetPasswordPage({super.key});

  @override
  State<PamsForgetPasswordPage> createState() => _PamsForgetPasswordPageState();
}

class _PamsForgetPasswordPageState extends State<PamsForgetPasswordPage> {
  String? emailError;
  String? passwordError;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => PsForgetCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          bgColor: Colors.white,
          titleColor: Colors.grey,
          title: "Forget Password",
          centerTile: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppImages.pamsLogo, width: size.width * 0.9),
                  const SizedBox(height: 16),
                  Text("Version 4.8.1", style: AppTextStyle.ts18MB),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.0),
                color: AppColors.primaryDarkColor,
                child: BlocConsumer<PsForgetCubit, PsForgetPassState>(
                  listener: (context, state) {
                    if (state is SuccessState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                        toastGravity: ToastGravity.CENTER,
                      );
                    } else if (state is ErrorState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                        toastGravity: ToastGravity.CENTER,
                      );
                    } else if (state is ValidationState) {
                      emailError = state.emailEr;
                      passwordError = state.passEr;
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        spacing: 16,
                        children: [
                          SizedBox(height: 10),
                          CustomTextField(
                            controller: emailC,
                            labelText: "Email",
                            lableTextColor: Colors.white,
                            cursorColor: Colors.white,
                            borderColor: Colors.black,
                            style: AppTextStyle.ts14RW,
                            errorText: emailError,
                            onChanged: (value) =>
                                context.read<PsForgetCubit>().fieldsValidation(email: value, password: passC.text),
                          ),
                          CustomTextField(
                            controller: passC,
                            labelText: "Password",
                            errorText: passwordError,
                            lableTextColor: Colors.white,
                            cursorColor: Colors.white,
                            style: AppTextStyle.ts14RW,
                            borderColor: Colors.black,
                            onChanged: (value) =>
                                context.read<PsForgetCubit>().fieldsValidation(email: emailC.text, password: value),
                          ),
                          SizedBox(height: 10),
                          CustomElevatedButton(
                            isLoading: state is LoadingState,
                            text: "Reset Password",
                            backgroundColor: AppColors.red,
                            onPressed: () {
                              context.read<PsForgetCubit>().resetPassword(email: emailC.text, password: passC.text);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
