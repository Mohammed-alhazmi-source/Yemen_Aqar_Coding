// ignore_for_file: public_member_api_docs, sort_constructors_firstutils/Extensions/extensions.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/ui/screens/subscription/widget/package_tile.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/liquid_indicator/src/liquid_circular_progress_indicator.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CurrentPackageTileCard extends StatefulWidget {
  const CurrentPackageTileCard({
    required this.package,
    super.key,
  });
  final SubscriptionPackageModel package;

  @override
  State<CurrentPackageTileCard> createState() => _CurrentPackageTileCardState();
}

class _CurrentPackageTileCardState extends State<CurrentPackageTileCard> {
  String endDate = '';
  bool isLifeTimeValidity = false;
  String endDay = '';

  // int? getDaysRemining() {
  //   if (widget.endDate != null) {
  //     DateTime currentDate = DateTime.now();
  //     Duration remainingDuration =
  //         DateTime.parse(widget.endDate).difference(currentDate);
  //     int daysLeft = remainingDuration.inDays;
  //     return daysLeft;
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    // if (widget.package / endDate != null) {
    //   endDate = widget.endDate.toString().formatDate(format: "d MMM yyyy");
    //   endDay = widget.endDate.toString().formatDate(format: "EEEE");
    // }
    // isLifeTimeValidity = widget.endDate == null;
    return Container(
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCurvePatternWidget(context),
          const SizedBox(
            height: 5,
          ),
          buildPriceAndTitleWidget(context),
          buildValidityWidget(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: widget.package.type == 'premium_user'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
              children: [
                if (widget.package.type == 'premium_user')
                  const Expanded(child: ViewOnlyPackageCard()),

                if (widget.package.type != 'premium_user')
                  LiquidProgressContainer(
                    title: 'property'.translate(context),
                    countUsed: widget.package.usedLimitForProperty ?? 0,
                    countLimit: widget.package.propertyLimit,
                  ),
                // LiquidProgressContainer(
                //   title: "property".translate(context),
                //   countRemining: widget.propertyRemining,
                //   countLimit: widget.propertyLimit,
                // ),
                if (widget.package.type != 'premium_user')
                  LiquidProgressContainer(
                    title: 'advertisement'.translate(context),
                    countUsed: widget.package.usedLimitForAdvertisement ?? 0,
                    countLimit: widget.package.advertisementLimit,
                  ),
                // LiquidProgressContainer(
                //   title: "advertisement".translate(context),
                //   countRemining: widget.advertismentRemining,
                //   countLimit: widget.advertismentLimit,
                // ),
                LiquidProgressContainer(
                  title: 'daysRemining'.translate(context),
                  countUsed: widget.package.remainingDays!,
                  isValidity: true,
                  countLimit: widget.package.duration,
                ),
                // LiquidProgressContainer(
                //   title: "daysRemining".translate(context),
                //   countRemining: (getDaysRemining() ?? 0).toString(),
                //   countLimit: widget.duration,
                //   isValidity: true,
                //   validityCount: widget.duration.toString(),
                // ),
              ],
            ),
          ),
          if (isLifeTimeValidity)
            const SizedBox(
              height: 6,
            ),
          if (!isLifeTimeValidity)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: DateCard(
                      title: 'startedOn'.translate(context),
                      day: widget.package.startDate!.formatDate(format: 'EEEE'),
                      date: widget.package.startDate ?? '',
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: DateCard(
                      day: widget.package.endDate!.formatDate(format: 'EEEE'),
                      title: 'willEndOn'.translate(context),
                      date: widget.package.endDate ?? '',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Stack buildCurvePatternWidget(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: context.screenWidth,
          child: UiUtils.getSvg(
            AppIcons.headerCurve,
            color: context.color.tertiaryColor,
            fit: BoxFit.fitWidth,
          ),
        ),
        PositionedDirectional(
            start: 10.rw(context),
            top: 8.rh(context),
            child: CustomText(
              UiUtils.translate(context, 'currentPackage'),
              fontWeight: FontWeight.w600,
              fontSize: context.font.larger,
              color: context.color.secondaryColor,
            )),
      ],
    );
  }

  Padding buildPriceAndTitleWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              child: CustomText(
                widget.package.name!,
                fontWeight: FontWeight.w600,
                fontSize: context.font.larger,
                color: context.color.textColorDark,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      'price'.translate(context),
                      textBaseline: TextBaseline.alphabetic,
                      fontWeight: FontWeight.w300,
                      fontSize: context.font.small,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    buildPriceWidget(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPriceWidget(BuildContext context) {
    return Row(
      children: [
        if (widget.package.price != 0)
          CustomText(
            Constant.currencySymbol,
            height: 0.6,
            fontSize: context.font.larger,
            color: context.color.tertiaryColor,
          ),
        CustomText(
          (widget.package.price == 0 ? 'Free' : widget.package.price)
              .toString(),
          height: 0.6,
          fontWeight: FontWeight.w500,
          fontSize: context.font.larger,
        ),
      ],
    );
  }

  Widget buildValidityWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        0,
        16,
        widget.package.type == 'premium_user' ? 0 : 10,
      ),
      child: CustomText(
        "${"packageValidity".translate(context)} ${widget.package.duration} ${"Days".translate(context)}",
        fontSize: context.font.large,
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  const DateCard({
    required this.title,
    required this.date,
    required this.day,
    super.key,
  });
  final String title;
  final String date;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(title),
        Container(
          height: 53,
          decoration: BoxDecoration(
            color: context.color.tertiaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.calender,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    context.color.buttonColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        day,
                        color: context.color.buttonColor,
                      ),
                      CustomText(
                        date,
                        fontWeight: FontWeight.w200,
                        color: context.color.buttonColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LiquidProgressContainer extends StatelessWidget {
  const LiquidProgressContainer({
    required this.title,
    required this.countUsed,
    required this.countLimit,
    super.key,
    this.isValidity,
    this.validityCount,
  });
  final String title;
  final int countUsed;
  final dynamic countLimit;
  final bool? isValidity;
  final String? validityCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          title,
          fontSize: context.font.normal,
        ),
        const SizedBox(
          height: 7,
        ),
        getLiquidProgress(
          context,
        ),
      ],
    );
  }

  Widget getLiquidProgress(BuildContext context) {
    double persontage;
    persontage = 0;
    var value = '';
    if (countLimit == 'not_available' || countLimit == null) {
      value = 'X';
    } else if (countLimit == 'unlimited') {
      value = 'unlimited'.translate(context);
    } else {
      value = '$countUsed/$countLimit';
      persontage = countUsed / countLimit;
    }
    if (isValidity == true) {
      value = "$countUsed ${"Days".translate(context)}";
    }

    return SizedBox(
      width: 60,
      height: 60,
      child: LiquidCircularProgressIndicator(
        value: persontage,
        valueColor: AlwaysStoppedAnimation(
          context.color.tertiaryColor.withValues(alpha: 0.3),
        ),
        backgroundColor: context.color.secondaryColor,
        borderColor: context.color.tertiaryColor,
        borderWidth: 3,
        center: Padding(
          padding: const EdgeInsets.all(5),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: CustomText(
              value,
              fontSize: context.font.small,
            ),
          ),
        ),
      ),
    );
  }
}
