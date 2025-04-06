import 'dart:developer';

import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  ValueNotifier isDarkTheme = ValueNotifier(false);
  String verificationStatus = '';
  bool isGuest = false;
  @override
  void initState() {
    final settings = context.read<FetchSystemSettingsCubit>();

    isGuest = GuestChecker.value;
    GuestChecker.listen().addListener(() {
      isGuest = GuestChecker.value;
      if (mounted) setState(() {});
    });
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    isDarkTheme.value = context.read<AppThemeCubit>().isDarkMode();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isDarkTheme.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
  int? a;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = context.watch<FetchSystemSettingsCubit>();
    verificationStatus =
        settings.getSetting(SystemSetting.verificationStatus) ?? '';
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    var username = 'anonymous'.translate(context);
    var email = 'notLoggedIn'.translate(context);
    if (!isGuest) {
      final user = context.watch<UserDetailsCubit>().state.user;
      username = user?.name!.firstUpperCase() ?? 'anonymous'.translate(context);
      email = user?.email ?? 'notLoggedIn'.translate(context);
    }
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'myProfile'),
      ),
      body: BlocListener<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountProgress) {
            unawaited(Widgets.showLoader(context));
          }
          if (state is DeleteAccountFailure) {
            Widgets.hideLoder(context);
          }
          if (state is AccountDeleted) {
            Widgets.hideLoder(context);
            context.read<UserDetailsCubit>().clear();
            Navigator.pushReplacementNamed(
              context,
              Routes.login,
              arguments: {'popToCurrent': false},
            );
          }
        },
        child: RefreshIndicator(
          color: context.color.tertiaryColor,
          onRefresh: () async {
            await context.read<FetchSystemSettingsCubit>().fetchSettings(
                  isAnonymous: false,
                  forceRefresh: true,
                );
          },
          child: ScrollConfiguration(
            behavior: RemoveGlow(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: profileScreenController,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: context.color.borderColor,
                        ),
                        color: context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: profileImgWidget(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomText(
                                  username,
                                  color: context.color.inverseSurface,
                                  fontSize: context.font.large,
                                  fontWeight: FontWeight.w700,
                                ),
                                CustomText(
                                  email,
                                  color: context.color.textColorDark,
                                  fontSize: context.font.small,
                                  maxLines: 1,
                                ),
                                if (isGuest == false)
                                  const SizedBox(height: 10),
                                if (isGuest == false)
                                  _buildVerificationUI(
                                    context,
                                    verificationStatus,
                                  ),
                              ],
                            ),
                          ),
                          if (isGuest == true)
                            Container(
                              margin: const EdgeInsetsDirectional.only(
                                end: 20,
                              ),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: context.color.borderColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.login,
                                    arguments: {'popToCurrent': false},
                                  );
                                  ;
                                },
                                child: CustomText('login'.translate(context)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: context.color.borderColor,
                        ),
                        color: context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          if (isGuest == false)
                            customTile(
                              context,
                              title: UiUtils.translate(context, 'editProfile'),
                              svgImagePath: AppIcons.profile,
                              onTap: () {
                                HelperUtils.goToNextPage(
                                  Routes.completeProfile,
                                  context,
                                  false,
                                  args: {'from': 'profile'},
                                );
                              },
                            ),
                          if (isGuest == false) dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'myProjects'),
                            svgImagePath: AppIcons.upcomingProject,
                            onTap: () async {
                              GuestChecker.check(
                                onNotGuest: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    Routes.projectListScreen,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'myAds'),
                            svgImagePath: AppIcons.promoted,
                            onTap: () async {
                              GuestChecker.check(
                                onNotGuest: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    Routes.myAdvertisment,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'subscription'),
                            svgImagePath: AppIcons.subscription,
                            onTap: () async {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.subscriptionPackageListRoute,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(
                              context,
                              'transactionHistory',
                            ),
                            svgImagePath: AppIcons.transaction,
                            onTap: () {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.transactionHistory,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(
                              context,
                              'personalized',
                            ),
                            svgImagePath: AppIcons.magic,
                            onTap: () {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.personalizedPropertyScreen,
                                    arguments: {
                                      'type': PersonalizedVisitType.Normal,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(
                              context,
                              'faqScreen',
                            ),
                            svgImagePath: AppIcons.faqs,
                            onTap: () {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.faqsScreen,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'language'),
                            svgImagePath: AppIcons.language,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.languageListScreenRoute,
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          ValueListenableBuilder(
                            valueListenable: isDarkTheme,
                            builder: (context, v, c) {
                              return customTile(
                                context,
                                title: UiUtils.translate(context, 'darkTheme'),
                                svgImagePath: AppIcons.darkTheme,
                                isSwitchBox: true,
                                onTapSwitch: (value) {
                                  context.read<AppThemeCubit>().changeTheme(
                                        value == true
                                            ? AppTheme.dark
                                            : AppTheme.light,
                                      );
                                  setState(() {
                                    isDarkTheme.value = value;
                                  });
                                },
                                switchValue: v,
                                onTap: () {},
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'notifications'),
                            svgImagePath: AppIcons.notification,
                            onTap: () {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.notificationPage,
                                  );
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'articles'),
                            svgImagePath: AppIcons.articles,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.articlesScreenRoute,
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'favorites'),
                            svgImagePath: AppIcons.favorites,
                            onTap: () {
                              GuestChecker.check(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.favoritesScreen,
                                  );
                                },
                              );
                            },
                          ),
                          // TODO(R): Enable this when mortgage calculator is ready
                          // dividerWithSpacing(),
                          // customTile(
                          //   context,
                          //   title: UiUtils.translate(
                          //     context,
                          //     'mortgageCalculator',
                          //   ),
                          //   svgImagePath: AppIcons.areaConvertor,
                          //   onTap: () {
                          //     Navigator.pushNamed(
                          //       context,
                          //       Routes.mortgageCalculatorScreen,
                          //     );
                          //   },
                          // ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'areaConvertor'),
                            svgImagePath: AppIcons.areaConvertor,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.areaConvertorScreen,
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'shareApp'),
                            svgImagePath: AppIcons.shareApp,
                            onTap: shareApp,
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'rateUs'),
                            svgImagePath: AppIcons.rateUs,
                            onTap: rateUs,
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'contactUs'),
                            svgImagePath: AppIcons.contactUs,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.contactUs,
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'aboutUs'),
                            svgImagePath: AppIcons.aboutUs,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.profileSettings,
                                arguments: {
                                  'title':
                                      UiUtils.translate(context, 'aboutUs'),
                                  'param': Api.aboutApp,
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(
                              context,
                              'termsConditions',
                            ),
                            svgImagePath: AppIcons.terms,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.profileSettings,
                                arguments: {
                                  'title': UiUtils.translate(
                                    context,
                                    'termsConditions',
                                  ),
                                  'param': Api.termsAndConditions,
                                },
                              );
                            },
                          ),
                          dividerWithSpacing(),
                          customTile(
                            context,
                            title: UiUtils.translate(context, 'privacyPolicy'),
                            svgImagePath: AppIcons.privacy,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.profileSettings,
                                arguments: {
                                  'title': UiUtils.translate(
                                    context,
                                    'privacyPolicy',
                                  ),
                                  'param': Api.privacyPolicy,
                                },
                              );
                            },
                          ),
                          if (Constant.isUpdateAvailable == true) ...[
                            dividerWithSpacing(),
                            updateTile(
                              context,
                              isUpdateAvailable: Constant.isUpdateAvailable,
                              title: UiUtils.translate(context, 'update'),
                              newVersion: Constant.newVersionNumber,
                              svgImagePath: AppIcons.update,
                              onTap: () async {
                                if (Platform.isIOS) {
                                  await launchUrl(
                                    Uri.parse(Constant.appstoreURLios),
                                  );
                                } else if (Platform.isAndroid) {
                                  await launchUrl(
                                    Uri.parse(Constant.playstoreURLAndroid),
                                  );
                                }
                              },
                            ),
                          ],
                          if (isGuest == false) ...[
                            dividerWithSpacing(),
                            customTile(
                              context,
                              title:
                                  UiUtils.translate(context, 'deleteAccount'),
                              svgImagePath: AppIcons.delete,
                              onTap: () {
                                if (Constant.isDemoModeOn &&
                                    context
                                            .read<UserDetailsCubit>()
                                            .state
                                            .user
                                            ?.authId ==
                                        Constant.demoFirebaseID) {
                                  HelperUtils.showSnackBarMessage(
                                    context,
                                    UiUtils.translate(
                                      context,
                                      'thisActionNotValidDemo',
                                    ),
                                  );
                                  return;
                                }

                                deleteConfirmWidget(
                                  UiUtils.translate(
                                    context,
                                    'deleteProfileMessageTitle',
                                  ),
                                  UiUtils.translate(
                                    context,
                                    'deleteProfileMessageContent',
                                  ),
                                  true,
                                );
                              },
                            ),
                          ],
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    if (isGuest == false) ...[
                      UiUtils.buildButton(
                        context,
                        onPressed: logOutConfirmWidget,
                        height: 52.rh(context),
                        prefixWidget: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: UiUtils.getSvg(
                                AppIcons.logout,
                                color: context.color.tertiaryColor,
                              ),
                            ),
                          ),
                        ),
                        buttonTitle: UiUtils.translate(context, 'logout'),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding dividerWithSpacing() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: UiUtils.getDivider(),
    );
  }

  Widget updateTile(
    BuildContext context, {
    required String title,
    required String newVersion,
    required bool isUpdateAvailable,
    required String svgImagePath,
    required VoidCallback onTap,
    Function(dynamic value)? onTapSwitch,
    dynamic switchValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () {
          if (isUpdateAvailable) {
            onTap.call();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor
                    .withValues(alpha: 0.10000000149011612),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.none,
                child: isUpdateAvailable == false
                    ? const Icon(Icons.done)
                    : UiUtils.getSvg(
                        svgImagePath,
                        color: context.color.tertiaryColor,
                      ),
              ),
            ),
            SizedBox(
              width: 25.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  isUpdateAvailable == false
                      ? 'uptoDate'.translate(context)
                      : title,
                  fontWeight: FontWeight.w700,
                  color: context.color.textColorDark,
                ),
                if (isUpdateAvailable)
                  CustomText(
                    'v$newVersion',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: context.color.textColorDark,
                    fontSize: context.font.small,
                  ),
              ],
            ),
            if (isUpdateAvailable) ...[
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: context.color.borderColor, width: 1.5),
                  color: context.color.secondaryColor
                      .withValues(alpha: 0.10000000149011612),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: SizedBox(
                    width: 8,
                    height: 15,
                    child: UiUtils.getSvg(
                      AppIcons.arrowRight,
                      matchTextDirection: true,
                      color: context.color.textColorDark,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget customTile(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    required VoidCallback onTap,
    bool? isSwitchBox,
    Function(dynamic value)? onTapSwitch,
    dynamic switchValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          absorbing: !(isSwitchBox ?? false),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor
                      .withValues(alpha: 0.10000000149011612),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: UiUtils.getSvg(
                    svgImagePath,
                    height: 24,
                    width: 24,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: 25.rw(context),
              ),
              Expanded(
                flex: 3,
                child: CustomText(
                  title,
                  fontWeight: FontWeight.w700,
                  color: context.color.textColorDark,
                ),
              ),
              const Spacer(),
              if (isSwitchBox != true)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.color.borderColor,
                      width: 1.5,
                    ),
                    color: context.color.secondaryColor
                        .withValues(alpha: 0.10000000149011612),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: SizedBox(
                      width: 8,
                      height: 15,
                      child: UiUtils.getSvg(
                        AppIcons.arrowRight,
                        matchTextDirection: true,
                        color: context.color.textColorDark,
                      ),
                    ),
                  ),
                ),
              if (isSwitchBox ?? false)
                // CupertinoSwitch(value: value, onChanged: onChanged)
                SizedBox(
                  height: 40,
                  width: 30,
                  child: CupertinoSwitch(
                    activeTrackColor: context.color.tertiaryColor,
                    value: switchValue ?? false,
                    onChanged: (value) {
                      onTapSwitch?.call(value);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteConfirmWidget(String title, String desc, callDel) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: title,
        content: CustomText(desc, textAlign: TextAlign.center),
        acceptButtonName: 'deleteBtnLbl'.translate(context),
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.deleteIcon,
        isAcceptContainesPush: true,
        onAccept: () async {
          final L = HiveUtils.getUserLoginType();
          Navigator.of(context).pop();
          if (callDel) {
            Future.delayed(
              const Duration(microseconds: 100),
              () async {
                unawaited(Widgets.showLoader(context));
                try {
                  // throw FirebaseAuthException(code: "requires-recent-login");
                  if (L == LoginType.phone &&
                      AppSettings.otpServiceProvider == 'firebase') {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }
                  if (L == LoginType.apple || L == LoginType.google) {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }

                  await context.read<DeleteAccountCubit>().deleteAccount(
                        context,
                      );
                  if (L == LoginType.email) {
                    Constant.favoritePropertyList.clear();
                    Constant.interestedPropertyIds.clear();
                    context.read<LikedPropertiesCubit>().state.liked.clear();
                    context.read<LikedPropertiesCubit>().clear();
                    context.read<LoadChatMessagesCubit>().close();
                  }
                  Widgets.hideLoder(context);
                  context.read<UserDetailsCubit>().clear();
                  await Navigator.pushReplacementNamed(
                    context,
                    Routes.login,
                    arguments: {'popToCurrent': true},
                  );
                } catch (e) {
                  Widgets.hideLoder(context);
                  if (e is FirebaseAuthException) {
                    if (e.code == 'requires-recent-login') {
                      await UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                            title: 'Recent login required'.translate(context),
                            acceptTextColor: context.color.buttonColor,
                            showCancleButton: false,
                            content: CustomText(
                              'logoutAndLoginAgain'.translate(context),
                              textAlign: TextAlign.center,
                            )),
                      );
                    }
                  } else {
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialoge: BlurredDialogBox(
                        title: 'somethingWentWrng'.translate(context),
                        acceptTextColor: context.color.buttonColor,
                        showCancleButton: false,
                        content: CustomText(e.toString() ?? ''),
                      ),
                    );
                  }
                }
              },
            );
          } else {
            await HiveUtils.logoutUser(
              context,
              onLogout: () {},
            );
          }
        },
      ),
    );
  }

  Widget profileImgWidget() {
    return GestureDetector(
      onTap: () {
        UiUtils.showFullScreenImage(
          context,
          provider: NetworkImage(
            context.read<UserDetailsCubit>().state.user?.profile ?? '',
          ),
        );
      },
      child: (context.watch<UserDetailsCubit>().state.user?.profile ?? '')
              .trim()
              .isEmpty
          ? buildDefaultPersonSVG(context)
          : Image.network(
              context.watch<UserDetailsCubit>().state.user?.profile ?? '',
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (
                BuildContext context,
                Object exception,
                StackTrace? stackTrace,
              ) {
                return buildDefaultPersonSVG(context);
              },
              loadingBuilder: (
                BuildContext context,
                Widget? child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child!;
                return buildDefaultPersonSVG(context);
              },
            ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: context.color.tertiaryColor.withValues(alpha: 0.1),
      child: FittedBox(
        fit: BoxFit.none,
        child: UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 32,
          height: 32,
        ),
      ),
    );
  }

  void shareApp() {
    try {
      if (Platform.isAndroid) {
        Share.share(
          '${Constant.appName}\n${Constant.playstoreURLAndroid}\n${Constant.shareappText}',
          subject: Constant.appName,
        );
      } else {
        Share.share(
          '${Constant.appName}\n${Constant.appstoreURLios}\n${Constant.shareappText}',
          subject: Constant.appName,
        );
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  Future<void> rateUs() async {
    await LaunchReview.launch(
      androidAppId: Constant.androidPackageName,
      iOSAppId: Constant.iOSAppId,
    );
  }

  void logOutConfirmWidget() {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: UiUtils.translate(context, 'confirmLogoutTitle'),
        onAccept: () async {
          try {
            final L = HiveUtils.getUserLoginType();
            if (L == LoginType.email) {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.favoritePropertyList.clear();
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().state.liked.clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'twilio') {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.favoritePropertyList.clear();
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().state.liked.clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'firebase') {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.favoritePropertyList.clear();
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().state.liked.clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.google || L == LoginType.apple) {
              Future.delayed(
                Duration.zero,
                () {
                  Constant.favoritePropertyList.clear();
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().state.liked.clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().close();
                  HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
              await GoogleSignIn().signOut();
            }
          } catch (e) {
            log('Issue while logout is $e');
          }
        },
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.logoutIcon,
        content: CustomText(UiUtils.translate(context, 'confirmLogOutMsg')),
      ),
    );
  }

  Widget _buildVerificationUI(BuildContext context, String status) {
    const verifyButtonPadding = EdgeInsetsDirectional.only(
      start: 4,
      end: 8,
      top: 2,
      bottom: 2,
    );
    switch (status) {
      case 'initial':
        return GestureDetector(
          onTap: () async {
            final systemRepository = SystemRepository();
            final fetchSystemSettings =
                await systemRepository.fetchSystemSettings(
              isAnonymouse: false,
            );
            if (fetchSystemSettings['data']['verification_status'] ==
                'initial') {
              HelperUtils.goToNextPage(
                Routes.agentVerificationForm,
                context,
                false,
              );
            } else {
              await HelperUtils.showSnackBarMessage(
                context,
                'formAlreadySubmitted'.translate(context),
              );
            }
          },
          child: Container(
            padding: verifyButtonPadding,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 2,
                  ),
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: UiUtils.getSvg(
                      AppIcons.agentBadge,
                      height: 24,
                      width: 24,
                      color: context.color.inversePrimary,
                    ),
                  ),
                ),
                CustomText(
                  'verifyNow'.translate(context),
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.normal,
                  color: context.color.inversePrimary,
                ),
              ],
            ),
          ),
        );
      case 'pending':
        return Container(
          padding: verifyButtonPadding,
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 4,
              ),
              const Icon(
                Icons.access_time_filled_rounded,
                color: Colors.orangeAccent,
              ),
              const SizedBox(
                width: 2,
              ),
              CustomText(
                'verificationPending'.translate(context),
                fontWeight: FontWeight.bold,
                fontSize: context.font.normal,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        );
      case 'success':
        return Container(
          padding: verifyButtonPadding,
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: UiUtils.getSvg(
                    AppIcons.agentBadge,
                    height: 24,
                    width: 24,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              CustomText(
                'verified'.translate(context),
                fontWeight: FontWeight.bold,
                fontSize: context.font.normal,
                color: context.color.tertiaryColor,
              ),
            ],
          ),
        );
      case 'failed':
        return GestureDetector(
          onTap: () async {
            final systemRepository = SystemRepository();
            final fetchSystemSettings =
                await systemRepository.fetchSystemSettings(
              isAnonymouse: false,
            );
            if (fetchSystemSettings['data']['verification_status'] ==
                'failed') {
              HelperUtils.goToNextPage(
                Routes.agentVerificationForm,
                context,
                false,
              );
            } else {
              await HelperUtils.showSnackBarMessage(
                context,
                'formAlreadySubmitted'.translate(context),
              );
            }
          },
          child: Container(
            padding: verifyButtonPadding,
            decoration: BoxDecoration(
              color: context.color.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                  ),
                  child: Icon(
                    Icons.cancel_rounded,
                    color: context.color.error,
                  ),
                ),
                const SizedBox(width: 2),
                CustomText(
                  'formRejected'.translate(context),
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.normal,
                  color: context.color.error,
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
