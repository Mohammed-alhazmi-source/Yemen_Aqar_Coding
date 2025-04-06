import 'package:ebroker/data/cubits/Utility/mortgage_calculator_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/proprties/widgets/donutChart.dart';
import 'package:ebroker/ui/screens/proprties/widgets/yearlyBreakdownScreen.dart';
import 'package:flutter/material.dart';

class MortgageCalculator extends StatefulWidget {
  const MortgageCalculator({required this.property, super.key});
  final PropertyModel property;

  @override
  State<MortgageCalculator> createState() => _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  //mortgage calculator controllers
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();
  Timer? _debounceTimer;
  final _formKey = GlobalKey<FormState>();
  bool isPercentage = false;

  @override
  void initState() {
    _downPaymentController.text = '';
    _interestRateController.text = '';
    _loanTermController.text = ''; // Default to 1 year
    super.initState();
  }

  @override
  void dispose() {
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getMortgageCalculator(context: context);
  }

  Widget _getMortgageCalculator({required BuildContext context}) {
    if (context.read<MortgageCalculatorCubit>().state
        is! MortgageCalculatorSuccess) {
      return SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'mortgageCalculator'.translate(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                CustomText(
                  '${'principalAmount'.translate(context)}: ${widget.property.price ?? '0'}',
                  color: context.color.tertiaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 10),
                _buildDownPaymentTextField(),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        readOnly: false,
                        controller: _interestRateController,
                        label: 'interestRate'.translate(context),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTextFormField(
                        readOnly: false,
                        controller: _loanTermController,
                        label: 'noOfYears'.translate(context),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (context.read<MortgageCalculatorCubit>().state
                    is! MortgageCalculatorSuccess)
                  _buildMortgageCalculatorButton(context: context),
              ],
            ),
          ),
        ),
      );
    } else if (context.read<MortgageCalculatorCubit>().state
        is MortgageCalculatorSuccess) {
      return _buildMortgageCalculatorOutput();
    }
    return const SizedBox.shrink();
  }

  Widget _buildDownPaymentTextField() {
    final price = double.parse(widget.property.price!);
    return TextFormField(
      controller: _downPaymentController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: isPercentage
            ? '${'downPaymentDescription'.translate(context)} 10%'
            : '${'downPaymentDescription'.translate(context)} ${(price * 0.1).toStringAsFixed(2)}',
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: context.color.tertiaryColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon:
            _buildDownPaymentTypeSelector(_downPaymentController, price),
      ),
      validator: (value) {
        final number = double.tryParse(value ?? '0') ?? 0;

        if (isPercentage) {
          if (number < 0 || number > 100) {
            return 'percentageRateWarning'.translate(context);
          }
        } else {
          if (number < 0 || number > double.parse(widget.property.price!)) {
            return 'amountLimitWarning'.translate(context);
          }
          if (number < 0 || number >= price) {
            return 'amountLimitWarning'.translate(context);
          }
        }
        return null;
      },
    );
  }

  Widget _buildDownPaymentTypeSelector(
    TextEditingController controller,
    double propertyPrice,
  ) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Currency button
          SizedBox(
            width: 50,
            child: InkWell(
              onTap: () {
                if (isPercentage) {
                  setState(() {
                    isPercentage = false;
                    // Convert current percentage to value
                    final currentPercentage = double.tryParse(controller.text);
                    if (currentPercentage != null) {
                      final value = (currentPercentage / 100) * propertyPrice;
                      controller.text = value.toStringAsFixed(2);
                    } else {
                      controller.clear();
                    }
                  });
                }
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: !isPercentage
                      ? context.color.tertiaryColor
                      : context.color.tertiaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: CustomText(
                    Constant.currencySymbol,
                    color: !isPercentage
                        ? context.color.secondaryColor
                        : context.color.tertiaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Percentage button
          SizedBox(
            width: 50,
            child: InkWell(
              onTap: () {
                if (!isPercentage) {
                  setState(() {
                    isPercentage = true;
                    // Convert current value to percentage
                    final currentValue = double.tryParse(controller.text);
                    if (currentValue != null) {
                      final percentage = (currentValue / propertyPrice) * 100;
                      controller.text = percentage.toStringAsFixed(1);
                    } else {
                      controller.clear();
                    }
                  });
                }
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isPercentage
                      ? context.color.tertiaryColor
                      : context.color.tertiaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: CustomText(
                    '%',
                    color: isPercentage
                        ? context.color.secondaryColor
                        : context.color.tertiaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMortgageCalculatorButton({required BuildContext context}) {
    return BlocBuilder<MortgageCalculatorCubit, MortgageCalculatorState>(
      builder: (context, state) {
        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            margin: const EdgeInsetsDirectional.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: context.read<MortgageCalculatorCubit>().state
                    is MortgageCalculatorLoading
                ? Center(
                    child: UiUtils.progress(
                      showWhite: true,
                      height: 14,
                    ),
                  )
                : CustomText(
                    textAlign: TextAlign.center,
                    'calculateMortgage'.translate(context),
                    color: context.color.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await context.read<MortgageCalculatorCubit>().calculateMortgage(
                  parameters: {
                    'loan_amount': double.parse(widget.property.price ?? '0'),
                    'down_payment': _downPaymentController.text == ''
                        ? 0
                        : isPercentage
                            ? ((double.parse(
                                      widget.property.price ?? '0',
                                    ) *
                                    double.parse(_downPaymentController.text)) /
                                100)
                            : double.parse(_downPaymentController.text),
                    'interest_rate': double.parse(_interestRateController.text),
                    'loan_term_years': double.parse(_loanTermController.text),
                    // !TODO(R): Manage this show_all_details
                    'show_all_details': 1,
                  },
                );
                setState(() {});
              } catch (e) {
                setState(() {});
                await HelperUtils.showSnackBarMessage(context, e.toString());
              }
            }
          },
        );
      },
    );
  }

  Widget _buildMortgageCalculatorOutput() {
    return BlocBuilder<MortgageCalculatorCubit, MortgageCalculatorState>(
      builder: (context, state) {
        final bool isPremiumUser = context
                .read<FetchSystemSettingsCubit>()
                .getRawSettings()['is_premium'] ??
            false;
        if (state is MortgageCalculatorLoading) {
          return Center(
            child: UiUtils.progress(),
          );
        } else if (state is MortgageCalculatorSuccess) {
          return Container(
            padding: const EdgeInsetsDirectional.only(
              bottom: 16,
              end: 16,
              start: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        'mortgageCalculator'.translate(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          setState(() {});
                          context
                              .read<MortgageCalculatorCubit>()
                              .emptyMortgageCalculatorData();
                        },
                        child: CustomText(
                          'reset'.translate(context),
                          showUnderline: true,
                          color: context.color.tertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  EMIDonutChart(
                    principalAmount: double.parse(
                      state.mortgageCalculatorModel.mainTotal
                              ?.principalAmount ??
                          '0',
                    ),
                    interestPayable: double.parse(
                      state.mortgageCalculatorModel.mainTotal
                              ?.payableInterest ??
                          '0',
                    ),
                    monthlyEMI: double.parse(
                      state.mortgageCalculatorModel.mainTotal?.monthlyEmi ??
                          '0',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'downPayment'.translate(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 5),
                          CustomText(
                            '${Constant.currencySymbol} ${state.mortgageCalculatorModel.mainTotal?.downPayment}',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'monthlyEMI'.translate(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 5),
                          CustomText(
                            '${Constant.currencySymbol} ${state.mortgageCalculatorModel.mainTotal?.monthlyEmi}',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UiUtils.buildButton(
                    context,
                    onPressed: () {
                      GuestChecker.check(
                        onNotGuest: () {
                          if (isPremiumUser) {
                            Navigator.push(
                              context,
                              BlurredRouter(
                                builder: (context) {
                                  return YearlyBreakdownScreen(
                                    mortgageCalculatorModel:
                                        state.mortgageCalculatorModel,
                                  );
                                },
                              ),
                            );
                          } else {
                            UiUtils.showBlurredDialoge(
                              context,
                              dialoge: BlurredDialogBox(
                                title: 'subscribeToUseThisFeature'
                                    .translate(context),
                                isAcceptContainesPush: true,
                                onAccept: () async {
                                  await Navigator.popAndPushNamed(
                                    context,
                                    Routes.subscriptionPackageListRoute,
                                    arguments: {'from': 'propertyDetails'},
                                  );
                                },
                                content: CustomText(
                                  'subscribeToUseThisFeature'
                                      .translate(context),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                    prefixWidget: isPremiumUser
                        ? null
                        : Container(
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            child: Icon(
                              Icons.lock,
                              color: context.color.buttonColor,
                            ),
                          ),
                    buttonTitle: 'yearlyBreakdown'.translate(context),
                    fontSize: context.font.large,
                    radius: 5,
                  ),
                ],
              ),
            ),
          );
        } else if (state is MortgageCalculatorFailure) {
          return Center(
            child: CustomText(
              '${state.errorMessage}'.translate(context),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required bool readOnly,
  }) {
    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: label,
        focusColor: context.color.tertiaryColor,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: context.color.tertiaryColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: context.color.secondaryColor.withValues(alpha: 0.1),
      ),
      validator: _validateNumber,
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'pleaseFillValue'.translate(context);
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'enterValidNumber'.translate(context);
    }

    if (isPercentage) {
      if (number <= 0 || number > 100) {
        return 'percentageRateWarning'.translate(context);
      }
    } else {
      final propertyPrice = double.parse(widget.property.price ?? '0');
      if (number <= 0 || number > propertyPrice) {
        return 'amountLimitWarning'.translate(context);
      }
    }
    return null;
  }
}
