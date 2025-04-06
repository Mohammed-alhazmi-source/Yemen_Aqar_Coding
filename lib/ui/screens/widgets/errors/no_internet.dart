import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 250,
            ),
            SizedBox(
              child: UiUtils.getSvg(AppIcons.no_internet),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomText(
              'noInternet'.translate(context),
              fontWeight: FontWeight.w600,
              fontSize: context.font.extraLarge,
              color: context.color.tertiaryColor,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: context.screenWidth * 0.8,
              child: CustomText(
                UiUtils.translate(context, 'noInternetErrorMsg'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
                onPressed: onRetry,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(
                    context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: CustomText(
                  UiUtils.translate(context, 'retry'),
                  color: context.color.tertiaryColor,
                )),
          ],
        ),
      ),
    );
  }
}
