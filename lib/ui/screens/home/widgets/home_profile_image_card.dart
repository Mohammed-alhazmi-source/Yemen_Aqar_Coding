import 'package:ebroker/data/cubits/system/user_details.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CircularProfileImageWidget extends StatelessWidget {
  const CircularProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        margin: const EdgeInsetsDirectional.only(end: 10),
        child: FittedBox(
          fit: BoxFit.cover,
          child: GestureDetector(
            child: (context.watch<UserDetailsCubit>().state.user?.profile ?? '')
                    .trim()
                    .isEmpty
                ? FittedBox(
                    fit: BoxFit.none,
                    child: buildDefaultPersonSVG(
                      context,
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    width: 90,
                    height: 90,
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      context.watch<UserDetailsCubit>().state.user?.profile ??
                          '',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace,
                      ) {
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                      loadingBuilder: (
                        BuildContext context,
                        Widget? child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child!;
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
