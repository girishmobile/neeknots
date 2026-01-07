import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:neeknots/core/color/color_utils.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/feature/auth/signup/signup_form_widget.dart';
import 'package:neeknots/main.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:neeknots/provider/signup_provider.dart';
import 'package:neeknots/provider/theme_provider.dart';
import 'package:neeknots/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/image/image_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  File? _pickedImage;


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    final formSignupKey = GlobalKey<FormState>();
    final signUpProvider = Provider.of<SignupProvider>(context);

    return commonScaffold(
      body: commonAppBackground(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return commonPopScope(
              onBack: () {
                context.read<LoginProvider>().resetState();
              },
              child: Stack(
                children: [
                  SafeArea(
                    child: commonAppBackground(
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
                                key: formSignupKey,
        
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: size.height * 0.08),
                                    Align(
                                      alignment: AlignmentGeometry.center,
                                      child: commonAssetImage(    icAppLogo,
        
        
                                        width: size.width * 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: Column(
                                        children: [
                                          commonHeadingText(
                                            text:
                                                "Create your Ecommerce manager account",
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDark
                                                ? Colors.white
                                                : colorLogo,
                                          ),
                                          const SizedBox(height: 6),
                                          commonDescriptionText(
                                            textAlign: TextAlign.center,
        
                                            text:
                                                "Fill in the details below to register your store and start using the app.",
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
        
                                    const SizedBox(height: 5),
        
                                    SizedBox(height: 20,),
                                    commonSignUpView(
                                      provider: provider,
                                      onPressSignUp: TapGestureRecognizer()
                                        ..onTap = () {
                                          hideKeyboard(context);
                                          context.read<LoginProvider>().resetState();
                                          navigatorKey.currentState?.pushNamed(
                                            RouteName.loginScreen,
                                          );
                                        },
        
                                      onPressed: () async {
                                        hideKeyboard(context);

                                        if (formSignupKey.currentState
                                                ?.validate() ==
                                            true) {
                                          try {
                                            await signUpProvider.signup(
                                              logoUrl:  provider
                                                  .tetLogoUrl
                                                  .text,
                                              countryCode:   provider
                                                  .tetCountryCodeController
                                                  .text,
                                              email: provider.tetEmail.text
                                                  .trim(),
        
                                              storeName: provider
                                                  .tetStoreName
                                                  .text
                                                  .trim(),
                                              websiteUrl: provider
                                                  .tetWebsiteUrl
                                                  .text
                                                  .trim(),
                                              mobile: provider.tetPhone.text,
                                              name: provider.tetFullName.text.trim(),
                                              photo: _pickedImage,
                                            );
        
                                            showCommonDialog(
                                              title: "Success",
                                              onPressed: () {
                                                Timer(
                                                  const Duration(milliseconds: 500),
                                                      () async {
                                                    navigatorKey.currentState
                                                        ?.pushNamedAndRemoveUntil(
                                                      RouteName.loginScreen,
                                                          (Route<dynamic> route) => false,
                                                    );
        
        
                                                    context.read<LoginProvider>().resetState();
                                                  },
                                                );
                                              },
                                              context: navigatorKey.currentContext!,
                                              content:
                                                  "Your account is successfully created. You can access it after 24 hours.",
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
                  ),
                  signUpProvider.isLoading ? showLoaderList() : SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
