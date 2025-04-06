import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

abstract class NativeAdWidgetContainer {}

class NativeAdWidget extends StatefulWidget implements NativeAdWidgetContainer {
  const NativeAdWidget({required this.type, super.key});
  final TemplateType type;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  bool isAdvertisementLoaded = false;
  NativeAd? _nativeAd;
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        NativeAd(
          adUnitId: Platform.isIOS
              ? Constant.admobNativeIos
              : Constant.admobNativeAndroid,
          request: const AdRequest(),
          listener: NativeAdListener(
            onAdLoaded: (Ad ad) {
              _nativeAd = ad as NativeAd;

              log('$NativeAd loaded. ${ad.responseInfo}');
              setState(() {
                isAdvertisementLoaded = true;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              log('$NativeAd failedToLoad: $error');
              ad.dispose();
            },
            onAdOpened: (Ad ad) {
              log('$NativeAd onAdOpened.');
            },
            onAdClosed: (Ad ad) {
              log('$NativeAd onAdClosed.');
            },
          ),
          // nativeAdOptions:
          //     NativeAdOptions(mediaAspectRatio: MediaAspectRatio.square),
          nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.small,
            cornerRadius: 10,
            mainBackgroundColor: Colors.white12,
            callToActionTextStyle: NativeTemplateTextStyle(
              size: 16,
              backgroundColor: context.color.tertiaryColor,
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.black38,
              backgroundColor: Colors.white70,
            ),
          ),
        ).load();
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isAdvertisementLoaded) {
      return getAdSize(widget.type);
    }
    return const SizedBox.shrink();
  }

  Widget getAdSize(TemplateType type) {
    // Small template
    if (type == TemplateType.small) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320, // minimum recommended width
          minHeight: 90, // minimum recommended height
          maxWidth: 400,
          maxHeight: 91,
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    }

// Medium template
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // minimum recommended width
        minHeight: 320, // minimum recommended height
        maxWidth: 400,
        maxHeight: 400,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

class NativeAdInjector {
  int _totalInjected = 0;
  int total = 0;
  AdConditions? _adConditions;
  call(Function(AdConditions conditions) builder) {
    final adConditions = AdConditions();
    builder.call(adConditions);
    _adConditions = adConditions;
  }

  bool isLimitReached = false;
  bool checkListLimitCondition = false;
  List<int> totalAddedAds = [];

  void wrapper({
    required List<NativeAdWidgetContainer> injectableList,
  }) {
    if (!Constant.isAdmobAdsEnabled) {
      return;
    }

    try {
      totalAddedAds = findIndices(
        injectableList,
        (element) {
          return element is NativeAdWidget;
        },
      );

      _totalInjected = totalAddedAds.length;
      total = injectableList.length;
      ////
      if (_totalInjected < _adConditions!.injectCount.count) {
        isLimitReached = false;
      } else {
        isLimitReached = true;
      }

      if (injectableList.length >= _adConditions!.minListCount) {
        checkListLimitCondition = true;
      } else {
        checkListLimitCondition = false;
      }

      if (isLimitReached == false && checkListLimitCondition == true) {
        arrangeIndex();
        for (final index in totalAddedAds) {
          injectableList.insert(
            index,
            const NativeAdWidget(
              type: TemplateType.small,
            ),
          );
        }
      }
    } catch (e, st) {
      log('Issue is $e $st');
    }
  }

  List<int> findIndices(
    List<NativeAdWidgetContainer> list,
    bool Function(NativeAdWidgetContainer) condition,
  ) {
    final indices = <int>[];
    for (var i = 0; i < list.length; i++) {
      if (condition(list[i])) {
        indices.add(i);
      }
    }
    return indices;
  }

  void arrangeIndex() {
    var lastIndex = totalAddedAds.lastOrNull ?? 0;

    for (var i = lastIndex; i < total; i++) {
      if (totalAddedAds.length != _adConditions!.injectCount.count &&
          (i + 1) % _adConditions!.afterIndex == 0) {
        lastIndex += _adConditions?.afterIndex ?? 0;
        totalAddedAds.add(lastIndex);
      }
    }
  }
}

class AdConditions {
  int minListCount = 0;
  InjectCount injectCount = InjectCount(per: 0, count: 0);
  int afterIndex = 0;

  AdConditions setMinListCount(int count) {
    minListCount = count;
    return this;
  }

  AdConditions setInjectSetting({
    required int perLength,
    required int count,
  }) {
    injectCount
      ..per = perLength
      ..count = count;
    return this;
  }

  AdConditions setAfter(int index) {
    afterIndex = index;
    return this;
  }

  Map<String, dynamic> get() {
    return {
      'min_list_count': minListCount,
      'inject_count': {'per': injectCount.per, 'count': injectCount.count},
      'after': afterIndex,
    };
  }
}

class InjectCount {
  InjectCount({required this.per, required this.count});
  int per;
  int count;
}
