import 'dart:developer';

import 'package:ebroker/data/cubits/subscription/assign_free_package.dart';
import 'package:ebroker/data/cubits/subscription/assign_package.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/subscription/payment_gatways.dart';
import 'package:ebroker/ui/screens/subscription/widget/current_package_card.dart';
import 'package:ebroker/ui/screens/subscription/widget/package_tile.dart';
import 'package:ebroker/ui/screens/subscription/widget/subscripton_feature_line.dart';
import 'package:ebroker/utils/AdMob/bannerAdLoadWidget.dart';
import 'package:ebroker/utils/AdMob/interstitialAdManager.dart';
import 'package:ebroker/utils/liquid_indicator/src/liquid_circular_progress_indicator.dart';
import 'package:ebroker/utils/payment/in_app_purchase/inAppPurchaseManager.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/payment_service.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageListScreen extends StatefulWidget {
  const SubscriptionPackageListScreen({super.key, this.from});
  final String? from;
  static Route route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => GetSubsctiptionPackageLimitsCubit(),
            ),
            BlocProvider(
              create: (context) => AssignFreePackageCubit(),
            ),
            BlocProvider(
              create: (context) => AssignInAppPackageCubit(),
            ),
          ],
          child: SubscriptionPackageListScreen(
            from: arguments?['from'],
          ),
        );
      },
    );
  }

  @override
  State<SubscriptionPackageListScreen> createState() =>
      _SubscriptionPackageListScreenState();
}

