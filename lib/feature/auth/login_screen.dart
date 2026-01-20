import 'package:email_otp/email_otp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/core/image/image_utils.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import 'login_widget.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    final formLoginKey = GlobalKey<FormState>();
    return commonScaffold(
      body: Consumer2<ThemeProvider, LoginProvider>(
        builder: (context, themeProvider, provider, child) {
          return commonAppBackground(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Consumer<LoginProvider>(
                      builder: (context, provider, child) {
                        return commonPopScope(
                          onBack: () {
                            provider.resetState();
                          },
                          child: Form(
                            key: formLoginKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 20),
                                Align(
                                  alignment: AlignmentGeometry.center,
                                  child: commonAssetImage(
                                    icAppLogo,
                                    height: 72,

                                    width: size.width * 0.7,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.07),
                                commonHeadingText(
                                  text: "Welcome back 👋 ",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: themeProvider.isDark
                                      ? Colors.white
                                      : colorLogo,
                                ),
                                const SizedBox(height: 2),
                                commonDescriptionText(
                                  text: "Please auth to continue  ",
                                ),
                                const SizedBox(height: 20),

                              commonLoginView(
                                  provider: provider,
                                  onPressSignUp: TapGestureRecognizer()
                                    ..onTap = () {
                                      hideKeyboard(context);
                                      context
                                          .read<LoginProvider>()
                                          .resetState();
                                      navigatorKey.currentState?.pushNamed(
                                        RouteName.signupScreen,
                                      );
                                    },


                                  onPressed: () async {
                                  /*  EmailSender emailSender = EmailSender();
                                    var response = await emailsender.sendOtp("pathansameerahmed@gmail.com", 123456);*/

                                    hideKeyboard(context);

                                    if (formLoginKey.currentState?.validate() ==
                                        true) {
                                      if (provider.tetPhone.text
                                          .trim()
                                          .isEmpty) {
                                        return;
                                      }
                                      try {
                                        final userData = await provider.login(
                                          countryCode: provider
                                              .tetCountryCodeController
                                              .text,
                                          email: provider.tetEmail.text.trim(),
                                          mobile: provider.tetPhone.text,
                                        );

                                        navigatorKey.currentState?.pushNamed(
                                          RouteName.otpVerificationScreen,
                                          arguments: userData,
                                        );
                                      } catch (e) {

                                        String errorMessage = e
                                            .toString()
                                            .split(": ")
                                            .last;

                                        showCommonDialog(
                                          title: "Error",
                                          context: navigatorKey.currentContext!,
                                          confirmText: "Close",
                                          showCancel: false,
                                          content: errorMessage,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                provider.isLoading ? showLoaderList() : SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}
