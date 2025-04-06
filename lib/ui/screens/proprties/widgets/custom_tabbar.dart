import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    required this.controller,
    required this.tabs,
    this.isScrollable,
    super.key,
  });
  final TabController controller;
  final List<String> tabs;
  final bool? isScrollable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: isScrollable ?? false,
        labelPadding: EdgeInsets.zero,
        indicatorWeight: 0,
        controller: controller,
        indicator: BoxDecoration(
          color: context.color.tertiaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: context.color.primaryColor,
        unselectedLabelColor: context.color.textColorDark,
        tabs: List.generate(tabs.length, (index) {
          return Container(
            height: 35,
            margin: const EdgeInsets.symmetric(vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: (index == controller.index) ||
                      (index == tabs.length - 1) ||
                      index == controller.index - 1
                  ? null
                  : Border(
                      right: BorderSide(
                        color:
                            context.color.inverseSurface.withValues(alpha: 0.2),
                      ),
                    ),
            ),
            child: CustomText(
              tabs[index],
              color: index == controller.index
                  ? context.color.primaryColor
                  : context.color.textColorDark,
            ),
          );
        }),
      ),
    );
  }
}
