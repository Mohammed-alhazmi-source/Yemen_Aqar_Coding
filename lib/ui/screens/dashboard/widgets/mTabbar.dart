import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class MTabBar extends StatefulWidget {
  const MTabBar({
    required this.tabs,
    required this.controller,
    required this.onChange,
    super.key,
    this.activeTabDecoration,
    this.deactiveTabDecoration,
    this.padding,
  });
  final List<MTab> tabs;
  final MTabDecoration? activeTabDecoration;
  final MTabDecoration? deactiveTabDecoration;
  final EdgeInsetsGeometry? padding;
  final PageController controller;
  final Function(int page) onChange;

  @override
  State<MTabBar> createState() => _MTabBarState();
}

class _MTabBarState extends State<MTabBar> {
  int _activeTabindex = 0;
  Map? selectedTab;

  final ScrollController _scrollController = ScrollController();
  GlobalKey? selectedKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final indexxedList = List.generate(widget.tabs.length, (index) {
      return _IndexedMTab(index, widget.tabs[index]);
    }).toList();
    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      padding: widget.padding,
      scrollDirection: Axis.horizontal,
      children: [
        ...indexxedList.map<Widget>((_IndexedMTab e) {
          final decoration = _activeTabindex == e.index
              ? widget.activeTabDecoration
              : widget.deactiveTabDecoration;
          final key = GlobalKey();
          if (decoration == null) {
            return MaterialButton(
              key: key,
              onPressed: () {
                setState(() {
                  final info = UiUtils.getWidgetInfo(context, key);
                  selectedTab = info;

                  selectedKey = key;
                  _activeTabindex = e.index;
                  widget.controller.jumpToPage(e.index);
                  widget.onChange(e.index);

                  setState(() {});
                });
              },
              child: CustomText(e.tab.title),
            );
          }
          return decoration._buildButton(
            key,
            context,
            child: CustomText(e.tab.title),
            onPressed: (info) {
              selectedTab = info;
              widget.controller.jumpToPage(e.index);
              _activeTabindex = e.index;
              widget.onChange(e.index);
              setState(() {});
            },
          );
        }),
      ],
    );
  }
}

class MTab {
  MTab({required this.title, this.activeDecoration, this.deactiveDecoration});
  final String title;
  final MTabDecoration? activeDecoration;
  final MTabDecoration? deactiveDecoration;
}

class _IndexedMTab {
  _IndexedMTab(this.index, this.tab);
  final int index;
  final MTab tab;
}

class MTabDecoration {
  MTabDecoration({
    this.color,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.overlayColor,
    this.side,
    this.tapTargetSize,
    this.animationDuration,
    this.clipBehavior,
    this.focusNode,
    this.autofocus,
  });
  final Color? color;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final WidgetStateProperty<Color?>? overlayColor;
  final BorderSide? side;
  final MaterialTapTargetSize? tapTargetSize;
  final Duration? animationDuration;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  final bool? autofocus;

  // Helper method to create the MaterialButton
  MaterialButton _buildButton(
    GlobalKey key,
    BuildContext context, {
    required Widget child,
    Function(Map info)? onPressed,
  }) {
    return MaterialButton(
      key: key,
      onPressed: () {
        final info = UiUtils.getWidgetInfo(context, key);

        onPressed?.call(info);
      },
      color: color,
      textColor: textColor,
      elevation: elevation,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        side: side ?? BorderSide.none,
      ),
      materialTapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      focusNode: focusNode,
      onHighlightChanged: (isHighlighted) {
        // You can add any additional logic here when the button is highlighted.
      },
      onLongPress: () {
        // You can add any additional logic here when the button is long-pressed.
      },
      mouseCursor: SystemMouseCursors.click,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      disabledColor: Colors.transparent,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      child: child,
    );
  }
}

class RoundedMTabDecoration extends MTabDecoration {
  RoundedMTabDecoration({
    required this.radius,
    required this.borderColor,
    this.tColor,
    this.buttonColor,
  });
  final Color borderColor;
  final double radius;
  final Color? tColor;
  final Color? buttonColor;
  @override
  BorderRadius? get borderRadius => BorderRadius.circular(radius);
  @override
  Color? get textColor => tColor ?? super.textColor;
  @override
  Color? get color => buttonColor ?? super.color;

  @override
  BorderSide? get side => BorderSide(width: 1.5, color: borderColor);
}

class MTabView extends StatefulWidget {
  const MTabView({required this.controller, required this.pages, super.key});
  final PageController controller;
  final List<Widget> pages;

  @override
  State<MTabView> createState() => _MTabViewState();
}

class _MTabViewState extends State<MTabView> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.controller,
      children: widget.pages,
    );
  }
}
