import 'package:flutter/material.dart';
import 'package:neeknots/core/component/component.dart';
import 'package:neeknots/provider/login_provider.dart';
import 'package:provider/provider.dart';

import '../core/component/common_intl_phone_field.dart';
import '../core/image/image_utils.dart';
import '../core/validation/validation.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  void initState() {
    super.initState();

    // Page load hone ke baad provider access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LoginProvider>();
      provider.resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formContactUS = GlobalKey<FormState>();
    return commonScaffold(
      appBar: commonAppBar(
        title: "Contact Us",
        centerTitle: true,
        context: context,
      ),
      body: Consumer<LoginProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Form(
                key: formContactUS,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16),

                  children: [
                    SizedBox(height: 20),
                    commonText(
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      text:
                          "Have a question or feedback? Fill out the form below and our team will get back to you as soon as possible.",
                    ),
                    SizedBox(height: 20),

                    Column(
                      spacing: 12,
                      children: [
                        _commonView(
                          title: "Name",
                          controller: provider.tetFullName,
                          validator: (value) => emptyError(
                            value,
                            errorMessage: "Name is required",
                          ),
                        ),
                        _commonView(
                          title: "Email",

                          prefixIcon: icEmail,
                          controller: provider.tetEmail,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: commonText(
                            text: "Phone Number",
                            fontWeight: FontWeight.w400,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        CommonIntlPhoneField(
                          phoneController: provider.tetPhone,
                          onCountryChanged: (value) {
                            final dialCode = "+${value.dialCode}";

                            provider.tetCountryCodeController.text = dialCode;
                          },
                          onChanged: (phone) {
                            provider.tetCountryCodeController.text =
                                phone.countryCode;
                          },
                        ),

                        _commonView(
                          controller: provider.tetMessage,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Message is required";
                            }
                            if (value.length < 100) {
                              return "Message must be at least 100 characters long";
                            }
                            return null;
                          },
                          maxLine: 8,
                          prefixIcon: null,
                          title: "Message",
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    commonButton(
                      text: "Submit",
                      onPressed: () {
                        if (formContactUS.currentState?.validate() == true) {
                          String fullNumber =
                              provider.tetCountryCodeController.text +
                              provider.tetPhone.text;
                          provider.addContactUsData(
                            email: provider.tetEmail.text,
                            mobile: fullNumber,
                            message: provider.tetMessage.text,
                            name: provider.tetFullName.text,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              provider.isLoading ? showLoaderList() : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Widget _commonView({
    int? maxLine,
    String? title,
    String? prefixIcon,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonText(text: title ?? "Name", fontWeight: FontWeight.w400),
        commonTextField(
          keyboardType: keyboardType ?? TextInputType.name,
          validator: validator,

          hintText: '',

          contentPadding: prefixIcon?.isNotEmpty == false
              ? EdgeInsetsGeometry.zero
              : EdgeInsets.symmetric(horizontal: 16, vertical: 16),

          maxLines: maxLine ?? 1,
          controller: controller,
        ),
      ],
    );
  }
}
