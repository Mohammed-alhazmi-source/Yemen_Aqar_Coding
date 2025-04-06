// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_list_screen.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/ui/screens/proprties/my_properties_screen.dart';
import 'package:ebroker/ui/screens/userprofile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

List<PropertyModel> myPropertylist = [];
Map<String, dynamic> searchbody = {};
String selectedcategoryId = '0';
String selectedcategoryName = '';
dynamic selectedCategory;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = '';
dynamic currentVisitingCategory = '';

List<int> navigationStack = [0];

ScrollController homeScreenController = ScrollController();
ScrollController chatScreenController = ScrollController();
ScrollController sellScreenController = ScrollController();
ScrollController rentScreenController = ScrollController();
ScrollController soldScreenController = ScrollController();
ScrollController rentedScreenController = ScrollController();
ScrollController profileScreenController = ScrollController();
ScrollController agentsListScreenController = ScrollController();
ScrollController faqsListScreenController = ScrollController();
ScrollController cityScreenController = ScrollController();

List<ScrollController> controllerList = [
  faqsListScreenController,
  agentsListScreenController,
  homeScreenController,
  chatScreenController,
  if (propertyScreenCurrentPage == 0) ...[
    sellScreenController,
  ] else if (propertyScreenCurrentPage == 1) ...[
    rentScreenController,
  ] else if (propertyScreenCurrentPage == 2) ...[
    soldScreenController,
  ] else if (propertyScreenCurrentPage == 3) ...[
    rentedScreenController,
  ],
  profileScreenController,
];

//
class MainActivity extends StatefulWidget {
  const MainActivity({required this.from, super.key});

  final String from;

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return BlurredRouter(
      builder: (_) => MainActivity(from: arguments['from'] as String),
    );
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  int currtab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List _pageHistory = [];
  late PageController pageController;
  DateTime? currentBackPressTime;

  // Artboard? artboard;
  bool? isReverse;

  // StateMachineController? _controller;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;
  bool showSellRentButton = false;

  ///Animation for sell and rent button
  ///
  late var plusAnimationController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  late final AnimationController _forSellAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 400,
    ),
    reverseDuration: const Duration(
      milliseconds: 400,
    ),
  );
  late final AnimationController _forRentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );

  ///END: Animation for sell and rent button
  late final Animation<double> _sellTween =
      Tween<double>(begin: -50, end: 80).animate(
    CurvedAnimation(
      parent: _forSellAnimationController,
      curve: Curves.easeIn,
    ),
  );
  late final Animation<double> _rentTween =
      Tween<double>(begin: -50, end: 30).animate(
    CurvedAnimation(parent: _forRentController, curve: Curves.easeIn),
  );

  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    plusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    if (appSettings.isUserActive == false) {
      Future.delayed(
        Duration.zero,
        () {
          HiveUtils.logoutUser(context, onLogout: () {});
        },
      );
    }

    GuestChecker.setContext(context);
    GuestChecker.set('main_activity', isGuest: HiveUtils.isGuest());
    final settings = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    final numberWithSuffix =
        settings.getSetting(SystemSetting.numberWithSuffix);
    if (numberWithSuffix == '1') {
      Constant.isNumberWithSuffix = true;
    } else {
      Constant.isNumberWithSuffix = false;
    }

    if (Constant.isDemoModeOn) {
      HiveUtils.setLocation(
        city: 'Bhuj',
        state: 'Gujrat',
        country: 'India',
        longitude: 69.666931,
        latitude: 23.242001,
        placeId: 'ChIJF28LAAniUDkRpnQHr1jzd3A',
      );
    }

    ///this will check if your profile is complete or not if it is incomplete it will redirect you to the edit profile page
    // completeProfileCheck();

    ///This will check for update
    versionCheck(settings);

    ///This will check if location is set or not , If it is not set it will show popup dialoge so you can set for better result
    if (GuestChecker.value == false) {
      locationSetCheck();
    }

