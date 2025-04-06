import 'package:country_picker/country_picker.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/login/apple_login/apple_login.dart';
import 'package:ebroker/utils/login/google_login/google_login.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:ebroker/utils/login/lib/login_system.dart';
import 'package:ebroker/utils/strings.dart';
import 'package:ebroker/utils/validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isDeleteAccount, this.popToCurrent});

  final bool? isDeleteAccount;
  final bool? popToCurrent;

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static BlurredRouter route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: LoginScreen(
          isDeleteAccount: args?['isDeleteAccount'],
          popToCurrent: args?['popToCurrent'],
        ),
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumController = TextEditingController(
    text: Constant.isDemoModeOn ? Constant.demoMobileNumber : '',
  );

  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<TextEditingController> _controllers = [];
  List<Widget> list = [];
  String otpVerificationId = '';
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false; //to swap between login & OTP screen
  bool isChecked = false; //Privacy policy checkbox value check
  String? phone, otp, countryCode, countryName, flagEmoji;

  int backPressedTimes = 0;
  late Size size;

  TextEditingController otpController = TextEditingController();
  bool isLoginButtonDisabled = false;
  String otpIs = '';
  bool isEmailSelected = false;
  bool isResendOtpButtonVisible = false;
  bool isForgotPasswordVisible = false;
  bool isPasswordVisible = false;

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });
  // Text change listener

  @override
  void initState() {
    super.initState();

    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) {
        if (state is MProgress) {
          unawaited(Widgets.showLoader(context));
        }

        if (state is MSuccess) {
          Widgets.hideLoder(context);
          if (widget.isDeleteAccount ?? false) {
            context.read<DeleteAccountCubit>().deleteUserAccount(
                  context,
                );
          } else {
            context.read<LoginCubit>().login(
                  type: LoginType.values
                      .firstWhere((element) => element.name == state.type),
                  name: state.credentials.user?.displayName ??
                      state.credentials.user?.providerData.first.displayName,
                  email: state.credentials.user?.providerData.first.email,
                  phoneNumber:
                      state.credentials.user?.providerData.first.phoneNumber,
                  uniqueId: state.credentials.user!.uid,
                  countryCode: countryCode,
                );
          }
        }

        if (state is MFail) {
          Widgets.hideLoder(context);
          if (state.error.toString() != 'google-terminated') {
            HelperUtils.showSnackBarMessage(
              context,
              state.error.toString(),
              type: MessageType.error,
            );
          }
        }
      });
    context.read<FetchSystemSettingsCubit>().fetchSettings(
          isAnonymous: true,
          forceRefresh: true,
        );
    mobileNumController.addListener(
      () {
        if (mobileNumController.text.isEmpty &&
            Constant.isDemoModeOn == true &&
            Constant.demoMobileNumber.isNotEmpty) {
          isLoginButtonDisabled = true;
          setState(() {});
        } else {
          isLoginButtonDisabled = false;
          setState(() {});
        }
      },
    );

    HelperUtils.getSimCountry().then((value) {
      countryCode = value.phoneCode;
      flagEmoji = value.flagEmoji;
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    isResendOtpButtonVisible = false;

    mobileNumController.dispose();
    if (isOtpSent) {
      SmsAutoFill().unregisterListener();
    }
    super.dispose();
  }

  Future<void> _onGoogleTap() async {
    try {
      await loginSystem.setActive('google');
      await loginSystem.login();
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        'googleLoginFailed'.translate(context),
        type: MessageType.error,
      );
    }
  }

  Future<void> _onTapAppleLogin() async {
    try {
      await loginSystem.setActive('apple');
      await loginSystem.login();
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        'appleLoginFailed'.translate(context),
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (context.watch<FetchSystemSettingsCubit>().state
        is FetchSystemSettingsSuccess) {
      Constant.isDemoModeOn = context
              .watch<FetchSystemSettingsCubit>()
              .getSetting(SystemSetting.demoMode) ??
          false;
    }

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (widget.isDeleteAccount ?? false) {
              Navigator.pop(context);
            } else if (isOtpSent == true) {
              setState(() {
                isOtpSent = false;
              });
            } else {
              Future.delayed(Duration.zero, () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              });
            }
            return Future.value(false);
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: context.color.backgroundColor,
            appBar: AppBar(
              systemOverlayStyle:
                  UiUtils.getSystemUiOverlayStyle(context: context),
              clipBehavior: Clip.none,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Builder(
                  builder: (context) {
                    return FittedBox(
                      fit: BoxFit.none,
                      child: MaterialButton(
                        color:
                            context.color.secondaryColor.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: context.color.borderColor,
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                        onPressed: () {
                          GuestChecker.set('login_screen', isGuest: true);
                          HiveUtils.setIsGuest();
                          APICallTrigger.trigger();
                          HiveUtils.setUserIsNotNew();
                          HiveUtils.setUserIsNotAuthenticated();
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.main,
                            arguments: {
                              'from': 'login',
                              'isSkipped': true,
                            },
                          );
                        },
                        child: CustomText('Skip'.translate(context)),
                      ),
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              height: kBottomNavigationBarHeight,
              padding: EdgeInsets.zero,
              child: buildTermsAndPrivacyWidget(),
            ),
            body: ScrollConfiguration(
              behavior: RemoveGlow().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: buildLoginFields(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginFields(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          context.read<UserDetailsCubit>().clear();
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, Routes.login);
          });
        }
      },
      builder: (context, state) {
        return BlocListener<LoginCubit, LoginState>(
          listener: (context, state) async {
            if (state is LoginInProgress) {
              unawaited(Widgets.showLoader(context));
            } else {
              if (widget.isDeleteAccount ?? false) {
              } else {
                Widgets.hideLoder(context);
              }
            }
            if (state is LoginFailure) {
              await HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
            }
            if (state is LoginSuccess) {
              try {
                Widgets.showLoader(context);
                GuestChecker.set('login_screen', isGuest: false);
                HiveUtils.setIsNotGuest();
                await LoadAppSettings().load(true);
                context
                    .read<UserDetailsCubit>()
                    .fill(HiveUtils.getUserDetails());

                APICallTrigger.trigger();

                await context.read<FetchSystemSettingsCubit>().fetchSettings(
                      isAnonymous: false,
                      forceRefresh: true,
                    );
                final settings = context.read<FetchSystemSettingsCubit>();

                if (!const bool.fromEnvironment(
                  'force-disable-demo-mode',
                )) {
                  Constant.isDemoModeOn =
                      settings.getSetting(SystemSetting.demoMode) ?? false;
                }
                if (state.isProfileCompleted) {
                  HiveUtils.setUserIsAuthenticated();
                  await HiveUtils.setUserIsNotNew();
                  await context.read<AuthCubit>().updateFCM(
                        context,
                      );
                  await Navigator.pushReplacementNamed(
                    context,
                    Routes.main,
                    arguments: {'from': 'login'},
                  );
                  Widgets.hideLoder(context);
                } else {
                  await HiveUtils.setUserIsNotNew();
                  await context.read<AuthCubit>().updateFCM(
                        context,
                      );

                  if (widget.popToCurrent == true) {
                    //Navigate to Edit profile field
                    await Navigator.pushNamed(
                      context,
                      Routes.completeProfile,
                      arguments: {
                        'from': 'login',
                        'popToCurrent': widget.popToCurrent,
                        'phoneNumber': mobileNumController.text,
                      },
                    );
                    Widgets.hideLoder(context);
                  } else {
                    //Navigate to Edit profile field
                    Widgets.hideLoder(context);
                    await Navigator.pushReplacementNamed(
                      context,
                      Routes.completeProfile,
                      arguments: {
                        'from': 'login',
                        'popToCurrent': widget.popToCurrent,
                        'phoneNumber': mobileNumController.text,
                      },
                    );
                  }
                }
              } catch (e) {
                Widgets.hideLoder(context);
                HelperUtils.showSnackBarMessage(
                  context,
                  'somethingWentWrong'.translate(context),
                  type: MessageType.error,
                );
              }
            }
          },
          child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listener: (context, state) {
              if (state is DeleteAccountProgress) {
                Widgets.hideLoder(context);
                Widgets.showLoader(context);
              }
              if (state is AccountDeleted) {
                Widgets.hideLoder(context);
              }
            },
            child: BlocListener<SendOtpCubit, SendOtpState>(
              listener: (context, state) {
                if (state is SendOtpInProgress) {
                  Widgets.showLoader(context);
                } else {
                  if (widget.isDeleteAccount ?? false) {
                  } else {
                    Widgets.hideLoder(context);
                  }
                }

                if (state is SendOtpSuccess) {
                  isOtpSent = true;
                  if (isForgotPasswordVisible) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.message ??
                          'forgotPasswordSuccess'.translate(context),
                      type: MessageType.success,
                    );
                  } else {
                    HelperUtils.showSnackBarMessage(
                      context,
                      UiUtils.translate(
                        context,
                        'optsentsuccessflly',
                      ),
                      type: MessageType.success,
                    );
                  }
                  otpVerificationId = state.verificationId ?? '';
                  setState(() {});

                  if (!isForgotPasswordVisible)
                    Navigator.pushNamed(context, Routes.otpScreen, arguments: {
                      'isDeleteAccount': widget.isDeleteAccount ?? false,
                      'phoneNumber': mobileNumController.text,
                      'email': emailAddressController.text,
                      'otpVerificationId': otpVerificationId,
                      'countryCode': countryCode ?? '',
                      'otpIs': otpIs,
                      'isEmailSelected': isEmailSelected,
                    });
                  // context.read<SendOtpCubit>().setToInitial();
                }
                if (state is SendOtpFailure) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.errorMessage,
                    type: MessageType.error,
                  );
                }
              },
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {});
                },
                child: buildLoginScreen(context),
              ),
            ),
          ),
        );
      },
    );
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == mobileNumController.text) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget buildLoginScreen(BuildContext context) {
    return BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
      listener: (context, state) {
        if (state is FetchSystemSettingsInProgress) {
          unawaited(Widgets.showLoader(context));
        }
        if (state is FetchSystemSettingsSuccess) {
          Widgets.hideLoder(context);
        }
      },
      builder: (context, state) {
        final phoneLogin = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.numberWithOtpLogin);
        final socialLogin = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.socialLogin);
        if (state is FetchSystemSettingsSuccess) {
          return Column(
            children: [
              _buildLoginShapeContainer(context, phoneLogin, socialLogin),
              _buildLoginContent(context, phoneLogin, socialLogin),
            ],
          );
        } else if (state is FetchSystemSettingsFailure) {
          return const Center(child: SomethingWentWrong());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildLoginShapeContainer(
      BuildContext context, String phoneLogin, String socialLogin) {
    final bool isSocialLogin = socialLogin == '1';
    final bool isPhoneLogin = phoneLogin == '1';
    final double height = isSocialLogin && isPhoneLogin
        ? MediaQuery.of(context).size.height * 0.5
        : MediaQuery.of(context).size.height * 0.55;
    return Stack(
      children: [
        Center(
          child: ClipPath(
            clipper: VShapeClipper(context: context),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: height,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          child: Center(
            child: ClipPath(
              clipper: VShapeClipper(context: context),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: height,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -20,
          child: Center(
            child: ClipPath(
              clipper: VShapeClipper(context: context),
              child: Image.asset(
                height: height,
                width: MediaQuery.of(context).size.width,
                'assets/login_background.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginContent(
      BuildContext context, String phoneLogin, String socialLogin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          SizedBox(height: 20.rh(context)),
          if (socialLogin == '0') ...[
            buildMobileEmailField(),
          ],
          if (socialLogin == '1') _buildSocialLoginSection(context, phoneLogin),
          const SizedBox(
            height: kBottomNavigationBarHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Center(
        child: Column(
          children: [
            CustomText(UiUtils.translate(context, 'loginNow'),
                fontWeight: FontWeight.w700,
                fontSize: context.font.extraLarge,
                color: context.color.textColorDark),
            const SizedBox(
              height: 8,
            ),
            CustomText(
              UiUtils.translate(context, 'loginToYourAccount'),
              fontWeight: FontWeight.w500,
              fontSize: context.font.large,
              color: context.color.textColorDark,
            ),
          ],
        ),
      );

  Widget _buildSocialLoginSection(BuildContext context, String phoneLogin) {
    if (phoneLogin == '0') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialButton(
              context: context,
              text: 'signInWithApple'.translate(context),
              icon: isEmailSelected ? AppIcons.phone : AppIcons.email,
              onTap: () {
                isEmailSelected
                    ? isEmailSelected = false
                    : isEmailSelected = true;
                setState(() {});
              }),
          const SizedBox(width: 10),
          if (Platform.isIOS) ...[
            _buildSocialButton(
                context: context,
                text: 'signInWithApple'.translate(context),
                icon: AppIcons.apple,
                onTap: _onTapAppleLogin),
            const SizedBox(width: 10),
          ],
          _buildSocialButton(
              text: 'signInWithGoogle'.translate(context),
              context: context,
              icon: AppIcons.google,
              onTap: _onGoogleTap),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMobileEmailField(),
          SizedBox(height: 8.rh(context)),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: context.color.inverseSurface.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomText('or'.translate(context)),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: context.color.inverseSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.rh(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                  context: context,
                  text: 'signInWithApple'.translate(context),
                  icon: isEmailSelected ? AppIcons.phone : AppIcons.email,
                  onTap: () {
                    isEmailSelected
                        ? isEmailSelected = false
                        : isEmailSelected = true;
                    setState(() {});
                  }),
              const SizedBox(width: 10),
              if (Platform.isIOS) ...[
                _buildSocialButton(
                  context: context,
                  text: 'signInWithApple'.translate(context),
                  icon: AppIcons.apple,
                  onTap: _onTapAppleLogin,
                ),
                const SizedBox(width: 10),
              ],
              _buildSocialButton(
                context: context,
                text: 'signInWithGoogle'.translate(context),
                icon: AppIcons.google,
                onTap: _onGoogleTap,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required VoidCallback onTap,
    required String text,
  }) {
    return GestureDetector(
      onTap: () {
        HelperUtils.unfocus();
        onTap();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.color.borderColor,
            width: 1.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: UiUtils.getSvg(
            icon,
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }

  // Widget buildMobileEmailField() => Column(
  //       children: [
  //         isEmailSelected
  //             ? Column(
  //                 children: [
  //                   TextFormField(
  //                     validator: Validator.validateEmail,
  //                     autofocus: false,
  //                     textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  //                     scrollPadding: EdgeInsets.only(
  //                         bottom: MediaQuery.of(context).viewInsets.bottom * 4),
  //                     decoration: InputDecoration(
  //                       errorMaxLines: 1,
  //                       errorText: '',
  //                       errorStyle: TextStyle(
  //                         color: Colors.transparent,
  //                         fontSize: 0,
  //                       ),
  //                       contentPadding: EdgeInsets.all(14),
  //                       isDense: true,
  //                       enabledBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide:
  //                             BorderSide(color: context.color.tertiaryColor),
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide:
  //                             BorderSide(color: context.color.tertiaryColor),
  //                       ),
  //                       focusedErrorBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide:
  //                             BorderSide(color: context.color.tertiaryColor),
  //                       ),
  //                       errorBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide:
  //                             BorderSide(color: context.color.tertiaryColor),
  //                       ),
  //                       hintText: 'email'.translate(context),
  //                       hintStyle: TextStyle(
  //                           color: context.color.inverseSurface
  //                               .withValues(alpha: 0.5)),
  //                       prefixIcon: Icon(Icons.email),
  //                       prefixIconColor: context.color.tertiaryColor,
  //                     ),
  //                     onChanged: (String value) {
  //                       setState(() {});
  //                       isResendOtpButtonVisible = false;
  //                     },
  //                     textAlignVertical: TextAlignVertical.bottom,
  //                     style: TextStyle(fontSize: 20),
  //                     cursorColor: context.color.tertiaryColor,
  //                     cursorErrorColor: context.color.tertiaryColor,
  //                     cursorHeight: 20,
  //                     keyboardType: TextInputType.emailAddress,
  //                     controller: emailAddressController,
  //                     inputFormatters: [
  //                       FilteringTextInputFormatter.singleLineFormatter
  //                     ],
  //                     textAlign: TextAlign.start,
  //                   ),
  //                   if (!isForgotPasswordVisible)
  //                     TextFormField(
  //                       validator: Validator.validatePassword,
  //                       autofocus: false,
  //                       textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  //                       scrollPadding: EdgeInsets.only(
  //                           bottom:
  //                               MediaQuery.of(context).viewInsets.bottom * 4),
  //                       obscureText: !isPasswordVisible,
  //                       decoration: InputDecoration(
  //                         suffixIcon: IconButton(
  //                           onPressed: () {
  //                             if (isPasswordVisible == true) {
  //                               isPasswordVisible = false;
  //                             } else {
  //                               isPasswordVisible = true;
  //                             }
  //                             setState(() {});
  //                           },
  //                           icon: Icon(isPasswordVisible
  //                               ? Icons.visibility_off_outlined
  //                               : Icons.visibility_outlined),
  //                           color: context.color.inverseSurface,
  //                         ),
  //                         errorMaxLines: 1,
  //                         errorText: '',
  //                         errorStyle: TextStyle(
  //                           color: Colors.transparent,
  //                           fontSize: 0,
  //                         ),
  //                         contentPadding: EdgeInsets.all(14),
  //                         isDense: true,
  //                         enabledBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide:
  //                               BorderSide(color: context.color.tertiaryColor),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide:
  //                               BorderSide(color: context.color.tertiaryColor),
  //                         ),
  //                         focusedErrorBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide:
  //                               BorderSide(color: context.color.tertiaryColor),
  //                         ),
  //                         errorBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide:
  //                               BorderSide(color: context.color.tertiaryColor),
  //                         ),
  //                         hintText: 'password'.translate(context),
  //                         hintStyle: TextStyle(
  //                             color: context.color.inverseSurface
  //                                 .withValues(alpha: 0.5)),
  //                         prefixIcon: Icon(Icons.lock),
  //                         prefixIconColor: context.color.tertiaryColor,
  //                       ),
  //                       onChanged: (String value) {
  //                         setState(() {});
  //                       },
  //                       textAlignVertical: TextAlignVertical.bottom,
  //                       style: TextStyle(fontSize: 20),
  //                       cursorColor: context.color.tertiaryColor,
  //                       cursorErrorColor: context.color.tertiaryColor,
  //                       cursorHeight: 20,
  //                       keyboardType: TextInputType.visiblePassword,
  //                       controller: passwordController,
  //                       inputFormatters: [
  //                         FilteringTextInputFormatter.singleLineFormatter
  //                       ],
  //                       textAlign: TextAlign.start,
  //                     ),
  //                 ],
  //               )
  //             : TextFormField(
  //                 autofocus: false,
  //                 textDirection: TextDirection.ltr,
  //                 maxLength: 16,
  //                 scrollPadding: EdgeInsets.only(
  //                     bottom: MediaQuery.of(context).viewInsets.bottom * 4),
  //                 buildCounter: (
  //                   context, {
  //                   required currentLength,
  //                   required isFocused,
  //                   maxLength,
  //                 }) {
  //                   return const SizedBox.shrink();
  //                 },
  //                 validator: Validator.validatePhoneNumber,
  //                 decoration: InputDecoration(
  //                   errorMaxLines: 1,
  //                   errorText: '',
  //                   errorStyle: TextStyle(
  //                     color: Colors.transparent,
  //                     fontSize: 0,
  //                   ),
  //                   contentPadding: EdgeInsets.all(14),
  //                   isDense: true,
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide:
  //                         BorderSide(color: context.color.tertiaryColor),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide:
  //                         BorderSide(color: context.color.tertiaryColor),
  //                   ),
  //                   focusedErrorBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     borderSide:
  //                         BorderSide(color: context.color.tertiaryColor),
  //                   ),
  //                   errorBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     borderSide:
  //                         BorderSide(color: context.color.tertiaryColor),
  //                   ),
  //                   // hintTextDirection: TextDirection.ltr,
  //                   hintTextDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  //                   hintText: Localizations.localeOf(context).languageCode == 'ar' ? ' 000000000 +967' : ' +967 000000000',
  //                   // hintText: ' +${countryCode ?? ''} 0000000000',
  //                   hintStyle: TextStyle(
  //                       color: context.color.inverseSurface
  //                           .withValues(alpha: 0.5)),
  //                   prefixIcon: !AppSettings.disableCountrySelection &&  Directionality.of(context) == TextDirection.ltr 
  //                   &&  Localizations.localeOf(context).languageCode == 'ar'
  //                       ? FittedBox(
  //                           fit: BoxFit.scaleDown,
  //                           child: GestureDetector(
  //                             // onTap: showCountryCode,
  //                             child: Container(
  //                               padding:
  //                                   const EdgeInsetsDirectional.only(start: 10),
  //                               height: 50,
  //                               alignment: Alignment.center,
  //                               child: Row(
  //                                 children: [
  //                                   CustomText(
  //                                     // flagEmoji ?? '',
  //                                     '🇾🇪',
  //                                     fontSize: context.font.xxLarge,
  //                                   ),
  //                                   const SizedBox(
  //                                     width: 4,
  //                                   ),
  //                                   UiUtils.getSvg(
  //                                     height: 12,
  //                                     AppIcons.downArrow,
  //                                     color: context.color.tertiaryColor,
  //                                   ),
  //                                   const SizedBox(
  //                                     width: 4,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         )
  //                       : SizedBox.shrink(),
  //                   suffixIcon: !AppSettings.disableCountrySelection &&
  //                           Directionality.of(context) == TextDirection.rtl  &&  Localizations.localeOf(context).languageCode == 'en'
  //                       ? FittedBox(
  //                           fit: BoxFit.none,
  //                           child: GestureDetector(
  //                             // onTap: showCountryCode,
  //                             child: Container(
  //                               padding:
  //                                   const EdgeInsetsDirectional.only(end: 10),
  //                               height: 50,
  //                               alignment: Alignment.center,
  //                               child: Row(
  //                                 children: [
  //                                   CustomText(
  //                                     // flagEmoji ?? '',
  //                                     '🇾🇪',
  //                                     fontSize: context.font.xxLarge,
  //                                   ),
  //                                   const SizedBox(
  //                                     width: 4,
  //                                   ),
  //                                   UiUtils.getSvg(
  //                                     height: 12,
  //                                     AppIcons.downArrow,
  //                                     color: context.color.tertiaryColor,
  //                                   ),
  //                                   const SizedBox(
  //                                     width: 4,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         )
  //                       : SizedBox.shrink(),
  //                 ),
  //                 onChanged: (String value) {
  //                   setState(() {
  //                     // phone = '${countryCode!} $value';
  //                     phone = '+967 $value';
  //                   });
  //                 },
  //                 textAlignVertical: TextAlignVertical.bottom,
  //                 style: TextStyle(fontSize: 20),
  //                 cursorColor: context.color.tertiaryColor,
  //                 cursorErrorColor: context.color.tertiaryColor,
  //                 cursorHeight: 20,
  //                 keyboardType: TextInputType.phone,
  //                 controller: mobileNumController,
  //                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //                 textAlign: TextAlign.start,
  //               ),
  //         const SizedBox(
  //           height: 4,
  //         ),
  //         if (!isForgotPasswordVisible && isEmailSelected)
  //           buildForgotPasswordText(),
  //         if (isForgotPasswordVisible)
  //           GestureDetector(
  //             onTap: () {
  //               isForgotPasswordVisible = false;
  //               setState(() {});
  //             },
  //             child: Container(
  //               alignment: AlignmentDirectional.centerEnd,
  //               padding: const EdgeInsetsDirectional.only(
  //                   end: sidePadding, bottom: 10),
  //               child: CustomText(
  //                 'goBackToLogin'.translate(context),
  //                 fontSize: context.font.normal,
  //                 color: context.color.tertiaryColor,
  //               ),
  //             ),
  //           ),
  //         isForgotPasswordVisible
  //             ? buildSubmitButton(context: context)
  //             : isResendOtpButtonVisible
  //                 ? buildResendOtpButton(context: context, isEmail: true)
  //                 : buildNextButton(context: context, isEmail: isEmailSelected),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         if (isEmailSelected)
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               CustomText('registerWith'.translate(context)),
  //               const SizedBox(width: 5),
  //               CustomText('eBroker'.translate(context)),
  //               const SizedBox(width: 5),
  //               GestureDetector(
  //                 onTap: () {
  //                   Navigator.pushNamed(context, Routes.emailRegistrationForm,
  //                       arguments: {
  //                         'email': emailAddressController.text,
  //                       });
  //                 },
  //                 child: CustomText(
  //                   'signUp'.translate(context),
  //                   fontWeight: FontWeight.w600,
  //                   color: context.color.tertiaryColor,
  //                 ),
  //               ),
  //             ],
  //           )
  //       ],
  //     );

Widget buildMobileEmailField() => Column(
  children: [
    isEmailSelected
        ? Column(
            children: [
              TextFormField(
                validator: Validator.validateEmail,
                autofocus: false,
                textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom * 4),
                decoration: InputDecoration(
                  errorMaxLines: 1,
                  errorText: '',
                  errorStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                  contentPadding: EdgeInsets.all(14),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: context.color.tertiaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: context.color.tertiaryColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: context.color.tertiaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: context.color.tertiaryColor),
                  ),
                  hintText: 'email'.translate(context),
                  hintStyle: TextStyle(
                      color: context.color.inverseSurface
                          .withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.email),
                  prefixIconColor: context.color.tertiaryColor,
                ),
                onChanged: (String value) {
                  setState(() {});
                  isResendOtpButtonVisible = false;
                },
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontSize: 20),
                cursorColor: context.color.tertiaryColor,
                cursorErrorColor: context.color.tertiaryColor,
                cursorHeight: 20,
                keyboardType: TextInputType.emailAddress,
                controller: emailAddressController,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                textAlign: TextAlign.start,
              ),
              if (!isForgotPasswordVisible)
                TextFormField(
                  validator: Validator.validatePassword,
                  autofocus: false,
                  textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  scrollPadding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).viewInsets.bottom * 4),
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (isPasswordVisible == true) {
                          isPasswordVisible = false;
                        } else {
                          isPasswordVisible = true;
                        }
                        setState(() {});
                      },
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      color: context.color.inverseSurface,
                    ),
                    errorMaxLines: 1,
                    errorText: '',
                    errorStyle: TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),
                    contentPadding: EdgeInsets.all(14),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: context.color.tertiaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: context.color.tertiaryColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: context.color.tertiaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: context.color.tertiaryColor),
                    ),
                    hintText: 'password'.translate(context),
                    hintStyle: TextStyle(
                        color: context.color.inverseSurface
                            .withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.lock),
                    prefixIconColor: context.color.tertiaryColor,
                  ),
                  onChanged: (String value) {
                    setState(() {});
                  },
                  textAlignVertical: TextAlignVertical.bottom,
                  style: TextStyle(fontSize: 20),
                  cursorColor: context.color.tertiaryColor,
                  cursorErrorColor: context.color.tertiaryColor,
                  cursorHeight: 20,
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                  textAlign: TextAlign.start,
                ),
            ],
          )
        : TextFormField(
            autofocus: false,
            textDirection: TextDirection.ltr,
            maxLength: 9,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom * 4),
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) {
              return const SizedBox.shrink();
            },
            validator: Validator.validatePhoneNumber,
            decoration: InputDecoration(
              prefix: Padding(padding: const EdgeInsets.only(right: 8.0)),
              errorMaxLines: 1,
              errorText: '',
              errorStyle: TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              contentPadding: EdgeInsets.all(14),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.color.tertiaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.color.tertiaryColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.color.tertiaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    BorderSide(color: context.color.tertiaryColor),
              ),
              // label: Text(Localizations.localeOf(context).languageCode),
              hintTextDirection: TextDirection.ltr,
              hintText: ' +967 000000000', // رمز دولة اليمن
              hintStyle: TextStyle(
                  color: context.color.inverseSurface
                      .withValues(alpha: 0.5)),
                    prefixIcon:  Directionality.of(context) == TextDirection.rtl 
                    
                    // !AppSettings.disableCountrySelection &&  Directionality.of(context) == TextDirection.ltr 
                    // &&  Localizations.localeOf(context).languageCode == 'ar'
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                              // onTap: showCountryCode,
                              child: Container(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 10),
                                height: 50,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    CustomText(
                                      // flagEmoji ?? '',
                                      '🇾🇪',
                                      fontSize: context.font.xxLarge,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    // UiUtils.getSvg(
                                    //   // AppIcons.downArrow,                                      
                                    //   height: 12,
                                    //   color: context.color.tertiaryColor,
                                    // ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              ),
                          )
                        : SizedBox.shrink(),
                    suffixIcon: 
                            Directionality.of(context) == TextDirection.ltr
                        ? FittedBox(
                            fit: BoxFit.none,
                              // onTap: showCountryCode,
                              child: Container(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10),
                                height: 50,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    CustomText(
                                      // flagEmoji ?? '',
                                      '🇾🇪',
                                      fontSize: context.font.xxLarge,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    // UiUtils.getSvg(
                                    //   height: 12,
                                    //   // AppIcons.downArrow,
                                    //   color: context.color.tertiaryColor,
                                    // ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              ),
                          )
                        : SizedBox.shrink(),
                   
            ),
            onChanged: (String value) {
              setState(() {
                phone = '+967 $value'; // رمز دولة اليمن
              });
            },
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyle(fontSize: 20),
            cursorColor: context.color.tertiaryColor,
            cursorErrorColor: context.color.tertiaryColor,
            cursorHeight: 20,
            keyboardType: TextInputType.phone,
            controller: mobileNumController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.start,
          ),
    const SizedBox(
      height: 4,
    ),
    if (!isForgotPasswordVisible && isEmailSelected)
      buildForgotPasswordText(),
    if (isForgotPasswordVisible)
      GestureDetector(
        onTap: () {
          isForgotPasswordVisible = false;
          setState(() {});
        },
        child: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(
              end: sidePadding, bottom: 10),
          child: CustomText(
            'goBackToLogin'.translate(context),
            fontSize: context.font.normal,
            color: context.color.tertiaryColor,
          ),
        ),
      ),
    isForgotPasswordVisible
        ? buildSubmitButton(context: context)
        : isResendOtpButtonVisible
            ? buildResendOtpButton(context: context, isEmail: true)
            : buildNextButton(context: context, isEmail: isEmailSelected),
    const SizedBox(
      height: 10,
    ),
    if (isEmailSelected)
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText('registerWith'.translate(context)),
          const SizedBox(width: 5),
          CustomText('Y-AQAR'.translate(context)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.emailRegistrationForm,
                  arguments: {
                    'email': emailAddressController.text,
                  });
            },
            child: CustomText(
              'signUp'.translate(context),
              fontWeight: FontWeight.w600,
              color: context.color.tertiaryColor,
            ),
          ),
        ],
      )
  ],
);

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(11),
        backgroundColor: context.color.backgroundColor,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          iconColor: context.color.tertiaryColor,
          prefixIconColor: context.color.tertiaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.color.tertiaryColor),
          ),
          floatingLabelStyle: TextStyle(color: context.color.tertiaryColor),
          labelText: 'Search',
          border: const OutlineInputBorder(),
        ),
      ),
      onSelect: (Country value) {
        flagEmoji = value.flagEmoji;
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  Future<void> sendEmailVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      Widgets.showLoader(context);
      await context.read<LoginCubit>().loginWithEmail(
            email: emailAddressController.text.trim(),
            password: passwordController.text.trim(),
            type: LoginType.email,
          );
      final state = context.read<LoginCubit>().state;
      if (state is LoginFailure) {
        Widgets.hideLoder(context);
        isResendOtpButtonVisible = true;
        setState(() {});
      } else if (state is LoginSuccess) {
        Widgets.hideLoder(context);
        return;
      }
    } else {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidEmailPassword'.translate(context),
        messageDuration: 1,
        type: MessageType.error,
        isFloating: true,
      );
    }
  }

  Future<void> sendPhoneVerificationCode({String? number}) async {
    if (!_formKey.currentState!.validate() ||
        mobileNumController.text.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidNumber'.translate(context),
        messageDuration: 1,
        type: MessageType.error,
        isFloating: true,
      );
      return;
    }
    if (AppSettings.otpServiceProvider == 'twilio' &&
        (widget.isDeleteAccount ?? false)) {
      try {
        await context
            .read<SendOtpCubit>()
            .sendTwilioOTP(phoneNumber: '+$number');
      } catch (e) {
        Widgets.hideLoder(context);
        await HelperUtils.showSnackBarMessage(
          context,
          Strings.invalidPhoneMessage,
          type: MessageType.error,
        );
      }
    } else if (AppSettings.otpServiceProvider == 'firebase' &&
        (widget.isDeleteAccount ?? false)) {
      try {
        await context
            .read<SendOtpCubit>()
            .sendFirebaseOTP(phoneNumber: '+$number');
      } catch (e) {
        Widgets.hideLoder(context);
        await HelperUtils.showSnackBarMessage(
          context,
          Strings.invalidPhoneMessage,
          type: MessageType.error,
        );
      }
    }
    final form = _formKey.currentState;

    if (form == null) return;
    form.save();
    //checkbox value should be 1 before Login/SignUp
    try {
      if (form.validate()) {
        if (widget.isDeleteAccount ?? false) {
        } else if (AppSettings.otpServiceProvider == 'firebase') {
          await context.read<SendOtpCubit>().sendFirebaseOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        } else if (AppSettings.otpServiceProvider == 'twilio') {
          await context.read<SendOtpCubit>().sendTwilioOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        }
      }
    } catch (e) {
      Widgets.hideLoder(context);
      await HelperUtils.showSnackBarMessage(
        context,
        Strings.invalidPhoneMessage,
        type: MessageType.error,
      );
    }
  }

  Widget buildForgotPasswordText() {
    return GestureDetector(
      onTap: () {
        isForgotPasswordVisible = true;
        setState(() {});
      },
      child: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: sidePadding, bottom: 10),
        child: CustomText(
          'forgotPassword'.translate(context),
          fontSize: context.font.normal,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  Widget buildSubmitButton({required BuildContext context}) {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        await context.read<SendOtpCubit>().sendForgotPasswordEmail(
              email: emailAddressController.text.trim(),
            );
      },
      disabled: (emailAddressController.text.trim().isEmpty),
      disabledColor: Colors.grey,
      height: 50,
      radius: 10,
      border: BorderSide(
        color: context.color.borderColor,
        width: 1,
      ),
      buttonTitle: 'submit'.translate(context),
    );
  }

  Widget buildResendOtpButton(
      {required BuildContext context, required bool isEmail}) {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        await context.read<SendOtpCubit>().resendEmailOTP(
              email: emailAddressController.text.trim(),
              password: passwordController.text.trim(),
            );
      },
      buttonTitle: UiUtils.translate(context, 'resendOtpBtnLbl'),
    );
  }

  Widget buildNextButton(
      {required BuildContext context, required bool isEmail}) {
    return UiUtils.buildButton(
      context,
      disabled: (isEmail && emailAddressController.text.isEmpty) ||
          (!isEmail && mobileNumController.text.isEmpty),
      disabledColor: Colors.grey,
      height: 50,
      onPressed:
          isEmail ? sendEmailVerificationCode : sendPhoneVerificationCode,
      buttonTitle: 'continue'.translate(context),
      border: BorderSide(
        color: context.color.borderColor,
        width: 1,
      ),
      radius: 10,
    );
  }