class _SubscriptionPackageListScreenState
    extends State<SubscriptionPackageListScreen> {
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  InAppPurchaseManager inAppPurchase = InAppPurchaseManager();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchSubscriptionPackagesCubit>().hasMore()) {
          context.read<FetchSubscriptionPackagesCubit>().fetchMorePackages();
        }
      }
    });

    context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
    interstitialAdManager.load();
    InAppPurchaseManager.getPendings();
    inAppPurchase.listenIAP(context);
    PaymentGatways.initPaystack();

    super.initState();
  }

  dynamic ifServiceUnlimited(dynamic text, {dynamic remining}) {
    if (text == 'unlimited') {
      return UiUtils.translate(context, 'unlimited');
    }
    if (text == 'not_available') {
      return '';
    }
    if (remining != null) {
      return '';
    }

    return text;
  }

  bool isUnlimited(int text, {dynamic remining}) {
    if (text == 0) {
      return true;
    }
    if (remining != null) {
      return false;
    }

    return false;
  }

  int selectedPage = 0;
  Future<void> _onTapSubscribe(subscriptionPackage) async {
    ///
    log('######## ${AppSettings.enabledPaymentGatway}----${AppSettings.razorpayKey}');

    if (subscriptionPackage.price?.toInt() == 0) {
      await context.read<AssignFreePackageCubit>().assign(
            subscriptionPackage.id!,
          );
      return;
    }
    if (Platform.isIOS) {
      await inAppPurchase.buy(
        subscriptionPackage!.iosProductId!,
        subscriptionPackage.id!.toString(),
      );
      print('inAppPurchase.buy');
      return;
    }

    if (!isPaymentGatewayOpen) {
      final paymentService = PaymentService()
        ..targetGatwayKey = AppSettings.enabledPaymentGatway
        ..attachedGatways(gatways)
        ..setContext(context)
        ..setPackage(subscriptionPackage);
      await paymentService.pay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'subscriptionPlan'),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: RefreshIndicator(
        backgroundColor: context.color.primaryColor,
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await interstitialAdManager.show();
            Future.delayed(
              Duration.zero,
              () {
                Navigator.pop(context);
              },
            );
          },
          child: MultiBlocListener(
            listeners: [
              BlocListener<AssignInAppPackageCubit, AssignInAppPackageState>(
                listener: (context, state) {
                  if (state is AssignInAppPackageSuccess) {
                    context.read<FetchSystemSettingsCubit>().fetchSettings(
                          isAnonymous: false,
                          forceRefresh: true,
                        );
                    HelperUtils.showSnackBarMessage(
                      context,
                      'Package Assigned',
                    );
                  }
                },
              ),
            ],
            child: Builder(
              builder: (context) {
                return BlocListener<AssignFreePackageCubit,
                    AssignFreePackageState>(
                  listener: (context, state) {
                    if (state is AssignFreePackageInProgress) {
                      unawaited(Widgets.showLoader(context));
                    }

                    if (state is AssignFreePackageSuccess) {
                      Widgets.hideLoder(context);
                      context
                          .read<FetchSubscriptionPackagesCubit>()
                          .fetchPackages();
                      context.read<FetchSystemSettingsCubit>().fetchSettings(
                            isAnonymous: false,
                            forceRefresh: true,
                          );

                      HelperUtils.showSnackBarMessage(
                        context,
                        'Free package is assigned',
                      );
                    }

                    if (state is AssignFreePackageFail) {
                      Widgets.hideLoder(context);

                      HelperUtils.showSnackBarMessage(
                        context,
                        'Failed to assign free package',
                      );
                    }
                  },
                  child: BlocConsumer<FetchSubscriptionPackagesCubit,
                      FetchSubscriptionPackagesState>(
                    listener:
                        (context, FetchSubscriptionPackagesState state) {},
                    builder: (context, state) {
                      if (state is FetchSubscriptionPackagesInProgress) {
                        return ListView.builder(
                          itemCount: 10,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: CustomShimmer(
                                height: 160,
                              ),
                            );
                          },
                        );
                      }
                      if (state is FetchSubscriptionPackagesFailure) {
                        if (state.errorMessage is NoInternetConnectionError) {
                          return NoInternet(
                            onRetry: () {
                              context
                                  .read<FetchSubscriptionPackagesCubit>()
                                  .fetchPackages();
                            },
                          );
                        }

                        return const SomethingWentWrong();
                      }
                      if (state is FetchSubscriptionPackagesSuccess) {
                        if (state.subscriptionPacakges.isEmpty) {
                          return NoDataFound(
                            onTap: () {
                              context
                                  .read<FetchSubscriptionPackagesCubit>()
                                  .fetchPackages();

                              setState(() {});
                            },
                          );
                        }

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.subscriptionPacakges.length,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemBuilder: (context, index) {
                                  final subscriptionPacakge =
                                      state.subscriptionPacakges[index];

                                  if (subscriptionPacakge.isActive == 1) {
                                    return CurrentPackageTileCard(
                                      package: subscriptionPacakge,
                                    );
                                  }

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: SubscriptionPackageTile(
                                      package: subscriptionPacakge,
                                      onTap: () {
                                        _onTapSubscribe
                                            .call(subscriptionPacakge);
                                      },
                                    ),
                                  );
                                },
                              ),
                              if (state.isLoadingMore) UiUtils.progress(),
                              if (state.hasError)
                                const CustomText('Something went wrong'),
                            ],
                          ),
                        );
                      }

                      return Container();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Row Indicator(FetchSubscriptionPackagesSuccess state, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(state.subscriptionPacakges.length, (index) {
          final isSelected = selectedPage == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border()
                    : Border.all(color: context.color.textColorDark),
                color: isSelected
                    ? context.color.tertiaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget PlanFacilityRow({
    required String icon,
    required String facilityTitle,
    required String count,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            context.color.tertiaryColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(
          width: 11,
        ),
        CustomText(
          '$facilityTitle $count',
          fontSize: context.font.large,
          color: context.color.textColorDark.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget currentPackageTile({
    required String name,
    required String price,
    dynamic advertismentLimit,
    dynamic propertyLimit,
    dynamic duration,
    dynamic startDate,
    dynamic endDate,
    dynamic advertismentRemining,
    dynamic propertyRemining,
  }) {
    ///
    if (endDate != null) {
      endDate = endDate.toString().formatDate();
    }

    return Container(
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: context.screenWidth,
                  child: UiUtils.getSvg(
                    AppIcons.headerCurve,
                    color: context.color.tertiaryColor,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                PositionedDirectional(
                  start: 10.rw(context),
                  top: 8.rh(context),
                  child: CustomText(
                    UiUtils.translate(context, 'currentPackage'),
                    fontWeight: FontWeight.w600,
                    fontSize: context.font.larger,
                    color: context.color.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomText(
                  name,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.larger,
                  color: context.color.textColorDark,
                )),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SubscriptionFeatureLine(
                  title: UiUtils.translate(context, 'adLimitIs'),
                  limit: PackageLimit(advertismentLimit),
                  isTime: false,
                ),
                const Spacer(),
                if (!isUnlimited(
                      advertismentLimit,
                      remining: advertismentRemining,
                    ) &&
                    advertismentLimit != '')
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: LiquidCircularProgressIndicator(
                      value: double.parse(advertismentRemining) /
                          advertismentLimit, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        context.color.tertiaryColor.withValues(alpha: 0.3),
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: context.color.tertiaryColor,
                      borderWidth: 3,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: CustomText(
                          '$advertismentRemining/$advertismentLimit'),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 5.rh(context),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (propertyLimit != null) SubscriptionFeatureLine(),

                    SubscriptionFeatureLine(
                      title: UiUtils.translate(context, 'propertyLimit'),
                      limit: PackageLimit(propertyLimit),
                      isTime: false,
                    ),
                    // bulletPoint(context,
                    //     "${UiUtils.getTranslatedLabel(context, "propertyLimit")} ${propertyLimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(propertyLimit, remining: propertyRemining)}"),
                    SizedBox(
                      height: 5.rh(context),
                    ),
                    // if (isLifeTimeSubscription)
                    //   Row(
                    //     children: [
                    //       SubscriptionFeatureLine(),
                    //       SubscriptionFeatureLine(
                    //         title: UiUtils.getTranslatedLabel(
                    //             context, "propertyLimit"),
                    //         limit: PackageLimit(endDate),
                    //         isTime: true,
                    //       ),
                    //       // bulletPoint(context,
                    //       //     "${UiUtils.getTranslatedLabel(context, "validity")} ${endDate ?? UiUtils.getTranslatedLabel(context, "lifetime")} "),
                    //     ],
                    //   ),
                    SubscriptionFeatureLine(
                      title: UiUtils.translate(context, 'validity'),
                      limit: null,
                      isTime: true,
                      timeLimit: UiUtils.translate(
                            context,
                            'packageStartedOn',
                          ) +
                          startDate +
                          UiUtils.translate(context, 'andPackageWillEndOn') +
                          endDate.toString(),
                    ),
                  ],
                ),
                const Spacer(),
                if (!isUnlimited(propertyLimit, remining: propertyRemining) &&
                    propertyLimit != '')
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: LiquidCircularProgressIndicator(
                      value: double.parse(advertismentRemining) /
                          advertismentLimit, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        context.color.tertiaryColor.withValues(alpha: 0.3),
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: context.color.tertiaryColor,
                      borderWidth: 3,

                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: CustomText(
                          '$advertismentRemining/$advertismentLimit'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPackageTile(
    BuildContext context,
    SubscriptionPackageModel subscriptionPacakge,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                width: context.screenWidth,
                child: UiUtils.getSvg(
                  AppIcons.headerCurve,
                  color: context.color.tertiaryColor,
                  fit: BoxFit.fitWidth,
                ),
              ),
              PositionedDirectional(
                start: 10.rw(context),
                top: 8.rh(context),
                child: CustomText(
                  subscriptionPacakge.name ?? '',
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.larger,
                  color: context.color.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          // if (subscriptionPacakge.advertisementLimit != "not_available")
          SubscriptionFeatureLine(
            limit: PackageLimit(subscriptionPacakge.advertisementLimit),
            isTime: false,
            title: UiUtils.translate(context, 'adLimitIs'),
          ),
          // bulletPoint(context,
          //     "${UiUtils.getTranslatedLabel(context, "adLimitIs")} ${subscriptionPacakge.advertisementLimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(subscriptionPacakge.advertisementLimit)}"),
          SizedBox(
            height: 5.rh(context),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubscriptionFeatureLine(
                    limit: PackageLimit(subscriptionPacakge.propertyLimit),
                    isTime: false,
                    title: UiUtils.translate(context, 'propertyLimit'),
                  ),
                  SizedBox(
                    height: 5.rh(context),
                  ),
                  SubscriptionFeatureLine(
                    limit: null,
                    isTime: true,
                    timeLimit:
                        "${subscriptionPacakge.duration} ${UiUtils.translate(context, "days")}",
                    title: UiUtils.translate(context, 'validity'),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 39.rh(context),
                    constraints: BoxConstraints(
                      minWidth: 80.rw(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CustomText(
                        '${subscriptionPacakge.price}'
                            .formatAmount(prefix: true),
                        fontWeight: FontWeight.bold,
                        fontSize: context.font.large,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: UiUtils.buildButton(
              context,
              onPressed: () async {
                if (subscriptionPacakge.price?.toInt() == 0) {
                  await context.read<AssignFreePackageCubit>().assign(
                        subscriptionPacakge.id!,
                      );
                  return;
                }
                if (Platform.isIOS) {
                  await inAppPurchase.buy(
                    // "android.test.purchased" ??
                    subscriptionPacakge.iosProductId!,
                    subscriptionPacakge.id!.toString(),
                  );
                  return;
                }

                final paymentService = PaymentService()
                  ..targetGatwayKey = AppSettings.enabledPaymentGatway
                  ..attachedGatways(gatways)
                  ..setContext(context)
                  ..setPackage(subscriptionPacakge);
                await paymentService.pay();
              },
              radius: 9,
              height: 33.rh(context),
              buttonTitle: UiUtils.translate(context, 'subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}
