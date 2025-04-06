import 'dart:developer';
import 'dart:ui' as ui;

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  ContactUsState createState() => ContactUsState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(builder: (_) => const ContactUs());
  }
}

class ContactUsState extends State<ContactUs> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        if (context.read<CompanyCubit>().state is CompanyInitial ||
            context.read<CompanyCubit>().state is CompanyFetchFailure) {
          context.read<CompanyCubit>().fetchCompany(
                context,
              );
        } else {
          // print("companyData Fetched already !! ");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'contactUs'),
        showBackButton: true,
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyFetchProgress) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CompanyFetchSuccess) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    UiUtils.translate(context, 'howCanWeHelp'),
                    fontWeight: FontWeight.w700,
                    fontSize: context.font.larger,
                    color: context.color.textColorDark,
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomText(
                    UiUtils.translate(context, 'itLooksLikeYouHasError'),
                    fontSize: context.font.small,
                    color: context.color.textLightColor,
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  customTile(
                    context,
                    title: UiUtils.translate(context, 'callBtnLbl'),
                    onTap: () async {
                      final number1 = state.companyData.companyTel1;
                      final number2 = state.companyData.companyTel2;

                      await UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                          title: 'chooseNumber'.translate(context),
                          showCancleButton: false,
                          barrierDismissable: true,
                          acceptTextColor: context.color.buttonColor,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: CustomText(
                                  number1.toString(),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {
                                  await launchUrl(Uri.parse('tel:$number1'));
                                },
                              ),
                              ListTile(
                                title: CustomText(
                                  number2.toString(),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {
                                  await launchUrl(Uri.parse('tel:$number2'));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    svgImagePath: AppIcons.call,
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  customTile(
                    context,
                    title: UiUtils.translate(context, 'companyEmailLbl'),
                    onTap: () {
                      final email = state.companyData.companyEmail;
                      showEmailDialoge(email);
                    },
                    svgImagePath: AppIcons.message,
                  ),
                ],
              ),
            );
          } else if (state is CompanyFetchFailure) {
            log('error iii ${state.errmsg}');
            return Center(
              child: CustomText(state.errmsg),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  showEmailDialoge(email) {
    Navigator.push(
      context,
      BlurredRouter(
        builder: (context) => EmailSendWidget(email: email),
      ),
    );
  }

  Widget customTile(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    required VoidCallback onTap,
    bool? isSwitchBox,
    Function(dynamic value)? onTapSwitch,
    dynamic switchValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withValues(
                alpha: 0.10000000149011612,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              fit: BoxFit.none,
              child: UiUtils.getSvg(
                svgImagePath,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 25.rw(context),
          ),
          CustomText(
            title,
            fontWeight: FontWeight.w700,
            color: context.color.textColorDark,
          ),
          const Spacer(),
          if (isSwitchBox != true)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border:
                    Border.all(color: context.color.borderColor, width: 1.5),
                color: context.color.secondaryColor
                    .withValues(alpha: 0.10000000149011612),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.none,
                child: SizedBox(
                  width: 8,
                  height: 15,
                  child: UiUtils.getSvg(
                    AppIcons.arrowRight,
                    color: context.color.textColorDark,
                  ),
                ),
              ),
            ),
          if (isSwitchBox ?? false)
            Switch(
              value: switchValue ?? false,
              onChanged: (value) {
                onTapSwitch?.call(value);
              },
            ),
        ],
      ),
    );
  }

  Future<void> launchPathURL(isTel, String value) async {
    late Uri redirectUri;
    if (isTel) {
      redirectUri = Uri.parse('tel: $value');
    } else {
      redirectUri = Uri(
        scheme: 'mailto',
        path: value,
        query:
            'subject=${Constant.appName}&body=${UiUtils.translate(context, "mailMsgLbl")}',
      );
    }

    if (await canLaunchUrl(redirectUri)) {
      await launchUrl(redirectUri);
    } else {
      log('Could not launch $redirectUri');
    }
  }
}

class EmailSendWidget extends StatefulWidget {
  const EmailSendWidget({
    required this.email,
    super.key,
  });
  final String email;

  @override
  State<EmailSendWidget> createState() => _EmailSendWidgetState();
}

class _EmailSendWidgetState extends State<EmailSendWidget> {
  final TextEditingController _subject = TextEditingController();
  late final TextEditingController _email =
      TextEditingController(text: widget.email);
  final TextEditingController _text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0),
      body: Center(
        child: Container(
          clipBehavior: Clip.antiAlias,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: ui.Color.fromARGB(255, 201, 201, 201),
              ),
            ],
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.color.tertiaryColor
                                .withValues(alpha: 0),
                            shape: BoxShape.circle,
                          ),
                          width: 40,
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: UiUtils.getSvg(
                              AppIcons.arrowLeft,
                              matchTextDirection: true,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.rh(context),
                  ),
                  CustomText(UiUtils.translate(context, 'sendEmail')),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: _subject,
                    hintText: UiUtils.translate(context, 'subject'),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: _email,
                    isReadOnly: true,
                    hintText: UiUtils.translate(context, 'companyEmailLbl'),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField(
                    controller: _text,
                    maxLine: 100,
                    hintText: UiUtils.translate(context, 'writeSomething'),
                    minLine: 5,
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  UiUtils.buildButton(
                    context,
                    onPressed: () async {
                      final redirecturi = Uri(
                        scheme: 'mailto',
                        path: _email.text,
                        query: 'subject=${_subject.text}&body=${_text.text}',
                      );
                      await launchUrl(redirecturi);
                    },
                    height: 50.rh(context),
                    buttonTitle: UiUtils.translate(context, 'sendEmail'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
