import 'package:ebroker/app/routes.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: UiUtils.getSvg(
          AppIcons.search,
          color: context.color.tertiaryColor,
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(top: 8, right: sidePadding, left: sidePadding),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.searchScreenRoute,
                arguments: {'autoFocus': true, 'openFilterScreen': false},
              );
            },
            child: AbsorbPointer(
              child: Container(
                width: 285.rw(
                  context,
                ),
                height: 50.rh(
                  context,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: context.color.borderColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: context.color.secondaryColor,
                ),
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none, //OutlineInputBorder()
                    fillColor: Theme.of(context).colorScheme.secondaryColor,
                    hintText: UiUtils.translate(context, 'searchHintLbl'),
                    prefixIcon: buildSearchIcon(),
                    prefixIconConstraints:
                        const BoxConstraints(minHeight: 5, minWidth: 5),
                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                  onTap: () {
                    //change prefix icon color to primary
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.propertyMapScreen);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.getSvg(
                AppIcons.propertyMap,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
