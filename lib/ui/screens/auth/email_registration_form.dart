import 'package:country_picker/country_picker.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/validator.dart';
import 'package:flutter/material.dart';

class EmailRegistrationForm extends StatefulWidget {
  const EmailRegistrationForm({super.key, required this.email});

  final String email;

  @override
  State<EmailRegistrationForm> createState() => _EmailRegistrationFormState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(providers: [
        BlocProvider(create: (context) => SendOtpCubit()),
        BlocProvider(create: (context) => VerifyOtpCubit()),
      ], child: EmailRegistrationForm(email: arguments['email'])),
    );
  }
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Timer? timer;
  ValueNotifier<int> otpResendTime = ValueNotifier<int>(
    Constant.otpResendSecond,
  );

  String countryCode = '';
  String flagEmoji = '';
  bool? isFirstPasswordVisible;
  bool? isSecondPasswordVisible;

  @override
  void initState() {
    isFirstPasswordVisible = true;
    isSecondPasswordVisible = true;
    super.initState();
    HelperUtils.getSimCountry().then((value) {
      countryCode = value.phoneCode;
      flagEmoji = value.flagEmoji;
      setState(() {});
    });
    if (timer != null) {
      timer!.cancel();
    }
    startTimer();
    emailController.text = widget.email;
  }

  @override
  void dispose() {
    otpResendTime.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendOtpCubit, SendOtpState>(
      listener: (context, state) {
        if (state is SendOtpInProgress) {
          Widgets.showLoader(context);
        }
        if (state is SendOtpFailure) {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(
            context,
            state.errorMessage,
            type: MessageType.error,
          );
        }
        if (state is SendOtpSuccess) {
          Widgets.hideLoder(context);
          Navigator.pushReplacementNamed(context, Routes.otpScreen, arguments: {
            'isDeleteAccount': false,
            'phoneNumber': mobileController.text,
            'email': emailController.text,
            'otpVerificationId': state.verificationId,
            'countryCode': countryCode,
            'otpIs': state.verificationId,
            'isEmailSelected': true,
          });
        }
      },
      child: Scaffold(
        extendBody: true,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: 'registerEmail'.translate(context),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: buildEmailRegistrationForm(context),
          ),
        ),
      ),
    );
  }

  Widget buildEmailRegistrationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(context,
                title: 'fullName'.translate(context),
                controller: nameController,
                validator: CustomTextFieldValidator.nullCheck,
                isPhoneNumber: false,
                isPassword: false),
            buildTextField(context,
                title: 'email'.translate(context),
                validator: CustomTextFieldValidator.email,
                controller: emailController,
                isPhoneNumber: false,
                isPassword: false),
            buildTextField(context,
                title: 'phoneNumber'.translate(context),
                validator: CustomTextFieldValidator.phoneNumber,
                controller: mobileController,
                keyboard: TextInputType.phone,
                isPhoneNumber: true,
                isPassword: false),
            buildFirstPasswordTextField(
              context,
              title: 'password'.translate(context),
              validator: (value) => Validator.validatePassword(
                // Added return here
                value,
                secondFieldValue: passwordController.text,
              ),
              controller: passwordController,
            ),
            buildSecondPasswordTextField(
              context,
              title: 'confirmPassword'.translate(context),
              controller: confirmPasswordController,
              validator: (value) => Validator.validatePassword(
                // Added return here
                value,
                secondFieldValue: passwordController.text,
              ),
            ),
            SizedBox(height: 16),
            UiUtils.buildButton(
              context,
              buttonTitle: 'register'.translate(context),
              onPressed: () async {
                bool checkMobile = mobileController.text.isNotEmpty;
                if (_formKey.currentState!.validate()) {
                  await context.read<SendOtpCubit>().sendEmailOTP(
                      email: emailController.text,
                      name: nameController.text,
                      phoneNumber: checkMobile ? mobileController.text : '',
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text);
                } else {
                  HelperUtils.showSnackBarMessage(
                      context, 'pleaseFillAllFields'.translate(context));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    List<TextInputFormatter>? formaters,
    required TextEditingController controller,
    TextInputType? keyboard,
    Widget? prefix,
    Widget? suffix,
    CustomTextFieldValidator? validator,
    bool? readOnly,
    TextDirection? textDirection,
    required bool isPhoneNumber,
    required bool isPassword,
  }) {
    final requiredSymbol = CustomText(
      '*',
      color: context.color.error,
      fontWeight: FontWeight.w400,
      fontSize: context.font.large,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Row(
          children: [
            CustomText(UiUtils.translate(context, title)),
            const SizedBox(width: 3),
            if (!isPhoneNumber) requiredSymbol,
          ],
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          textDirection: textDirection,
          controller: controller,
          keyboard: keyboard,
          isReadOnly: readOnly,
          validator: isPhoneNumber ? null : validator,
          prefix: isPhoneNumber
              ? FittedBox(
                  fit: BoxFit.none,
                  child: GestureDetector(
                    onTap: showCountryCode,
                    child: Container(
                      color: context.color.primaryColor,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          CustomText(
                            flagEmoji,
                            fontSize: context.font.xxLarge,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          UiUtils.getSvg(
                            height: 12,
                            AppIcons.downArrow,
                            color: context.color.tertiaryColor,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          formaters: formaters,
          //
          fillColor: context.color.textLightColor.withValues(alpha: 00.01),
        ),
      ],
    );
  }

  Widget buildFirstPasswordTextField(
    BuildContext context, {
    required String title,
    List<TextInputFormatter>? formaters,
    required TextEditingController controller,
    TextInputType? keyboard,
    Widget? prefix,
    Widget? suffix,
    FormFieldValidator? validator,
    bool? readOnly,
    TextDirection? textDirection,
  }) {
    final requiredSymbol = CustomText(
      '*',
      color: context.color.error,
      fontWeight: FontWeight.w400,
      fontSize: context.font.large,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Row(
          children: [
            CustomText(UiUtils.translate(context, title)),
            const SizedBox(width: 3),
            requiredSymbol,
          ],
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        TextFormField(
          maxLines: 1,
          textDirection: textDirection,
          controller: controller,
          obscureText: isFirstPasswordVisible ?? false,
          inputFormatters: formaters,
          keyboardAppearance: Brightness.light,
          style: TextStyle(fontSize: context.font.large),
          validator: validator,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefix: prefix,
            suffixIcon: IconButton(
              onPressed: () {
                if (isFirstPasswordVisible == true) {
                  isFirstPasswordVisible = false;
                } else {
                  isFirstPasswordVisible = true;
                }
                setState(() {});
              },
              icon: Icon(isFirstPasswordVisible ?? false
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              color: context.color.inverseSurface,
            ),
            hintStyle: TextStyle(
              color: context.color.textColorDark.withValues(alpha: 0.7),
              fontSize: context.font.large,
            ),
            filled: true,
            fillColor: context.color.primaryColor,
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.tertiaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSecondPasswordTextField(
    BuildContext context, {
    required String title,
    List<TextInputFormatter>? formaters,
    required TextEditingController controller,
    TextInputType? keyboard,
    Widget? prefix,
    Widget? suffix,
    FormFieldValidator? validator,
    bool? readOnly,
    TextDirection? textDirection,
  }) {
    final requiredSymbol = CustomText(
      '*',
      color: context.color.error,
      fontWeight: FontWeight.w400,
      fontSize: context.font.large,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Row(
          children: [
            CustomText(UiUtils.translate(context, title)),
            const SizedBox(width: 3),
            requiredSymbol,
          ],
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        TextFormField(
          textDirection: textDirection,
          controller: controller,
          obscureText: isSecondPasswordVisible ?? false,
          inputFormatters: formaters,
          keyboardAppearance: Brightness.light,
          style: TextStyle(fontSize: context.font.large),
          validator: validator,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefix: prefix,
            suffixIcon: IconButton(
              onPressed: () {
                if (isSecondPasswordVisible == true) {
                  isSecondPasswordVisible = false;
                } else {
                  isSecondPasswordVisible = true;
                }
                setState(() {});
              },
              icon: Icon(isSecondPasswordVisible ?? false
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              color: context.color.inverseSurface,
            ),
            hintStyle: TextStyle(
              color: context.color.textColorDark.withValues(alpha: 0.7),
              fontSize: context.font.large,
            ),
            filled: true,
            fillColor: context.color.primaryColor,
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.tertiaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

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

  Widget resendOtpTimerWidget() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, child) {
        if (!(timer?.isActive ?? false)) {
          return const SizedBox.shrink();
        }
        String formatSecondsToMinutes(int seconds) {
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
        }

        return SizedBox(
          height: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: "${UiUtils.translate(context, "resendMessage")} ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.textColorDark,
                  letterSpacing: 0.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: formatSecondsToMinutes(int.parse(value.toString())),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(
                      context,
                      'resendMessageDuration',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void resendOTP() {
    context.read<SendOtpCubit>().sendEmailOTP(
          email: emailController.text.trim(),
          name: nameController.text.trim(),
          phoneNumber: mobileController.text.trim(),
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
  }

  Future<void> startTimer() async {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (otpResendTime.value == 0) {
          timer.cancel();
          otpResendTime.value = Constant.otpResendSecond;
          setState(() {});
        } else {
          otpResendTime.value--;
        }
      },
    );
    setState(() {});
  }
}
