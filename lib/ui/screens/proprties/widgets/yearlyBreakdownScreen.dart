import 'package:ebroker/data/model/mortgage_calculator_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class YearlyBreakdownScreen extends StatefulWidget {
  const YearlyBreakdownScreen({
    required this.mortgageCalculatorModel,
    super.key,
  });
  final MortgageCalculatorModel mortgageCalculatorModel;

  @override
  State<YearlyBreakdownScreen> createState() => _YearlyBreakdownScreenState();
}

class _YearlyBreakdownScreenState extends State<YearlyBreakdownScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.mortgageCalculatorModel.yearlyTotals.isEmpty
        ? const Center(
            child: NoDataFound(),
          )
        : Scaffold(
            appBar: UiUtils.buildAppBar(
              context,
              showBackButton: true,
              title: 'yearlyBreakdown'.translate(context),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSummaryRow(
                          'principalAmount'.translate(context),
                          '${Constant.currencySymbol} ${widget.mortgageCalculatorModel.mainTotal?.principalAmount}',
                        ),
                        const Spacer(),
                        _buildSummaryRow(
                          'monthlyEMI'.translate(context),
                          '${Constant.currencySymbol} ${widget.mortgageCalculatorModel.mainTotal?.monthlyEmi}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ...List.generate(
                    widget.mortgageCalculatorModel.yearlyTotals.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8),
                        child: _buildYearContent(
                          yearData: widget
                              .mortgageCalculatorModel.yearlyTotals[index],
                          initiallyExpanded: index == 0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildYearContent({
    required YearlyTotals yearData,
    required bool initiallyExpanded,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: EdgeInsets.zero,
      expandedAlignment: Alignment.centerLeft,
      iconColor: context.color.tertiaryColor,
      collapsedIconColor: context.color.inverseSurface,
      title: CustomText(
        yearData.year ?? '',
        fontWeight: FontWeight.bold,
        fontSize: context.font.larger,
      ),
      textColor: context.color.tertiaryColor,
      collapsedTextColor: context.color.textColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: context.color.borderColor,
        ),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: context.color.borderColor,
        ),
      ),
      collapsedBackgroundColor: context.color.secondaryColor,
      backgroundColor: context.color.secondaryColor,
      initiallyExpanded: initiallyExpanded,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            _buildSummaryRow(
              'principalAmount'.translate(context),
              '${Constant.currencySymbol} ${yearData.principalAmount}',
            ),
            const Spacer(),
            _buildSummaryRow(
              'outstandingAmount'.translate(context),
              '${Constant.currencySymbol} ${yearData.remainingBalance}',
            ),
            const SizedBox(
              width: 16,
            ),
          ],
        ),
        _buildPaymentScheduleTable(monthData: yearData.monthlyTotals ?? []),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildPaymentScheduleTable({required List<MonthlyTotals> monthData}) {
    const cellPadding = 12.0;
    return DataTable(
      dividerThickness: 0,
      horizontalMargin: 10,
      columnSpacing: 4,
      headingRowColor: WidgetStatePropertyAll(context.color.tertiaryColor),
      columns: [
        DataColumn(
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: cellPadding),
            child: CustomText(
              'month'.translate(context),
              fontWeight: FontWeight.bold,
              fontSize: context.font.small,
              color: context.color.primaryColor,
            ),
          ),
        ),
        DataColumn(
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: cellPadding),
            child: CustomText(
              'principal'.translate(context),
              fontWeight: FontWeight.bold,
              fontSize: context.font.small,
              color: context.color.primaryColor,
            ),
          ),
        ),
        DataColumn(
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: cellPadding),
            child: CustomText(
              'interest'.translate(context),
              fontWeight: FontWeight.bold,
              fontSize: context.font.small,
              color: context.color.primaryColor,
            ),
          ),
        ),
        DataColumn(
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: cellPadding),
            child: CustomText(
              'outstanding'.translate(context),
              fontWeight: FontWeight.bold,
              fontSize: context.font.small,
              color: context.color.primaryColor,
            ),
          ),
        ),
      ],
      rows: List.generate(
        monthData.length,
        (index) => DataRow(
          color: index.isOdd
              ? WidgetStatePropertyAll(
                  context.color.tertiaryColor.withValues(alpha: 0.1),
                )
              : WidgetStatePropertyAll(context.color.secondaryColor),
          cells: [
            DataCell(
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  '${monthData[index].month?.substring(0, 3)}'.firstUpperCase(),
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  '${Constant.currencySymbol} ${monthData[index].principalAmount}',
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  '${Constant.currencySymbol} ${monthData[index].payableInterest}',
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  '${Constant.currencySymbol} ${monthData[index].remainingBalance}',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label,
            fontSize: context.font.large,
          ),
          CustomText(
            value,
            fontSize: context.font.extraLarge,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
