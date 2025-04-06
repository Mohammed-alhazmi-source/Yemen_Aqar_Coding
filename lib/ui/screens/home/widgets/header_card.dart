import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    required this.title,
    super.key,
    this.onSeeAll,
    this.enableShowAll,
  });
  final String title;
  final VoidCallback? onSeeAll;
  final bool? enableShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 20,
        bottom: 16,
        start: sidePadding,
        end: sidePadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomText(
              title,
              fontWeight: FontWeight.w700,
              fontSize: context.font.large,
              color: context.color.textColorDark,
              maxLines: 1,
            ),
          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
              },
              child: CustomText(
                UiUtils.translate(context, 'seeAll'),
                fontWeight: FontWeight.w700,
                fontSize: context.font.small,
                color: context.color.textLightColor,
              ),
            ),
        ],
      ),
    );
  }
}
