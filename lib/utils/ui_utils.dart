import 'dart:math';

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class UiUtils {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static Widget getSvg(
    String path, {
    bool? matchTextDirection,
    Color? color,
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      path,
      matchTextDirection: matchTextDirection ?? false,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }

  static SvgPicture networkSvg(String url, {Color? color, BoxFit? fit}) {
    return SvgPicture.network(
      url,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      fit: fit ?? BoxFit.contain,
    );
  }

  static String translate(BuildContext context, String labelKey) {
    return (AppLocalization.of(context)!.getTranslatedValues(labelKey) ??
            labelKey)
        .trim();
  }

  static Map<String, double> getWidgetInfo(
    BuildContext context,
    GlobalKey key,
  ) {
    final renderBox = key.currentContext!.findRenderObject()! as RenderBox;

    final size = renderBox.size; // or _widgetKey.currentContext?.size
    final offset = renderBox.localToGlobal(Offset.zero);

    return {
      'x': offset.dx,
      'y': offset.dy,
      'width': size.width,
      'height': size.height,
      'offX': offset.dx,
      'offY': offset.dy,
    };
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final result = languageCode.split('-');
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static Widget getDivider() {
    return const Divider(
      endIndent: 0,
      indent: 0,
    );
  }

  static Widget getImage(
    String url, {
    double? width,
    double? height,
    BoxFit? fit,
    String? blurHash,
    bool? showFullScreenImage,
  }) {
    // return SizedBox.shrink();
    final defaultMemCacheSize = 500;
    final placeholderOpacity = 0.1;
    final placeholderSize = 70.0;
    final placeholderImage = appSettings.placeholderLogo ?? '';
    return CachedNetworkImage(
      cacheKey: url,
      memCacheWidth: defaultMemCacheSize,
      memCacheHeight: defaultMemCacheSize,
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color:
            context.color.tertiaryColor.withValues(alpha: placeholderOpacity),
        alignment: Alignment.center,
        child: FittedBox(
          child: SizedBox(
            width: placeholderSize,
            height: placeholderSize,
            child: Image.network(
              placeholderImage,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color:
            context.color.tertiaryColor.withValues(alpha: placeholderOpacity),
        alignment: Alignment.center,
        child: FittedBox(
          child: SizedBox(
            width: placeholderSize,
            height: placeholderSize,
            child: Image.network(
              placeholderImage,
            ),
          ),
        ),
      ),
    );
  }

  static Widget progress({
    double? width,
    double? height,
    Color? normalProgressColor,
    bool showWhite = false,
  }) {
    if (Constant.useLottieProgress) {
      return LottieBuilder.asset(
        'assets/lottie/${showWhite ? Constant.progressLottieFileWhite : Constant.progressLottieFile}',
        width: width ?? 45,
        height: height ?? 45,
        delegates: !showWhite
            ? LottieDelegates(
                values: [
                  ValueDelegate.color(
                    [
                      'Layer 5 Outlines',
                      'Group 1',
                      '**',
                    ],
                    value: _context?.color.tertiaryColor,
                  ),
                  ValueDelegate.color(
                    [
                      'cube 4 Outlines',
                      'Group 1',
                      '**',
                    ],
                    value: _context?.color.tertiaryColor,
                  ),
                  ValueDelegate.color(
                    [
                      'cube 2 Outlines',
                      'Group 1',
                      '**',
                    ],
                    value: Colors.grey.shade100,
                  ),
                  ValueDelegate.color(
                    [
                      'cube 3 Outlines',
                      'Group 1',
                      '**',
                    ],
                    value: Colors.grey.shade100,
                  ),
                ],
              )
            : LottieDelegates(),
      );
    } else {
      return CircularProgressIndicator(
        color: normalProgressColor,
      );
    }
  }

  static CachedNetworkImage setNetworkImage(
    String imgUrl, {
    double? hh,
    double? ww,
  }) {
    return CachedNetworkImage(
      memCacheWidth: 500,
      memCacheHeight: 500,
      imageUrl: imgUrl,
      matchTextDirection: true,
      fit: BoxFit.cover,
      height: hh,
      width: ww,
      placeholder: (context, url) {
        return Image.asset('assets/images/png/placeholder.png');
      },
      errorWidget: (context, url, error) {
        return Image.asset('assets/images/png/placeholder.png');
      },
    );
  }

  ///Divider / Container

  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
  }) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: context.color.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          context.color.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
    );
  }

  static PreferredSize buildAppBar(
    BuildContext context, {
    String? title,
    bool? showBackButton,
    List<Widget>? actions,
    List<Widget>? bottom,
    double? bottomHeight,
    bool? hideTopBorder,
    VoidCallback? onbackpress,
    Color? appBarColor,
    Color? borderColor,
    Color? backButtonBackgroundColor,
    String? isFrom,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(55 + (bottomHeight ?? 0)),
      child: RoundedBorderOnSomeSidesWidget(
        borderColor: borderColor ?? context.color.borderColor,
        borderRadius: 20,
        borderWidth: 1.5,
        contentBackgroundColor: appBarColor ?? context.color.secondaryColor,
        bottomLeft: true,
        bottomRight: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (showBackButton ?? false) ? 0 : 20,
                    vertical: (showBackButton ?? false) ? 0 : 18,
                  ),
                  child: Row(
                    children: [
                      if (showBackButton ?? false) ...[
                        Material(
                          clipBehavior: Clip.antiAlias,
                          color:
                              backButtonBackgroundColor ?? Colors.transparent,
                          type: MaterialType.circle,
                          child: InkWell(
                            onTap: () {
                              onbackpress?.call();
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: UiUtils.getSvg(
                                AppIcons.arrowLeft,
                                matchTextDirection: true,
                                fit: BoxFit.none,
                                color: context.color.tertiaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: CustomText(
                          title ?? '',
                          fontWeight: FontWeight.w600,
                          color: context.color.textColorDark,
                          fontSize: context.font.larger,
                        ),
                      ),
                      if (actions != null) ...actions,
                    ],
                  ),
                ),
              ),
            ),
            ...bottom ?? [const SizedBox.shrink()],
          ],
        ),
      ),
    );
  }

  static Color makeColorDark(Color color) {
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

  static Color makeColorLight(Color color) {
    final color0 = color;

    final red = color0.r + 10;
    final green = color0.g + 10;
    final blue = color0.b + 10;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  static Widget buildButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String buttonTitle,
    double? height,
    double? width,
    BorderSide? border,
    String? titleWhenProgress,
    bool isInProgress = false,
    double? fontSize,
    double? radius,
    bool? autoWidth,
    Widget? prefixWidget,
    EdgeInsetsGeometry? padding,
    bool? showProgressTitle,
    double? progressWidth,
    double? progressHeight,
    bool? showElevation,
    Color? textColor,
    Color? buttonColor,
    EdgeInsetsGeometry? outerPadding,
    Color? disabledColor,
    VoidCallback? onTapDisabledButton,
    bool? disabled,
  }) {
    var title = '';
    final isRTL = context.read<LanguageCubit>().isRTL;
    if (isInProgress == true) {
      title = titleWhenProgress ?? buttonTitle;
    } else {
      title = buttonTitle;
    }
    return Padding(
      padding: outerPadding ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          if (disabled == true) {
            onTapDisabledButton?.call();
          }
        },
        child: MaterialButton(
          minWidth: autoWidth == true ? null : (width ?? double.infinity),
          height: height ?? 56.rh(context),
          padding: padding,
          shape: RoundedRectangleBorder(
            side: border ?? BorderSide.none,
            borderRadius: BorderRadius.circular(radius ?? 16),
          ),
          elevation: (showElevation ?? true) ? 0.5 : 0,
          color: buttonColor ?? context.color.tertiaryColor,
          disabledColor: disabledColor ?? context.color.tertiaryColor,
          onPressed: (isInProgress == true || (disabled ?? false))
              ? null
              : () {
                  HelperUtils.unfocus();
                  onPressed.call();
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixWidget != null && !isInProgress && isRTL) ...[
                prefixWidget,
              ],
              if (isInProgress) ...[
                UiUtils.progress(
                  width: progressWidth ?? 16,
                  height: progressHeight ?? 16,
                  showWhite: true,
                ),
              ],
              if (prefixWidget != null && !isInProgress && !isRTL) ...[
                prefixWidget,
              ],
              if (isInProgress != true) ...[
                CustomText(
                  title,
                  color: textColor ?? context.color.buttonColor,
                  fontSize: fontSize ?? context.font.larger,
                ),
              ] else ...[
                if (showProgressTitle ?? false)
                  CustomText(
                    title,
                    color: context.color.buttonColor,
                    fontSize: fontSize ?? context.font.larger,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String removeDoubleSlashUrl(String url) {
    final uri = Uri.parse(url);
    final segments = List<String>.from(uri.pathSegments)
      ..removeWhere((element) => element == '');
    return Uri(
      host: uri.host,
      pathSegments: segments,
      scheme: uri.scheme,
      fragment: uri.fragment,
      queryParameters: uri.queryParameters,
      port: uri.port,
      query: uri.query,
      userInfo: uri.userInfo,
    ).toString();
  }

  static Widget imageType(
    String url, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    final ext = url.split('.').last.toLowerCase();
    if (ext == 'svg') {
      return NetworkToLocalSvg().svg(
        UiUtils.removeDoubleSlashUrl(url),
        color: color,
        width: 20,
        height: 20,
      );
    } else {
      return getImage(
        url,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }

  static void showFullScreenImage(
    BuildContext context, {
    required ImageProvider provider,
    VoidCallback? then,
    bool? downloadOption,
    VoidCallback? onTapDownload,
  }) {
    Navigator.of(context)
        .push(
      BlurredRouter(
        sigmaX: 10,
        sigmaY: 10,
        barrierDismiss: true,
        builder: (BuildContext context) => FullScreenImageView(
          provider: provider,
          showDownloadButton: downloadOption,
          onTapDownload: onTapDownload,
        ),
      ),
    )
        .then((value) {
      then?.call();
    });
  }

  static void imageGallaryView(
    BuildContext context, {
    required List images,
    required int initalIndex,
    VoidCallback? then,
  }) {
    Navigator.of(context)
        .push(
      BlurredRouter(
        sigmaX: 10,
        sigmaY: 10,
        builder: (BuildContext context) => GalleryViewWidget(
          initalIndex: initalIndex,
          images: images,
        ),
      ),
    )
        .then((value) {
      then?.call();
    });
  }

  static Future showBlurredDialoge(
    BuildContext context, {
    required BlurDialoge dialoge,
    double? sigmaX,
    double? sigmaY,
  }) async {
    return Navigator.push(
      context,
      BlurredRouter(
        barrierDismiss: true,
        builder: (context) {
          if (dialoge is BlurredDialogBox) {
            return dialoge;
          } else if (dialoge is BlurredDialogBuilderBox) {
            return dialoge;
          } else if (dialoge is EmptyDialogBox) {
            return dialoge;
          }

          return Container();
        },
        sigmaX: sigmaX,
        sigmaY: sigmaY,
      ),
    );
  }

//AAA is color theory's point it means if color is AAA then it will be perfect for your app
  static bool isColorMatchAAA(Color textColor, Color background) {
    final contrastRatio = (textColor.computeLuminance() + 0.05) /
        (background.computeLuminance() + 0.05);
    if (contrastRatio < 4.5) {
      return false;
    } else {
      return true;
    }
  }

  static double getRadiansFromDegree(double radians) {
    return radians * 180 / pi;
  }

  static String time24to12hour(String time24) {
    final tempDate = DateFormat('hh:mm').parse(time24);
    final dateFormat = DateFormat('h:mm a');
    return dateFormat.format(tempDate);
  }
}

///Format string
extension FormatAmount on String {
  String formatAmount({bool prefix = false}) {
    return prefix
        ? '${Constant.currencySymbol}${toString()}'
        : '${toString()}${Constant.currencySymbol}'; // \u{20B9}"; //currencySymbol
  }

  String formatDate({
    String? format,
  }) {
    final dateFormat = DateFormat(format ?? 'MMM d, yyyy');
    final formatted = dateFormat.format(DateTime.parse(this));
    return formatted;
  }

  String formatPercentage() {
    return '${toString()} %';
  }

  String formatId() {
    return ' # ${toString()} '; // \u{20B9}"; //currencySymbol
  }

  String firstUpperCase() {
    var upperCase = '';
    var suffix = '';
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return upperCase + suffix;
  }
}

//scroll controller extenstion

extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    if (offset >= position.maxScrollExtent) {
      return true;
    }
    return false;
  }
}

class RemoveGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class RoundedBorderOnSomeSidesWidget extends StatelessWidget {
  const RoundedBorderOnSomeSidesWidget({
    required this.borderColor,
    required this.contentBackgroundColor,
    required this.child,
    required this.borderRadius,
    required this.borderWidth,
    super.key,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  /// Color of the content behind this widget
  final Color contentBackgroundColor;
  final Color borderColor;
  final Widget child;

  final double borderRadius;
  final double borderWidth;

  /// The sides where we want the rounded border to be
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? Radius.circular(borderRadius) : Radius.zero,
          topRight: topRight ? Radius.circular(borderRadius) : Radius.zero,
          bottomLeft: bottomLeft ? Radius.circular(borderRadius) : Radius.zero,
          bottomRight:
              bottomRight ? Radius.circular(borderRadius) : Radius.zero,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          top: topLeft || topRight ? borderWidth : 0,
          left: topLeft || bottomLeft ? borderWidth : 0,
          bottom: bottomLeft || bottomRight ? borderWidth : 0,
          right: topRight || bottomRight ? borderWidth : 0,
        ),
        decoration: BoxDecoration(
          color: contentBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: topLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            topRight: topRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomLeft: bottomLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomRight: bottomRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
          ),
        ),
        child: child,
      ),
    );
  }
}