//This will init page controller
    initPageController();
  }

  void addHistory(int index) {
    final stack = navigationStack;
    // if (stack.length > 5) {
    //   stack.removeAt(0);
    // } else {
    if (stack.last != index) {
      stack.add(index);
      navigationStack = stack;
    }

    setState(() {});
  }

  void initPageController() {
    pageController = PageController()
      ..addListener(() {
        _pageHistory.insert(0, pageController.page);
      });
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == '' ||
        HiveUtils.getUserDetails().email == '') {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(
            context,
            Routes.completeProfile,
            arguments: {'from': 'login'},
          );
        },
      );
    }
  }

  Future<void> versionCheck(settings) async {
    var remoteVersion = settings.getSetting(
      Platform.isIOS ? SystemSetting.iosVersion : SystemSetting.androidVersion,
    );
    final remote = remoteVersion;

    final forceUpdate = settings.getSetting(SystemSetting.forceUpdate);

    final packageInfo = await PackageInfo.fromPlatform();

    final current = packageInfo.version;

    final currentVersion = HelperUtils.comparableVersion(packageInfo.version);
    if (remoteVersion == null) {
      return;
    }
    remoteVersion = HelperUtils.comparableVersion(
      remoteVersion,
    );

    if (remoteVersion > currentVersion) {
      Constant.isUpdateAvailable = true;
      Constant.newVersionNumber = settings.getSetting(
        Platform.isIOS
            ? SystemSetting.iosVersion
            : SystemSetting.androidVersion,
      );

      Future.delayed(
        Duration.zero,
        () {
          if (forceUpdate == '1') {
            ///This is force update
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                onAccept: () async {
                  if (Platform.isAndroid) {
                    await launchUrl(
                      Uri.parse(
                        Constant.playstoreURLAndroid,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(
                      Uri.parse(
                        Constant.appstoreURLios,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                backAllowedButton: false,
                svgImagePath: AppIcons.update,
                isAcceptContainesPush: true,
                svgImageColor: context.color.tertiaryColor,
                showCancleButton: false,
                title: 'updateAvailable'.translate(context),
                acceptTextColor: context.color.buttonColor,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText('$current>$remote'),
                    CustomText(
                      'newVersionAvailableForce'.translate(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                onAccept: () async {
                  if (Platform.isAndroid) {
                    await launchUrl(
                      Uri.parse(
                        Constant.playstoreURLAndroid,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(
                      Uri.parse(
                        Constant.appstoreURLios,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                svgImagePath: AppIcons.update,
                svgImageColor: context.color.tertiaryColor,
                showCancleButton: true,
                title: 'updateAvailable'.translate(context),
                content: CustomText(
                  'newVersionAvailable'.translate(context),
                ),
              ),
            );
          }
        },
      );
    }
  }

  void locationSetCheck() {
    if (HiveUtils.isShowChooseLocationDialoge() &&
        !HiveUtils.isLocationFilled()) {
      Future.delayed(
        Duration.zero,
        () {
          UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: UiUtils.translate(context, 'setLocation'),
              content: StatefulBuilder(
                builder: (context, update) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        UiUtils.translate(
                          context,
                          'setLocationforBetter',
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            fillColor: WidgetStateProperty.resolveWith(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return context.color.tertiaryColor;
                                } else {
                                  return context.color.primaryColor;
                                }
                              },
                              // context.color.primaryColor,
                            ),
                            value: isChecked,
                            onChanged: (value) {
                              isChecked = value ?? false;
                              update(() {});
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          CustomText(
                              UiUtils.translate(context, 'dontshowagain')),
                        ],
                      ),
                    ],
                  );
                },
              ),
              isAcceptContainesPush: true,
              onCancel: () {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
              },
              onAccept: () async {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
                Navigator.pop(context);

                await Navigator.pushNamed(
                  context,
                  Routes.completeProfile,
                  arguments: {
                    'from': 'chooseLocation',
                    'navigateToHome': true,
                  },
                );
              },
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> checkForMaintenanceMode() async {
    final body = <String, String>{
      Api.type: Api.maintenanceMode,
    };

    final response = await HelperUtils.sendApiRequest(
      Api.apiGetAppSettings,
      body,
      true,
      context,
    );
    final getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        Constant.maintenanceMode = getdata['data'].toString();
        if (Constant.maintenanceMode == '1') {
          setState(() {});
        }
      }
    }
  }

  late List<Widget> pages = [
    HomeScreen(from: widget.from),
    const ChatListScreen(),
    const CustomText(''),
    const PropertiesScreen(),
    const ProfileScreen(),
  ];

  bool isProfileCompleted = HiveUtils.getUserDetails().email != '' &&
      HiveUtils.getUserDetails().mobile != '' &&
      HiveUtils.getUserDetails().name != '' &&
      HiveUtils.getUserDetails().address != '' &&
      HiveUtils.getUserDetails().profile != '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final length = navigationStack.length;
          if (length == 1 && navigationStack[0] == 0) {
            final now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              await Fluttertoast.showToast(
                msg: 'pressAgainToExit'.translate(context),
              );
              return Future.value(false);
            }
          } else {
            //This will put our page on previous page.
            final secondLast = navigationStack[length - 2];
            navigationStack.removeLast();
            pageController.jumpToPage(secondLast);
            setState(() {});
            return Future.value(false);
          }

          Future.delayed(Duration.zero, () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          });
        },
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          bottomNavigationBar:
              Constant.maintenanceMode == '1' ? null : bottomBar(),
          body: Stack(
            children: <Widget>[
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: onItemSwipe,
                children: pages,
              ),
              if (Constant.maintenanceMode == '1')
                Container(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight,
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _forRentController,
                      builder: (context, c) {
                        return Positioned(
                          bottom: _rentTween.value,
                          left: (context.screenWidth / 2) - (181 / 2),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                if (Constant.isDemoModeOn) {
                                  await HelperUtils.showSnackBarMessage(
                                    context,
                                    'thisActionNotValidDemo'.translate(context),
                                  );
                                } else if (AppSettings.isVerificationRequired ==
                                        true &&
                                    isProfileCompleted != true) {
                                  await UiUtils.showBlurredDialoge(
                                    context,
                                    dialoge: BlurredDialogBox(
                                      title:
                                          'completeProfile'.translate(context),
                                      isAcceptContainesPush: true,
                                      onAccept: () async {
                                        await Navigator.popAndPushNamed(
                                          context,
                                          Routes.completeProfile,
                                          arguments: {
                                            'from': 'home',
                                            'navigateToHome': true
                                          },
                                        );
                                      },
                                      content: HiveUtils.getUserDetails()
                                                      .profile ==
                                                  '' &&
                                              (HiveUtils.getUserDetails()
                                                          .name !=
                                                      '' &&
                                                  HiveUtils.getUserDetails()
                                                          .email !=
                                                      '' &&
                                                  HiveUtils.getUserDetails()
                                                          .address !=
                                                      '')
                                          ? CustomText('uploadProfilePicture'
                                              .translate(context))
                                          : CustomText(
                                              'completeProfileFirst'
                                                  .translate(context),
                                            ),
                                    ),
                                  );
                                } else {
                                  unawaited(Widgets.showLoader(context));
                                  final systemRepository = SystemRepository();
                                  final settings = await systemRepository
                                      .fetchSystemSettings(
                                    isAnonymouse: false,
                                  );
                                  if (settings['data']['is_premium'] == true) {
                                    Widgets.hideLoder(context);
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.selectPropertyTypeScreen,
                                      arguments: {
                                        'type': PropertyAddType.property,
                                      },
                                    );
                                  } else {
                                    Widgets.hideLoder(context);
                                    GuestChecker.check(
                                      onNotGuest: () async {
                                        await UiUtils.showBlurredDialoge(
                                          context,
                                          dialoge: BlurredDialogBox(
                                            title: 'Subscription needed',
                                            isAcceptContainesPush: true,
                                            onAccept: () async {
                                              await Navigator.popAndPushNamed(
                                                context,
                                                Routes
                                                    .subscriptionPackageListRoute,
                                                arguments: {'from': 'home'},
                                              );
                                            },
                                            content: CustomText(
                                              'subscribeToUseThisFeature'
                                                  .translate(context),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  Widgets.hideLoder(context);
                                }
                              } catch (e) {
                                Widgets.hideLoder(context);
                                await HelperUtils.showSnackBarMessage(
                                  context,
                                  'somethingWentWrng'.translate(context),
                                );
                              }
                            },
                            child: Container(
                              width: 181,
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.color.borderColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiaryColor
                                        .withValues(alpha: 0.4),
                                    offset: const Offset(0, 3),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: context.color.tertiaryColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  UiUtils.getSvg(
                                    AppIcons.propertiesIcon,
                                    color: context.color.buttonColor,
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: 7.rw(context),
                                  ),
                                  CustomText(
                                    'property'.translate(context),
                                    color: context.color.buttonColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _forSellAnimationController,
                      builder: (context, c) {
                        return Positioned(
                          bottom: _sellTween.value,
                          left: (context.screenWidth / 2) - 128 / 2,
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                if (Constant.isDemoModeOn) {
                                  await HelperUtils.showSnackBarMessage(
                                    context,
                                    'thisActionNotValidDemo'.translate(context),
                                  );
                                } else if (AppSettings.isVerificationRequired ==
                                        true &&
                                    isProfileCompleted != true) {
                                  await UiUtils.showBlurredDialoge(
                                    context,
                                    dialoge: BlurredDialogBox(
                                      title:
                                          'completeProfile'.translate(context),
                                      isAcceptContainesPush: true,
                                      onAccept: () async {
                                        await Navigator.popAndPushNamed(
                                          context,
                                          Routes.completeProfile,
                                          arguments: {
                                            'from': 'home',
                                            'navigateToHome': true
                                          },
                                        );
                                      },
                                      content: CustomText(
                                        'completeProfile'.translate(context),
                                      ),
                                    ),
                                  );
                                } else {
                                  unawaited(Widgets.showLoader(context));
                                  final systemRepository = SystemRepository();
                                  final settings = await systemRepository
                                      .fetchSystemSettings(
                                    isAnonymouse: false,
                                  );
                                  if (settings['data']['is_premium'] == true) {
                                    Widgets.hideLoder(context);
                                    GuestChecker.check(
                                      onNotGuest: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.selectPropertyTypeScreen,
                                          arguments: {
                                            'type': PropertyAddType.project,
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    Widgets.hideLoder(context);
                                    GuestChecker.check(
                                      onNotGuest: () async {
                                        await UiUtils.showBlurredDialoge(
                                          context,
                                          dialoge: BlurredDialogBox(
                                            title: 'Subscription needed',
                                            isAcceptContainesPush: true,
                                            onAccept: () async {
                                              await Navigator.popAndPushNamed(
                                                context,
                                                Routes
                                                    .subscriptionPackageListRoute,
                                                arguments: {'from': 'home'},
                                              );
                                            },
                                            content: CustomText(
                                              'subscribeToUseThisFeature'
                                                  .translate(context),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  Widgets.hideLoder(context);
                                }
                              } catch (e) {
                                Widgets.hideLoder(context);
                                await HelperUtils.showSnackBarMessage(
                                  context,
                                  'somethingWentWrng'.translate(context),
                                );
                              }
                            },
                            child: Container(
                              width: 128,
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.color.borderColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiaryColor
                                        .withValues(alpha: 0.4),
                                    offset: const Offset(0, 3),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: context.color.tertiaryColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UiUtils.getSvg(
                                    AppIcons.upcomingProject,
                                    color: context.color.buttonColor,
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: 7.rw(context),
                                  ),
                                  CustomText(
                                    UiUtils.translate(context, 'project'),
                                    color: context.color.buttonColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    addHistory(index);

    if (index == currtab) {
      var xIndex = index;

      if (xIndex == 3) {
        xIndex = 2;
      } else if (xIndex == 4) {
        xIndex = 3;
      }
      if (controllerList[xIndex].hasClients) {
        controllerList[xIndex].animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceOut,
        );
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
    isReverse = true;
    plusAnimationController.reverse();
    _forSellAnimationController.reverse();
    _forRentController.reverse();

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = '';
      }
    }
    searchbody = {};
    if (index == 1 || index == 3) {
      GuestChecker.check(
        onNotGuest: () {
          currtab = index;
          pageController.jumpToPage(currtab);
          setState(
            () {},
          );
        },
      );
    } else {
      currtab = index;
      pageController.jumpToPage(currtab);

      setState(() {});
    }
  }

  double degreesToQuarterTurns(double degrees) {
    return degrees / 90;
  }

  void onItemSwipe(int index) {
    addHistory(index);

    FocusManager.instance.primaryFocus?.unfocus();
    isReverse = true;
    plusAnimationController.reverse();
    _forSellAnimationController.reverse();
    _forRentController.reverse();

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = '';
      }
    }
    searchbody = {};
    setState(() {
      currtab = index;
    });
    pageController.jumpToPage(currtab);
  }

  BottomAppBar bottomBar() {
    return BottomAppBar(
      // notchMargin: 10.0,
      color: context.color.primaryColor,
      shape: const CircularNotchedRectangle(),
      child: ColoredBox(
        color: context.color.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            buildBottomNavigationbarItem(
              0,
              AppIcons.home,
              UiUtils.translate(context, 'homeTab'),
            ),
            buildBottomNavigationbarItem(
              1,
              AppIcons.chat,
              UiUtils.translate(context, 'chat'),
            ),
            Transform(
              transform: Matrix4.identity()..translate(0.toDouble(), -20),
              child: SizedBox(
                width: 60.rw(context),
                height: 66,
                child: Stack(
                  children: [
                    Center(
                      child: UiUtils.getSvg(
                        AppIcons.addButtonShape,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isReverse ?? true) {
                          plusAnimationController.forward();
                          isReverse = false;
                          showSellRentButton = true;
                          _forRentController.forward();
                          _forSellAnimationController.forward();
                        } else {
                          plusAnimationController.reverse();
                          showSellRentButton = false;
                          isReverse = true;
                          _forRentController.reverse();
                          _forSellAnimationController.reverse();
                        }
                        setState(() {});
                      },
                      child: AnimatedBuilder(
                        animation: plusAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: plusAnimationController.value *
                                (3 *
                                    3.1415926535897932 /
                                    4), // Rotate 135 degrees
                            child: child,
                          );
                        },
                        child: Center(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(19),
                            child: UiUtils.getSvg(
                              AppIcons.plusButtonIcon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildBottomNavigationbarItem(
              3,
              AppIcons.properties,
              UiUtils.translate(context, 'properties'),
            ),
            buildBottomNavigationbarItem(
              4,
              AppIcons.profileOutlined,
              UiUtils.translate(context, 'profileTab'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
    int index,
    String svgImage,
    String title,
  ) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currtab == index) ...{
                UiUtils.getSvg(svgImage, color: context.color.tertiaryColor),
              } else ...{
                UiUtils.getSvg(svgImage, color: context.color.textLightColor),
              },
              CustomText(
                title,
                textAlign: TextAlign.center,
                color: currtab == index
                    ? context.color.tertiaryColor
                    : context.color.textLightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
