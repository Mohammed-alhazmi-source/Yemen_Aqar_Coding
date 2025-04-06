import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    this.onTap,
    this.height,
    this.title,
    this.description,
  });
  final double? height;
  final VoidCallback? onTap;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: SvgPicture.asset(AppIcons.no_data_found),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomText(
            title ?? 'nodatafound'.translate(context),
            fontWeight: FontWeight.w600,
            fontSize: context.font.extraLarge,
            color: context.color.tertiaryColor,
          ),
          const SizedBox(
            height: 14,
          ),
          CustomText(
            description ?? 'sorryLookingFor'.translate(context),
            textAlign: TextAlign.center,
            fontSize: context.font.large,
          )
        ],
      ),
    );
  }
}
