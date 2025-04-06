import 'dart:ui';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

class PropertyCardBig extends StatelessWidget {
  const PropertyCardBig({
    required this.property,
    super.key,
    this.onLikeChange,
    this.isFirst,
    this.showEndPadding,
    this.showLikeButton,
  });

  final PropertyModel property;
  final bool? isFirst;
  final bool? showEndPadding;
  final bool? showLikeButton;
  final Function(FavoriteType type)? onLikeChange;

  @override
  Widget build(BuildContext context) {
    var rentPrice = property.price!
        .priceFormat(
          enabled: Constant.isNumberWithSuffix == true,
          context: context,
        )
        .formatAmount(prefix: true);
    if (property.rentduration != '' && property.rentduration != null) {
      rentPrice =
          ('$rentPrice / ') + (property.rentduration ?? '').translate(context);
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: (isFirst ?? false) ? 0 : 5.0,
        end: (showEndPadding ?? true) ? 5.0 : 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        height: 280,
        width: 260,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 147,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: UiUtils.getImage(
                          property.titleImage!,
                          height: 147,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          blurHash: property.titleimagehash,
                        ),
                      ),
                      PositionedDirectional(
                        start: 10,
                        bottom: 10,
                        child: Container(
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Center(
                                child: CustomText(
                                  property.properyType!
                                      .toLowerCase()
                                      .translate(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font.smaller,
                                  color: context.color.textColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            UiUtils.imageType(
                              property.category!.image!,
                              width: 18,
                              height: 18,
                              color: Constant.adaptThemeColorSvg
                                  ? context.color.tertiaryColor
                                  : null,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: CustomText(
                                property.category?.category ?? '',
                                fontWeight: FontWeight.w400,
                                fontSize: context.font.small,
                                color: context.color.textLightColor,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (property.properyType.toString().toLowerCase() ==
                            'rent') ...[
                          CustomText(
                            rentPrice,
                            maxLines: 1,
                            fontWeight: FontWeight.w700,
                            fontSize: context.font.large,
                            color: context.color.tertiaryColor,
                          ),
                        ] else ...[
                          CustomText(
                            property.price!
                                .priceFormat(
                                  enabled: Constant.isNumberWithSuffix == true,
                                  context: context,
                                )
                                .formatAmount(prefix: true),
                            maxLines: 1,
                            fontWeight: FontWeight.w700,
                            fontSize: context.font.large,
                            color: context.color.tertiaryColor,
                          ),
                        ],
                        const SizedBox(
                          height: 5,
                        ),
                        CustomText(
                          property.title ?? '',
                          maxLines: 1,
                          fontSize: context.font.large,
                          color: context.color.textColorDark,
                        ),
                        if (property.city != '') ...[
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UiUtils.getSvg(
                                AppIcons.location,
                                height: 20,
                                width: 15,
                                color: context.color.textLightColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: CustomText(
                                property.city!,
                                maxLines: 1,
                                color: context.color.textLightColor,
                              )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showLikeButton ?? true)
              PositionedDirectional(
                end: 25,
                top: 128,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(33, 0, 0, 0),
                        offset: Offset(0, 2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: LikeButtonWidget(
                    propertyId: property.id!,
                    isFavourite: property.isFavourite!,
                    onLikeChanged: onLikeChange,
                  ),
                ),
              ),
            PositionedDirectional(
              start: 10,
              top: 10,
              child: Row(
                children: [
                  Visibility(
                    visible: property.promoted ?? false,
                    child: const PromotedCard(type: PromoteCardType.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
