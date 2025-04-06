import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

mixin BlurDialoge {}

///This dialog box will blur background of screen
///This is normally a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBox extends StatelessWidget implements BlurDialoge {
  const BlurredDialogBox({
    required this.title,
    required this.content,
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.barrierDismissable,
    this.isAcceptContainesPush,
  });
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget content;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return Stack(
      children: [
        //Make dialoge box's background lighter black
        GestureDetector(
          onTap: () {
            if (barrierDismissable ?? false) {
              Navigator.pop(context);
            }
          },
          child: Container(
            color: Colors.black.withValues(alpha: 0.14),
          ),
        ),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 186 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                        child: SizedBox(
                          // width: 87 / 2,
                          // height: 87 / 2,
                          child: UiUtils.getSvg(
                            svgImagePath!,
                            color: svgImageColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    CustomText(title.firstUpperCase(),
                        textAlign: TextAlign.center),
                  ],
                ),
                content: content,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancleButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor:
                          cancelButtonColor ?? context.color.primaryColor,
                      buttonName: cancelButtonName ??
                          UiUtils.translate(context, 'cancelBtnLbl'),
                      textColor: cancelTextColor ?? context.color.textColorDark,
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context, false);
                      },
                    ),

                    // const Spacer(),
                  ],
                  Builder(
                    builder: (context) {
                      if (showCancleButton == false) {
                        return Center(
                          child: SizedBox(
                            width: context.screenWidth / 2,
                            child: button(
                              context,
                              constraints: constraints,
                              buttonColor: acceptButtonColor ??
                                  context.color.tertiaryColor,
                              buttonName: acceptButtonName ??
                                  UiUtils.translate(context, 'ok'),
                              textColor: acceptTextColor ??
                                  context.color.textColorDark,
                              onTap: () async {
                                await onAccept?.call();

                                if (isAcceptContainesPush == false ||
                                    isAcceptContainesPush == null) {
                                  Future.delayed(
                                    Duration.zero,
                                    () {
                                      Navigator.pop(context, true);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }
                      return button(
                        context,
                        constraints: constraints,
                        buttonColor:
                            acceptButtonColor ?? context.color.tertiaryColor,
                        buttonName: acceptButtonName ??
                            UiUtils.translate(context, 'ok'),
                        textColor: acceptTextColor ??
                            const Color.fromARGB(255, 255, 255, 255),
                        onTap: () async {
                          if (!context.mounted) return;
                          await onAccept?.call();
                          if (isAcceptContainesPush == false ||
                              isAcceptContainesPush == null) {
                            Future.delayed(
                              Duration.zero,
                              () {
                                Navigator.pop(context, true);
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color makeColorDark(Color color) {
    final color0 = color;

    final red = color0.r - 10;
    final green = color0.g - 10;
    final blue = color0.b - 10;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  Widget button(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: constraints.maxWidth / 3,
      child: MaterialButton(
        elevation: 0,

        height: 39.rh(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: context.color.borderColor),
        ),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,

        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }
}

///This dialoge box will blur background of screen
///This is normaly a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBuilderBox extends StatelessWidget implements BlurDialoge {
  const BlurredDialogBuilderBox({
    required this.title,
    required this.contentBuilder,
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.isAcceptContainesPush,
  });
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget? Function(BuildContext context, BoxConstraints constrains)
      contentBuilder;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? isAcceptContainesPush;

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return Stack(
      children: [
        //Make dialog box's background lighter black
        Container(
          color: Colors.black.withValues(alpha: 0.14),
        ),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: makeColorDark(context.color.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 98 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                        child: SizedBox(
                          width: 87 / 2,
                          height: 87 / 2,
                          child: UiUtils.getSvg(
                            svgImagePath!,
                            color: svgImageColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    CustomText(title.firstUpperCase(),
                        textAlign: TextAlign.center),
                  ],
                ),
                content: contentBuilder.call(context, constraints),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (showCancleButton ?? true) ...[
                    button(
                      context,
                      constraints: constraints,
                      buttonColor: cancelButtonColor ??
                          context.color.tertiaryColor.withValues(alpha: .10),
                      buttonName: cancelButtonName ??
                          UiUtils.translate(context, 'cancelBtnLbl'),
                      textColor: cancelTextColor ?? context.color.textColorDark,
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context, false);
                      },
                    ),

                    // const Spacer(),
                  ],
                  Builder(
                    builder: (context) {
                      if (showCancleButton == false) {
                        return Center(
                          child: SizedBox(
                            width: context.screenWidth / 2,
                            child: button(
                              context,
                              constraints: constraints,
                              buttonColor: acceptButtonColor ??
                                  context.color.tertiaryColor,
                              buttonName: acceptButtonName ??
                                  UiUtils.translate(context, 'ok'),
                              textColor: acceptTextColor ??
                                  context.color.textColorDark,
                              onTap: () async {
                                await onAccept?.call();

                                if (isAcceptContainesPush == false ||
                                    isAcceptContainesPush == null) {
                                  Future.delayed(
                                    Duration.zero,
                                    () {
                                      Navigator.pop(context, true);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }
                      return button(
                        context,
                        constraints: constraints,
                        buttonColor:
                            acceptButtonColor ?? context.color.tertiaryColor,
                        buttonName: acceptButtonName ??
                            UiUtils.translate(context, 'ok'),
                        textColor: acceptTextColor ??
                            const Color.fromARGB(255, 255, 255, 255),
                        onTap: () async {
                          await onAccept?.call();
                          if (isAcceptContainesPush == false ||
                              isAcceptContainesPush == null) {
                            Future.delayed(
                              Duration.zero,
                              () {
                                Navigator.pop(context, true);
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color makeColorDark(Color color) {
    final color0 = color;

    final red = color0.r - 10;
    final green = color0.g - 10;
    final blue = color0.b - 10;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  Widget button(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: constraints.maxWidth / 3,
      child: MaterialButton(
        elevation: 0,
        height: 39.rh(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,

        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }
}

class EmptyDialogBox extends StatelessWidget with BlurDialoge {
  const EmptyDialogBox({
    required this.child,
    super.key,
    this.barrierDismisable,
  });
  final Widget child;
  final bool? barrierDismisable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (barrierDismisable ?? true) Navigator.pop(context);
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
