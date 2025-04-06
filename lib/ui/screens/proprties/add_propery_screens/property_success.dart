import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PropertyAddSuccess extends StatelessWidget {
  const PropertyAddSuccess({required this.model, super.key});

  final PropertyModel model;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        Navigator.popUntil(context, (Route route) => route.isFirst);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SizedBox(
          width: context.screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppIcons.propertySubmittedc),
              const SizedBox(
                height: 32,
              ),
              CustomText(
                'congratulations'.translate(context),
                fontWeight: FontWeight.bold,
                fontSize: context.font.extraLarge,
                color: context.color.tertiaryColor,
              ),
              const SizedBox(
                height: 18,
              ),
              CustomText(
                'submittedSuccess'.translate(context),
                textAlign: TextAlign.center,
                fontSize: context.font.larger,
              ),
              const SizedBox(
                height: 68,
              ),
              MaterialButton(
                  elevation: 0,
                  onPressed: () async {
                    try {
                      unawaited(Widgets.showLoader(context));
                      final fetch = PropertyRepository();
                      final dataOutput =
                          await fetch.fetchPropertyFromPropertyId(
                        id: model.id!,
                        isMyProperty:
                            model.addedBy.toString() == HiveUtils.getUserId(),
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
                              'fromMyProperty': true,
                            },
                          );
                        },
                      );
                    } catch (e) {
                      Widgets.hideLoder(context);
                    }
                  },
                  height: 48,
                  minWidth: MediaQuery.of(context).size.width * 0.6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: context.color.tertiaryColor),
                  ),
                  color: context.color.backgroundColor,
                  child: CustomText(
                    'previewProperty'.translate(context),
                    color: context.color.tertiaryColor,
                    fontSize: context.font.larger,
                  )),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.popUntil(context, (Route route) => route.isFirst);
                },
                child: CustomText(
                  'backToHome'.translate(context),
                  fontSize: context.font.large,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