//otp
  Widget buildTermsAndPrivacyWidget() {
    return Container(
      padding: EdgeInsetsDirectional.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "${UiUtils.translate(context, "policyAggreementStatement")}\n",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.textColorDark,
                      ),
                ),
                TextSpan(
                  text: UiUtils.translate(context, 'termsConditions'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() {
                      HelperUtils.goToNextPage(
                        Routes.profileSettings,
                        context,
                        false,
                        args: {
                          'title':
                              UiUtils.translate(context, 'termsConditions'),
                          'param': Api.termsAndConditions,
                        },
                      );
                    }),
                ),
                TextSpan(
                  text: " ${UiUtils.translate(context, "and")} ",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.textColorDark,
                      ),
                ),
                TextSpan(
                  text: UiUtils.translate(context, 'privacyPolicy'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() {
                      HelperUtils.goToNextPage(
                        Routes.profileSettings,
                        context,
                        false,
                        args: {
                          'title': UiUtils.translate(context, 'privacyPolicy'),
                          'param': Api.privacyPolicy,
                        },
                      );
                    }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VShapeClipper extends CustomClipper<Path> {
  VShapeClipper({required this.context});
  final BuildContext context;
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;
    final path = Path();
    var shortestSide = MediaQuery.of(context).size.width;

    final bool useMobileLayout = shortestSide < 550;

    final pad = useMobileLayout ? 12.0 : 25.0;
    path
      ..lineTo(0, h - (pad * 10))
      ..quadraticBezierTo(0, h - (pad * 10) + 5, 5, h - (pad * 10) + 10)
      ..lineTo(w / 2 - pad, h - pad / 2)
      ..cubicTo(w / 2, h, w / 2, h, w / 2 + pad, h - pad / 2)
      ..lineTo(w - 5, h - (pad * 10) + 10)
      ..quadraticBezierTo(w, h - (pad * 10) + 5, w, h - (pad * 10))
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
