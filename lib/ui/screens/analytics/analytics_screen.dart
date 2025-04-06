import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({required this.interestUserCount, super.key});
  final String interestUserCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.05),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: context.screenWidth,
              height: 100,
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      UiUtils.translate(context, 'interestedUserCount'),
                      fontWeight: FontWeight.bold,
                      color: context.color.textColorDark,
                      fontSize: context.font.larger,
                    ),
                    Center(
                        child: CustomText(
                      interestUserCount,
                      fontStyle: FontStyle.italic,
                      color: context.color.textColorDark,
                      fontSize: context.font.extraLarge,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
