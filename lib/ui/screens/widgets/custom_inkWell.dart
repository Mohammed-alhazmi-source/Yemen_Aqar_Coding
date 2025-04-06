import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    required this.child,
    required this.onTap,
    super.key,
    this.color,
    this.borderRadius,
    this.shape,
  });
  final Color? color;
  final Widget child;
  final BorderRadius? borderRadius;
  final BoxShape? shape;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        clipBehavior: Clip.antiAlias,
        // color: color,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          shape: shape ?? BoxShape.rectangle,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}
