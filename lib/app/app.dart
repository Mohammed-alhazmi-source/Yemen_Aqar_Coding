import 'package:ebroker/data/cubits/home_page_data_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/firebase_options.dart';
import 'package:flutter/material.dart';


PersonalizedInterestSettings personalizedInterestSettings =
    PersonalizedInterestSettings.empty();
AppSettingsDataModel appSettings = fallbackSettingAppSettings;

Future<void> initApp() async {
  ///Note: this file's code is very necessary and sensitive if you change it, this might affect whole app , So change it carefully.
  ///This must be used do not remove this line
  await HiveUtils.initBoxes();
  Api.initInterceptors();

  ///This is the widget to show uncaught runtime error in this custom widget so that user can know in that screen something is wrong instead of grey screen
  SomethingWentWrong.asGlobalErrorBuilder();

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(
    NotificationService.onBackgroundMessageHandler,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    await LoadAppSettings().load(false);
    runApp(const EntryPoint());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    ///Here Fetching property report reasons
    context.read<LanguageCubit>().loadCurrentLanguage();
    final currentTheme = HiveUtils.getCurrentTheme();

    ///Initialized notification services
    LocalAwsomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);

    ///////////////////////////////////////
    /// Initialized dynamic links for share properties feature
    context.read<AppThemeCubit>().changeTheme(currentTheme);

    APICallTrigger.onTrigger(
      () {
        ///THIS WILL be CALLED WHEN USER WILL LOGIN FROM ANONYMOUS USER.
        context.read<LikedPropertiesCubit>().emptyCubit();
        context.read<GetApiKeysCubit>().fetch();
        loadInitialData(
          context,
          loadWithoutDelay: true,
        );
      },
    );

    UiUtils.setContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///Continuously watching theme change
    final currentTheme = context.watch<AppThemeCubit>().state.appTheme;
    return BlocListener<GetApiKeysCubit, GetApiKeysState>(
      listener: (context, state) {
        context.read<GetApiKeysCubit>().setAPIKeys();
      },
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            initialRoute: Routes.splash,
            // App will start from here splash screen is first screen,
            navigatorKey: Constant.navigatorKey,
            //This navigator key is used for Navigate users through notification
            title: Constant.appName,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRouted,
            theme: appThemeData[currentTheme],
            builder: (context, child) {
              ErrorFilter.setContext(context);
              TextDirection direction;
              //here we are languages direction locally
              if (languageState is LanguageLoader) {
                if (languageState.isRTL) {
                  direction = TextDirection.rtl;
                } else {
                  direction = TextDirection.ltr;
                }
              } else {
                direction = TextDirection.ltr;
              }
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                  // textScaleFactor:
                  //     1.0, //set text scale factor to 1 so that this will not resize app's text while user change their system settings text scale
                ),
                child: Directionality(
                  textDirection: direction,
                  //This will convert app direction according to language
                  child: child!,
                ),
              );
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: loadLocalLanguageIfFail(languageState),
          );
        },
      ),
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if (state is LanguageLoader) {
      return Locale(state.languageCode);
    } else if (state is LanguageLoadFail) {
      return const Locale('en');
    }
  }
}

void loadInitialData(
  BuildContext context, {
  bool? loadWithoutDelay,
  bool? forceRefresh,
}) {
  if (context.read<FetchCategoryCubit>().state is! FetchCategorySuccess) {
    context.read<FetchCategoryCubit>().fetchCategories(
          loadWithoutDelay: loadWithoutDelay,
          forceRefresh: forceRefresh,
        );
  }
  context.read<FetchHomePageDataCubit>().fetch(
        forceRefresh: true,
      );
  context.read<FetchNearbyPropertiesCubit>().fetch(
        loadWithoutDelay: loadWithoutDelay,
        forceRefresh: forceRefresh,
      );
  context.read<FetchCityCategoryCubit>().fetchCityCategory(
        loadWithoutDelay: loadWithoutDelay,
        forceRefresh: forceRefresh,
      );
  context.read<FetchRecentPropertiesCubit>().fetch(
        loadWithoutDelay: loadWithoutDelay,
        forceRefresh: forceRefresh,
      );

  if (context.read<AuthenticationCubit>().isAuthenticated()) {
    context.read<GetChatListCubit>().setContext(context);
    context.read<GetChatListCubit>().fetch();
    context.read<FetchPersonalizedPropertyList>().fetch(
          loadWithoutDelay: loadWithoutDelay,
          forceRefresh: forceRefresh,
        );

    PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
      personalizedInterestSettings = value;
    });
  }

  GuestChecker.listen().addListener(() {
    if (GuestChecker.value == false) {
      PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
        personalizedInterestSettings = value;
      });
    }
  });

//    // }
}
