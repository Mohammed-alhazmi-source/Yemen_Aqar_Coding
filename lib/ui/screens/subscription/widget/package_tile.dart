import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/ui/screens/subscription/widget/subscripton_feature_line.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

abstract class Limit<T> {
  abstract final T value;
}

class StringLimit extends Limit {
  StringLimit(this.value);
  @override
  final String value;
}

class IntLimit extends Limit {
  IntLimit(this.value);
  @override
  final int value;
}

class NotAvailable extends Limit {
  NotAvailable();
  @override
  void value;
}

class PackageLimit {
  PackageLimit(this.limit);
  final dynamic limit;

  Limit get(context) {
    if (limit is int) {
      return IntLimit(limit);
    } else {
      if (isAvailable(context, limit)) {
        if (isUnLimited(context, limit)) {
          return StringLimit('unlimited'.translate(context));
        } else {
          //Will not execute but added
          return StringLimit(limit);
        }
      } else {
        return NotAvailable();
      }
    }
  }

  bool isUnLimited(BuildContext context, String value) {
    if (value == 'unlimited') {
      return true;
    }
    return false;
  }

  bool isAvailable(BuildContext context, String? value) {
    if (value == 'not_available' || value == null) {
      return false;
    }
    return true;
  }
}

class SubscriptionPackageTile extends StatelessWidget {
  const SubscriptionPackageTile({
    required this.onTap,
    required this.package,
    super.key,
  });
  final SubscriptionPackageModel package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
                  package.name ?? '',
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.larger,
                  color: context.color.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SubscriptionFeatureLine(
            limit: PackageLimit(package.advertisementLimit),
            isTime: false,
            title: UiUtils.translate(context, 'adLimitIs'),
          ),
          SizedBox(
            height: 5.rh(context),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubscriptionFeatureLine(
                    limit: PackageLimit(package.propertyLimit),
                    isTime: false,
                    title: UiUtils.translate(context, 'propertyLimit'),
                  ),
                  SizedBox(
                    height: 5.rh(context),
                  ),
                  SubscriptionFeatureLine(
                    limit: null,
                    isTime: true,
                    timeLimit:
                        "${package.duration} ${UiUtils.translate(context, "days")}",
                    title: UiUtils.translate(context, 'validity'),
                  ),
                  // SubscriptionFeatureLine(),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 39.rh(context),
                    constraints: BoxConstraints(
                      minWidth: 80.rw(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CustomText(
                        package.price == 0
                            ? 'Free'.translate(context)
                            : '${package.price}'.formatAmount(prefix: true),
                        fontWeight: FontWeight.bold,
                        fontSize: context.font.large,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: UiUtils.buildButton(
              context,
              onPressed: onTap,
              radius: 9,
              height: 33.rh(context),
              buttonTitle: UiUtils.translate(context, 'subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewOnlyPackageCard extends StatelessWidget {
  const ViewOnlyPackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 60,
        child: Center(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.color.tertiaryColor,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: context.color.tertiaryColor,
                  ),
                ),
                CustomText(
                  'Unlocked Private Properties'.translate(context),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WavePattern extends CustomPainter {
  final Color color;

  WavePattern({this.color = const Color(0xFF087C7C)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Define wave dimensions
    final waveWidth = size.width / 14;
    final waveHeight = 6.0;
    final cornerRadius = 15.0;

    // Start path from top-left with rounded corner
    path.moveTo(cornerRadius, 0);

    // Top edge with rounded corners
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Right edge
    path.lineTo(size.width, size.height - waveHeight);

    // Draw curved waves
    double currentX = size.width;

    // Starting point for waves
    path.lineTo(currentX, size.height - waveHeight);

    while (currentX > 0) {
      // First outward curve
      path.quadraticBezierTo(
        currentX - waveWidth / 4, size.height - waveHeight * 2,
        // control point higher up
        currentX - waveWidth / 2, size.height - waveHeight, // end point
      );

      currentX -= waveWidth / 2;

      if (currentX > 0) {
        // Second outward curve
        path.quadraticBezierTo(
          currentX - waveWidth / 4, size.height, // control point lower down
          currentX - waveWidth / 2, size.height - waveHeight, // end point
        );

        currentX -= waveWidth / 2;
      }
    }

    // Complete the path
    path.lineTo(0, size.height - waveHeight);
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
