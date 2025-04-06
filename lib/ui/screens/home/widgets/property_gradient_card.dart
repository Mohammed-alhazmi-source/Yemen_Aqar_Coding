import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PropertyGradiendCard extends StatefulWidget {
  const PropertyGradiendCard({
    required this.model,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });
  final PropertyModel model;
  final bool? isFirst;
  final bool? showEndPadding;

  @override
  State<PropertyGradiendCard> createState() => _PropertyGradiendCardState();
}

class _PropertyGradiendCardState extends State<PropertyGradiendCard> {
  List<Widget> paramterList(PropertyModel propertie) {
    final parameters = propertie.parameters;

    final List<Widget>? icons = parameters?.map((e) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          width: 15,
          height: 15,
          child: SvgPicture.network(
            e.image!,
            colorFilter: ColorFilter.mode(
              context.color.tertiaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }).toList();

    final filterd = icons?.take(4);

    return filterd?.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          unawaited(Widgets.showLoader(context));
          final fetch = PropertyRepository();
          final dataOutput = await fetch.fetchPropertyFromPropertyId(
            id: widget.model.id!,
            isMyProperty:
                widget.model.addedBy.toString() == HiveUtils.getUserId(),
          );
          Future.delayed(
            Duration.zero,
            () {
              Widgets.hideLoder(context);
              HelperUtils.goToNextPage(
                Routes.propertyDetails,
                context,
                false,
                args: {
                  'propertyData': dataOutput,
                  'fromMyProperty': false,
                },
              );
            },
          );
        } catch (e) {
          Widgets.hideLoder(context);
        }
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: (widget.isFirst ?? false) ? 0 : 5.0,
          end: (widget.showEndPadding ?? true) ? 5.0 : 0,
        ),
        child: Container(
          height: 200,
          width: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final propertie = widget.model;
              return Stack(
                children: [
                  UiUtils.getImage(
                    propertie.titleImage ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    width: c.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.2,
                          0.4,
                          0.7,
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: c.maxHeight,
                      width: c.maxWidth,
                      child: Stack(
                        children: [
                          PositionedDirectional(
                            top: 0,
                            start: 0,
                            child: Row(
                              children: [
                                Container(
                                  height: 19,
                                  decoration: BoxDecoration(
                                    color: secondaryColorDark.withValues(
                                        alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Center(
                                      child: CustomText(
                                        propertie.properyType!
                                            .translate(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font.smaller,
                                        color: context.color.buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                if (propertie.promoted ?? false)
                                  Container(
                                    height: 19,
                                    decoration: BoxDecoration(
                                      color: context.color.tertiaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Center(
                                        child: PromotedCard(
                                          color: Colors.transparent,
                                          type: PromoteCardType.icon,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PositionedDirectional(
                            bottom: 0,
                            start: 0,
                            child: SizedBox(
                              height: c.maxHeight * 0.35,
                              width: c.maxWidth - 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Row(
                                          children: [
                                            UiUtils.imageType(
                                              propertie.category?.image ?? '',
                                              color: Constant.adaptThemeColorSvg
                                                  ? context.color.tertiaryColor
                                                  : null,
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                                child: CustomText(
                                              (propertie.category!.category) ??
                                                  '',
                                              maxLines: 1,
                                              color: context.color.buttonColor,
                                            )),
                                          ],
                                        ),
                                        const Spacer(),
                                        CustomText(
                                          (propertie.title) ?? '',
                                          maxLines: 1,
                                          fontSize: context.font.large,
                                          color: context.color.buttonColor,
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.location,
                                              colorFilter: ColorFilter.mode(
                                                context.color.buttonColor
                                                    .withValues(alpha: 0.8),
                                                BlendMode.srcIn,
                                              ),
                                              width: 12,
                                              height: 12,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                child: CustomText(
                                                  propertie.address ?? '',
                                                  maxLines: 1,
                                                  color:
                                                      context.color.buttonColor,
                                                  fontSize: context.font.small,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Spacer(),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: CustomText(
                                            propertie.price!
                                                .priceFormat(
                                                  enabled: Constant
                                                          .isNumberWithSuffix ==
                                                      true,
                                                  context: context,
                                                )
                                                .formatAmount(
                                                  prefix: true,
                                                ),
                                            maxLines: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font.extraLarge,
                                            color: context.color.buttonColor,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: paramterList(propertie),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // const PositionedDirectional(
                  //     child: PromotedCard(type: PromoteCardType.icon))
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
