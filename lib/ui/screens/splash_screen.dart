// import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter/foundation.dart';
// import 'package:ebroker/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    locationPermission();
    checkIsUserAuthenticated();
    super.initState();
    getDefaultLanguage(
      () {
        isLanguageLoaded = true;
      },
    );
    MobileAds.instance.initialize();

    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NoInternet(
                onRetry: () async {
                  try {
                    await LoadAppSettings().load(true);
                    if (context.color.brightness == Brightness.light) {
                      context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                    } else {
                      context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                    }
                  } catch (e) {
                    log('no internet');
                  }
                  Future.delayed(
                    Duration.zero,
                    () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.splash,
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      }
    });
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            Api.currencySymbol,
          );
    });
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Future<void> checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
          );
      completeProfileCheck();
    } else {
      //This call will hide sensitive details.
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: true,
          );
    }
  }

  void navigateCheck() {
    ({
      'setting': isSettingsLoaded,
      'language': isLanguageLoaded,
    }).logg;

    if (isSettingsLoaded) {
      navigateToScreen();
    }
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
            arguments: {
              'from': 'login',
            },
          );
        },
      );
    }
  }

  void navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        '1') {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(
          Routes.maintenanceMode,
        );
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': 'main'});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box(HiveKeys.userDetailsBox).get('isGuest') == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(Routes.main, arguments: {'from': 'splash'});
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {
            log('FetchSystemSettings Issue while load system settings ${state.errorMessage}');
          }
          if (state is FetchSystemSettingsSuccess) {
            if (kDebugMode) {
              print('FetchSystemSettingsSuccess');
            }
            final setting = [];
            if (setting.isNotEmpty) {
              if ((setting[0] as Map).containsKey('package_id')) {
                Constant.subscriptionPackageId = '';
              }
            }

            if (state.settings['data'].containsKey('demo_mode')) {
              Constant.isDemoModeOn =
                  state.settings['data']['demo_mode'] ?? false;
            }
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: UiUtils.getSystemUiOverlayStyle(context: context),
          child: Scaffold(
            backgroundColor: context.color.tertiaryColor,
            body: Stack(
              children: [
                Align(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/AppIcon/icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    key: const ValueKey('companylogo'),
                    child: UiUtils.getSvg(AppIcons.companyLogo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future getDefaultLanguage(VoidCallback onSuccess) async {
  try {
    // await Hive.initFlutter();v
    await Hive.openBox(HiveKeys.languageBox);
    await Hive.openBox(HiveKeys.userDetailsBox);
    await Hive.openBox(HiveKeys.authBox);

    if (kDebugMode) {
      print(
        'Here in SplashScreen HiveBox ${Hive.isBoxOpen(HiveKeys.languageBox)}',
      );
    }
    if (kDebugMode) {
      print('${HiveUtils.getLanguage()}');
    }
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      final result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      final code = result['data']['default_language'];

      await Api.get(
        url: Api.getLanguagae,
        queryParameters: {
          Api.languageCode: code,
        },
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          'code': value['data']['code'],
          'data': value['data']['file_name'],
          'name': value['data']['name'],
          'isRTL': value['data']['rtl']?.toString() == '1',
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
    }
  } catch (e, st) {
    log('Error while load default language $st');
  }
}
