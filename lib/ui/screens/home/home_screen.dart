// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:ebroker/data/cubits/home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:ebroker/data/helper/design_configs.dart';
import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/home_slider.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agents_card.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_card_big.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/category_card.dart';
import 'package:ebroker/ui/screens/home/widgets/header_card.dart';
import 'package:ebroker/ui/screens/home/widgets/homeListener.dart';
import 'package:ebroker/ui/screens/home/widgets/home_search.dart';
import 'package:ebroker/ui/screens/home/widgets/home_shimmers.dart';
import 'package:ebroker/ui/screens/home/widgets/location_widget.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/admob/bannerAdLoadWidget.dart';
import 'package:ebroker/utils/network/networkAvailability.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
// JWT Token

const double sidePadding = 18;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return BlurredRouter(
      builder: (_) => HomeScreen(from: arguments['from'] as String),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  HomePageStateListener homeStateListener = HomePageStateListener();

  @override
  void initState() {
    DeepLinkManager.initDeepLinks(context);
    context.read<HomePageInfinityScrollCubit>().fetch();
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    AppLinks().getInitialLink().then((value) {
      if (value == null) return;
    });
    AppLinks().uriLinkStream.listen((event) {});

    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker(context);
    fetchApiKeys();
    initializeHomeStateListener();
    super.initState();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    homeScreenController.addListener(pageScrollListener);
  }

  void initializeHomeStateListener() {
    homeStateListener.init(
      setState,
      onNetAvailable: () {
        if (mounted) {
          loadInitialData(
            loadWithoutDelay: true,
            context,
          );
        }
      },
    );
  }

  void fetchApiKeys() {
    if (context.read<AuthenticationCubit>().isAuthenticated()) {
      context.read<GetApiKeysCubit>().fetch();
    }
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (homeScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<HomePageInfinityScrollCubit>().hasMoreData()) {
          context.read<HomePageInfinityScrollCubit>().fetchMore();
        }
      }
    }
  }

  void _onTapPromotedSeeAll() {
    Navigator.pushNamed(context, Routes.promotedPropertiesScreen);
  }

  void _onTapNearByPropertiesAll() {
    final StateMap stateMap = StateMap<
        FetchNearbyPropertiesInitial,
        FetchNearbyPropertiesInProgress,
        FetchNearbyPropertiesSuccess,
        FetchNearbyPropertiesFailure>();

    ViewAllScreen<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      title: 'nearByProperties'.translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onTapMostLikedAll() {
    Navigator.pushNamed(context, Routes.mostLikedPropertiesScreen);
  }

  void _onTapMostViewedSeeAll() {
    Navigator.pushNamed(context, Routes.mostViewedPropertiesScreen);
  }

  void _onRefresh() {
    context.read<FetchNearbyPropertiesCubit>().fetch(
          forceRefresh: true,
        );
    context.read<FetchCityCategoryCubit>().fetchCityCategory(
          forceRefresh: true,
        );
    context.read<FetchPersonalizedPropertyList>().fetch(
          forceRefresh: true,
        );
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: true,
        );
    context.read<HomePageInfinityScrollCubit>().fetch();
    if (GuestChecker.value == false) {
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
            forceRefresh: true,
          );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeScreenState = homeStateListener.listen(context);
    HiveUtils.getJWT()?.log('JWT');

    ///
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
        elevation: 0,
        leadingWidth: (HiveUtils.getCityName() != null &&
                HiveUtils.getCityName().toString().isNotEmpty)
            ? 200.rw(context)
            : 130,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(
            start: sidePadding.rw(context),
          ),
          child: (HiveUtils.getCityName() != null &&
                  HiveUtils.getCityName().toString().isNotEmpty)
              ? const LocationWidget()
              : LoadAppSettings().loadHomeLogo(appSettings.appHomeScreen!),
        ),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      ),
      backgroundColor: context.color.primaryColor,
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await CheckInternet.check(
            onInternet: () {
              _onRefresh();
            },
            onNoInternet: () {
              HelperUtils.showSnackBarMessage(
                context,
                'noInternet'.translate(context),
              );
            },
          );
        },
        child: Builder(
          builder: (context) {
            if (homeScreenState.state == HomeScreenDataState.fail) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  alignment: Alignment.topCenter,
                  height: context.screenHeight - 235,
                  child: const SomethingWentWrong(),
                ),
              );
            }
            return BlocConsumer<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                if (state is FetchHomePageDataLoading) {
                  const HomeShimmer();
                  homeStateListener.setNetworkState(setState, true);
                  setState(() {});
                }
                if (state is FetchSystemSettingsSuccess) {
                  homeStateListener.setNetworkState(setState, true);
                  setState(() {});
                }
              },
              builder: (context, state) {
                if (homeScreenState.state == HomeScreenDataState.nointernet) {
                  return NoInternet(
                    onRetry: () {
                      CheckInternet.check(
                        onInternet: () {
                          _onRefresh();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        onNoInternet: () {
                          HelperUtils.showSnackBarMessage(
                            context,
                            'noInternet'.translate(context),
                          );
                        },
                      );
                    },
                  );
                }
                return BlocBuilder<FetchHomePageDataCubit,
                    FetchHomePageDataState>(
                  builder: (homeContext, homeState) {
                    if (homeState is FetchHomePageDataLoading) {
                      return const HomeShimmer();
                    }
                    if (homeState is FetchHomePageDataSuccess) {
                      final home = homeState.homePageDataModel;
                      return SingleChildScrollView(
                        controller: homeScreenController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).padding.top,
                        ),
                        child: BlocProvider(
                          create: (context) => FetchHomePageDataCubit(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ///Looping through sections so arrange it
                              ...List.generate(
                                growable: false,
                                AppSettings.sections.length,
                                (index) {
                                  final section = AppSettings.sections[index];
                                  if (section == HomeScreenSections.Search) {
                                    return const HomeSearchField();
                                  } else if (section ==
                                      HomeScreenSections.PersonalizedFeed) {
                                    return const PersonalizedPropertyWidget();
                                  } else if (section ==
                                      HomeScreenSections.Slider) {
                                    return sliderWidget(home.sliderSection);
                                  } else if (section ==
                                      HomeScreenSections.Category) {
                                    return categoryWidget(
                                      home.categoriesSection,
                                    );
                                  } else if (section ==
                                      HomeScreenSections.NearbyProperties) {
                                    return buildNearByProperties(
                                        nearByProperties:
                                            home.nearByProperties);
                                  } else if (section ==
                                      HomeScreenSections.FeaturedProperties) {
                                    return featuredProperties(
                                      home.featuredSection,
                                      context,
                                    );
                                  } else if (section ==
                                      HomeScreenSections.Agents) {
                                    return buildAgents(home.agentsList);
                                  } else if (section ==
                                      HomeScreenSections.RecentlyAdded) {
                                    return const RecentPropertiesSectionWidget();
                                  } else if (section ==
                                      HomeScreenSections.MostLikedProperties) {
                                    return mostLikedProperties(
                                      home.mostLikedProperties,
                                      context,
                                    );
                                  } else if (section ==
                                      HomeScreenSections.MostViewed) {
                                    return mostViewedProperties(
                                      home.mostViewedProperties,
                                      context,
                                    );
                                  } else if (section ==
                                      HomeScreenSections.PopularCities) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          const BannerAdWidget(),
                                          popularCityProperties(),
                                        ],
                                      ),
                                    );
                                  } else if (section ==
                                      HomeScreenSections.project) {
                                    return buildProjects(
                                      home.projectSection,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                              allProperties(context: context),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget allProperties({required BuildContext context}) {
    return BlocBuilder<HomePageInfinityScrollCubit,
        HomePageInfinityScrollState>(
      builder: (context, state) {
        if (state is HomePageInfinityScrollFailure) {
          const SizedBox.shrink();
        }
        if (state is HomePageInfinityScrollInProgress) {
          return LayoutBuilder(
            builder: (context, c) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          child: CustomShimmer(
                            height: 90,
                            width: 90,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              CustomShimmer(
                                height: 10,
                                width: c.maxWidth - 100,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const CustomShimmer(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomShimmer(
                                height: 10,
                                width: c.maxWidth / 1.2,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomShimmer(
                                height: 10,
                                width: c.maxWidth / 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: 6,
              );
            },
          );
        }

        if (state is HomePageInfinityScrollSuccess) {
          return Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleHeader(
                    enableShowAll: false,
                    title: UiUtils.translate(
                      context,
                      'allProperties',
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: state.properties.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PropertyHorizontalCard(
                          property: state.properties[index]);
                    },
                  ),
                  if (context
                      .watch<HomePageInfinityScrollCubit>()
                      .isLoadingMore()) ...[
                    Center(child: UiUtils.progress()),
                  ],
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  bool cityEmpty() {
    if (context.watch<FetchCityCategoryCubit>().state
        is FetchCityCategorySuccess) {
      return (context.watch<FetchCityCategoryCubit>().state
              as FetchCityCategorySuccess)
          .cities
          .isEmpty;
    }
    return true;
  }

  Widget buildProjects(List<ProjectModel> projectSection) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: 'Project section'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.allProjectsScreen);
            },
          ),
          Container(
            height: 250,
            margin: const EdgeInsets.only(bottom: 8, right: 7),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: projectSection.length,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: 8,
                );
              },
              itemBuilder: (context, index) {
                final project = projectSection[index];
                return GestureDetector(
                  onTap: () async {
                    GuestChecker.check(
                      onNotGuest: () async {
                        final systemRepository = SystemRepository();
                        final settings =
                            await systemRepository.fetchSystemSettings(
                          isAnonymouse: false,
                        );
                        if (settings['data']['is_premium'] == true &&
                            project.addedBy.toString() !=
                                HiveUtils.getUserId()) {
                          try {
                            unawaited(Widgets.showLoader(context));
                            final projectRepository = ProjectRepository();
                            final projectDetails = await projectRepository
                                .getProjectDetails(id: project.id!);
                            Future.delayed(
                              Duration.zero,
                              () {
                                Widgets.hideLoder(context);
                                HelperUtils.goToNextPage(
                                  Routes.projectDetailsScreen,
                                  context,
                                  false,
                                  args: {
                                    'project': projectDetails,
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            log('Error is $e');
                            Widgets.hideLoder(context);
                          }
                        } else if (project.addedBy.toString() ==
                            HiveUtils.getUserId()) {
                          try {
                            unawaited(Widgets.showLoader(context));
                            final projectRepository = ProjectRepository();
                            final projectDetails = await projectRepository
                                .getProjectDetails(id: project.id!);
                            Future.delayed(
                              Duration.zero,
                              () {
                                Widgets.hideLoder(context);
                                HelperUtils.goToNextPage(
                                  Routes.projectDetailsScreen,
                                  context,
                                  false,
                                  args: {
                                    'project': projectDetails,
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            log('Error is $e');
                            Widgets.hideLoder(context);
                          }
                        } else {
                          Widgets.hideLoder(context);
                          await UiUtils.showBlurredDialoge(
                            context,
                            dialoge: BlurredDialogBox(
                              title: 'Subscription needed',
                              isAcceptContainesPush: true,
                              onAccept: () async {
                                await Navigator.popAndPushNamed(
                                  context,
                                  Routes.subscriptionPackageListRoute,
                                  arguments: {'from': 'home'},
                                );
                              },
                              content: CustomText(
                                'subscribeToUseThisFeature'.translate(context),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  child: ProjectCard(
                    title: project.title ?? '',
                    categoryIcon: project.category?.image ?? '',
                    url: project.image ?? '',
                    categoryName: project.category?.category ?? '',
                    description: project.description ?? '',
                    status: project.type ?? '',
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildAgents(List<AgentModel> agents) {
    if (agents.isNotEmpty)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            title: UiUtils.translate(context, 'agents'),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.agentListScreen);
            },
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              itemCount: agents.length < 5 ? agents.length : 5,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: 8,
                );
              },
              itemBuilder: (context, index) {
                final agent = agents[index];
                return GestureDetector(
                  child: AgentCard(
                    agent: agent,
                    propertyCount: agent.propertyCount,
                    name: agent.name,
                  ),
                );
              },
            ),
          ),
        ],
      );
    return const SizedBox.shrink();
  }

  Widget popularCityProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!cityEmpty())
          TitleHeader(
            title: 'popularCities'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.cityListScreen);
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
            builder: (context, FetchCityCategoryState state) {
              if (state is FetchCityCategorySuccess) {
                final cityLength =
                    state.cities.length > 10 ? 10 : state.cities.length;
                return StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: [
                    ...List.generate(cityLength, (index) {
                      if (index % 4 == 0 || index % 5 == 0) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 2,
                          child: buildCityCard(state, index),
                        );
                      } else {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: buildCityCard(state, index),
                        );
                      }
                    }),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget mostViewedProperties(
    List<PropertyModel> mostViewedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostViewedProperties.isNotEmpty)
          TitleHeader(
            onSeeAll: _onTapMostViewedSeeAll,
            title: UiUtils.translate(context, 'mostViewed'),
          ),
        buildMostViewedProperties(mostViewedProperties),
      ],
    );
  }

  Widget mostLikedProperties(
    List<PropertyModel> mostLikedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostLikedProperties.isNotEmpty) ...[
          TitleHeader(
            onSeeAll: _onTapMostLikedAll,
            title: UiUtils.translate(
              context,
              'mostLikedProperties',
            ),
          ),
          buildMostLikedProperties(mostLikedProperties),
          const SizedBox(
            height: 15,
          ),
        ],
      ],
    );
  }

  Widget featuredProperties(
    List<PropertyModel> featuredProperties,
    BuildContext context,
  ) {
    if (featuredProperties.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            onSeeAll: _onTapPromotedSeeAll,
            title: UiUtils.translate(
              context,
              'promotedProperties',
            ),
          ),
          buildPromotedProperties(featuredProperties),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget sliderWidget(List<HomeSlider> sliderList) {
    if (sliderList.isNotEmpty) {
      return const SliderWidget();
    }
    return const SizedBox.shrink();
  }

  Widget buildCityCard(FetchCityCategorySuccess state, int index) {
    if (index >= state.cities.length) {
      return const SizedBox.shrink();
    }
    final city = state.cities[index];
    return GestureDetector(
      onTap: () {
        context.read<FetchCityPropertyList>().fetch(
              cityName: city.name,
              forceRefresh: true,
            );
        Navigator.push(
          context,
          BlurredRouter(
            builder: (context) {
              return CityPropertiesScreen(
                cityName: city.name,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiUtils.getImage(
                city.image,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.68),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 8,
                start: 12,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: city.name.firstUpperCase(),
                        style: TextStyle(
                          color: context.color.buttonColor,
                          fontSize: context.font.normal,
                        ),
                      ),
                      TextSpan(
                        text: '\n${city.count} ',
                        style: TextStyle(
                          color: context.color.buttonColor,
                          fontSize: context.font.small,
                        ),
                      ),
                      TextSpan(
                        text: 'properties'.translate(context),
                        style: TextStyle(
                          color: context.color.buttonColor,
                          fontSize: context.font.small,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      color: context.color.buttonColor,
                      fontSize: context.font.small,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPromotedProperties(List<PropertyModel> promotedProperties) {
    return SizedBox(
      height: 261,
      child: ListView.builder(
        itemCount: promotedProperties.length.clamp(0, 6),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final thisItemKey = GlobalKey();
          return GestureDetector(
            onTap: () async {
              try {
                unawaited(Widgets.showLoader(context));
                final fetch = PropertyRepository();
                final dataOutput = await fetch.fetchPropertyFromPropertyId(
                  id: promotedProperties[index].id!,
                  isMyProperty: promotedProperties[index].addedBy.toString() ==
                      HiveUtils.getUserId(),
                );
                Future.delayed(
                  Duration.zero,
                  () {
                    Widgets.hideLoder(context);
                    HelperUtils.goToNextPage(
                      Routes.propertyDetails,
                      context,
                      false,
                      args: {
                        'propertyData': dataOutput,
                        'fromMyProperty': false,
                      },
                    );
                  },
                );
              } catch (e) {
                log('Error is $e');
                Widgets.hideLoder(context);
              }
            },
            child: BlocProvider(
              create: (context) {
                return AddToFavoriteCubitCubit();
              },
              child: PropertyCardBig(
                key: thisItemKey,
                isFirst: index == 0,
                property: promotedProperties[index],
                onLikeChange: (type) {
                  if (type == FavoriteType.add) {
                    context
                        .read<FetchFavoritesCubit>()
                        .add(promotedProperties[index]);
                  } else {
                    context
                        .read<FetchFavoritesCubit>()
                        .remove(promotedProperties[index].id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMostLikedProperties(List<PropertyModel> mostLiked) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 15,
        crossAxisCount: 2,
        height: 260,
      ),
      itemCount: mostLiked.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final properties = mostLiked[index];
        return BlocProvider(
          create: (context) => AddToFavoriteCubitCubit(),
          child: GestureDetector(
            onTap: () async {
              try {
                unawaited(Widgets.showLoader(context));
                final fetch = PropertyRepository();
                final dataOutput = await fetch.fetchPropertyFromPropertyId(
                  id: properties.id!,
                  isMyProperty:
                      properties.addedBy.toString() == HiveUtils.getUserId(),
                );
                Future.delayed(
                  Duration.zero,
                  () {
                    Widgets.hideLoder(context);
                    HelperUtils.goToNextPage(
                      Routes.propertyDetails,
                      context,
                      false,
                      args: {
                        'propertyData': dataOutput,
                        'fromMyProperty': false,
                      },
                    );
                  },
                );
              } catch (e) {
                log('Error is $e');
                Widgets.hideLoder(context);
              }
            },
            child: PropertyCardBig(
              showEndPadding: false,
              isFirst: index == 0,
              onLikeChange: (type) {
                if (type == FavoriteType.add) {
                  context.read<FetchFavoritesCubit>().add(properties);
                } else {
                  context.read<FetchFavoritesCubit>().remove(properties.id);
                }
              },
              property: properties,
            ),
          ),
        );
      },
    );
  }

  Widget buildNearByProperties(
      {required List<PropertyModel> nearByProperties}) {
    if (nearByProperties.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          onSeeAll: _onTapNearByPropertiesAll,
          title: "${UiUtils.translate(
            context,
            "nearByProperties",
          )} (${HiveUtils.getCityName()})",
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: nearByProperties.length.clamp(0, 6),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var model = nearByProperties[index];
              model = context.watch<PropertyEditCubit>().get(model);
              return PropertyGradiendCard(
                model: model,
                isFirst: index == 0,
                showEndPadding: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildMostViewedProperties(List<PropertyModel> mostViewed) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 15,
        crossAxisCount: 2,
        height: 260,
      ),
      itemCount: mostViewed.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final property = mostViewed[index];
        return GestureDetector(
          onTap: () async {
            try {
              unawaited(Widgets.showLoader(context));
              final fetch = PropertyRepository();
              final dataOutput = await fetch.fetchPropertyFromPropertyId(
                id: property.id!,
                isMyProperty:
                    property.addedBy.toString() == HiveUtils.getUserId(),
              );
              Future.delayed(
                Duration.zero,
                () {
                  Widgets.hideLoder(context);
                  HelperUtils.goToNextPage(
                    Routes.propertyDetails,
                    context,
                    false,
                    args: {
                      'propertyData': dataOutput,
                      'fromMyProperty': false,
                    },
                  );
                },
              );
            } catch (e) {
              log('Error is $e');
              Widgets.hideLoder(context);
            }
          },
          child: BlocProvider(
            create: (context) => AddToFavoriteCubitCubit(),
            child: PropertyCardBig(
              showEndPadding: false,
              isFirst: index == 0,
              onLikeChange: (type) {
                if (type == FavoriteType.add) {
                  context.read<FetchFavoritesCubit>().add(property);
                } else {
                  context.read<FetchFavoritesCubit>().remove(property.id);
                }
              },
              property: property,
            ),
          ),
        );
      },
    );
  }

  Widget categoryWidget(List<Category> categories) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 44.rh(context),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length.clamp(0, Constant.maxCategoryLength),
            itemBuilder: (context, index) {
              final category = categories[index];
              Constant.propertyFilter = null;
              if (index == (Constant.maxCategoryLength - 1)) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.categories);
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 100.rw(context),
                      ),
                      height: 44.rh(context),
                      alignment: Alignment.center,
                      decoration: DesignConfig.boxDecorationBorder(
                        color: context.color.secondaryColor,
                        radius: 10,
                        borderWidth: 1.5,
                        borderColor: context.color.borderColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomText(UiUtils.translate(context, 'more')),
                      ),
                    ),
                  ),
                );
              }
              return buildCategoryCard(context, category, index != 0);
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryCard(
    BuildContext context,
    Category category,
    frontSpacing,
  ) {
    return CategoryCard(
      frontSpacing: frontSpacing,
      onTapCategory: (category) {
        currentVisitingCategoryId = category.id;
        currentVisitingCategory = category;
        Navigator.of(context).pushNamed(
          Routes.propertiesList,
          arguments: {'catID': category.id, 'catName': category.category},
        );
      },
      category: category,
    );
  }
}

class RecentPropertiesSectionWidget extends StatefulWidget {
  const RecentPropertiesSectionWidget({super.key});

  @override
  State<RecentPropertiesSectionWidget> createState() =>
      _RecentPropertiesSectionWidgetState();
}

class _RecentPropertiesSectionWidgetState
    extends State<RecentPropertiesSectionWidget> {
  void _onRecentlyAddedSeeAll() {
    final dynamic statemap = StateMap<
        FetchRecentProepertiesInitial,
        FetchRecentPropertiesInProgress,
        FetchRecentPropertiesSuccess,
        FetchRecentPropertiesFailur>();
    ViewAllScreen<FetchRecentPropertiesCubit, FetchRecentPropertiesState>(
      title: 'recentlyAdded'.translate(context),
      map: statemap,
    ).open(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isRecentEmpty() {
      if (context.watch<FetchRecentPropertiesCubit>().state
          is FetchRecentPropertiesSuccess) {
        return (context.watch<FetchRecentPropertiesCubit>().state
                as FetchRecentPropertiesSuccess)
            .properties
            .isEmpty;
      }
      return true;
    }

    return Column(
      children: [
        if (!isRecentEmpty())
          TitleHeader(
            enableShowAll: false,
            title: 'recentlyAdded'.translate(context),
            onSeeAll: _onRecentlyAddedSeeAll,
          ),
        LayoutBuilder(
          builder: (context, c) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: BlocBuilder<FetchRecentPropertiesCubit,
                  FetchRecentPropertiesState>(
                builder: (context, state) {
                  if (state is FetchRecentPropertiesInProgress) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const ClipRRect(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                child: CustomShimmer(height: 90, width: 90),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth - 100,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const CustomShimmer(
                                      height: 10,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth / 1.2,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth / 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 5,
                    );
                  }

                  if (state is FetchRecentPropertiesSuccess) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var modal = state.properties[index];
                        modal = context.watch<PropertyEditCubit>().get(modal);
                        return PropertyHorizontalCard(
                          property: modal,
                          additionalImageWidth: 10,
                        );
                      },
                      itemCount: state.properties.length.clamp(0, 4),
                      shrinkWrap: true,
                    );
                  }
                  if (state is FetchRecentPropertiesFailur) {
                    return Container();
                  }

                  return Container();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class PersonalizedPropertyWidget extends StatelessWidget {
  const PersonalizedPropertyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPersonalizedPropertyList,
        FetchPersonalizedPropertyListState>(
      builder: (context, state) {
        if (state is FetchPersonalizedPropertyInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {},
                title: 'personalizedFeed'.translate(context),
              ),
              const PromotedPropertiesShimmer(),
            ],
          );
        }

        if (state is FetchPersonalizedPropertySuccess) {
          if (state.properties.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {
                  final StateMap stateMap = StateMap<
                      FetchPersonalizedPropertyInitial,
                      FetchPersonalizedPropertyInProgress,
                      FetchPersonalizedPropertySuccess,
                      FetchPersonalizedPropertyFail>();

                  ViewAllScreen<FetchPersonalizedPropertyList,
                      FetchPersonalizedPropertyListState>(
                    title: 'personalizedFeed'.translate(context),
                    map: stateMap,
                  ).open(context);
                },
                title: 'personalizedFeed'.translate(context),
              ),
              SizedBox(
                height: 261,
                child: ListView.builder(
                  itemCount: state.properties.length.clamp(0, 6),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final thisITemkye = GlobalKey();

                    var propertymodel = state.properties[index];
                    propertymodel =
                        context.watch<PropertyEditCubit>().get(propertymodel);
                    return GestureDetector(
                      onTap: () {
                        HelperUtils.goToNextPage(
                          Routes.propertyDetails,
                          context,
                          false,
                          args: {
                            'propertyData': propertymodel,
                            'fromMyProperty': false,
                          },
                        );
                      },
                      child: BlocProvider(
                        create: (context) {
                          return AddToFavoriteCubitCubit();
                        },
                        child: PropertyCardBig(
                          key: thisITemkye,
                          isFirst: index == 0,
                          property: propertymodel,
                          onLikeChange: (type) {
                            if (type == FavoriteType.add) {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .add(propertymodel);
                            } else {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .remove(state.properties[index].id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

Future<void> notificationPermissionChecker(BuildContext context) async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.onPermanentlyDeniedCallback(
      () {
        return;
      },
    );
    await Permission.notification.request().then((value) {
      if (value == true) {
        HelperUtils.showSnackBarMessage(
            context, 'Notification Permission Granted');
      } else {
        HelperUtils.showSnackBarMessage(
            context, 'Notification Permission Denied');
      }
    });
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
  int bannersLength = 0;
  late Timer _timer;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_bannerIndex.value < bannersLength - 1) {
        _bannerIndex.value++;
      } else {
        _bannerIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _bannerIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerIndex.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FetchHomePageDataCubit, FetchHomePageDataState>(
      builder: (context, state) {
        if (state is FetchHomePageDataLoading) {
          return Column(
            children: [
              SizedBox(
                height: 15.rh(context),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 18,
                  top: 10,
                  left: 18,
                  bottom: 10,
                ),
                height: 170.rh(context),
                child: ListView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemCount: 1,
                  itemBuilder: (context, index) => CustomShimmer(
                    height: 130.rh(context),
                    width: context.screenWidth * 0.9,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),
            ],
          );
        }
        if (state is FetchHomePageDataSuccess &&
            state.homePageDataModel.sliderSection.isNotEmpty) {
          bannersLength = state.homePageDataModel.sliderSection.length;
          return Column(
            children: <Widget>[
              SizedBox(
                height: 15.rh(context),
              ),
              SizedBox(
                height: 170.rh(context),
                child: PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemCount: state.homePageDataModel.sliderSection.length,
                  onPageChanged: (index) {
                    _bannerIndex.value = index;
                  },
                  itemBuilder: (context, index) => _buildBanner(
                    state.homePageDataModel.sliderSection[index],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(HomeSlider banner) {
    return GestureDetector(
      onTap: () async {
        if (banner.sliderType == '1') {
          UiUtils.showFullScreenImage(
            context,
            provider: NetworkImage(banner.image.toString()),
          );
        } else if (banner.sliderType == '2') {
          await Navigator.pushNamed(
            context,
            Routes.propertiesList,
            arguments: {
              'catID': banner.categoryId,
              'catName': banner.category!.category,
            },
          );
        } else if (banner.sliderType == '3') {
          try {
            unawaited(Widgets.showLoader(context));
            final fetch = PropertyRepository();
            final dataOutput = await fetch.fetchPropertyFromPropertyId(
              id: int.parse(banner.propertysId!),
              isMyProperty:
                  banner.property!.addedBy.toString() == HiveUtils.getUserId(),
            );
            Future.delayed(
              Duration.zero,
              () {
                Widgets.hideLoder(context);
                HelperUtils.goToNextPage(
                  Routes.propertyDetails,
                  context,
                  false,
                  args: {
                    'propertyData': dataOutput,
                    'propertiesList': dataOutput,
                    'fromMyProperty': false,
                  },
                );
              },
            );
          } catch (e) {
            log('Error is $e');
            Widgets.hideLoder(context);
          }
        } else if (banner.sliderType == '4') {
          await url_launcher.launchUrl(Uri.parse(banner.link!));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              width: context.screenWidth,
              height: context.screenHeight * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: UiUtils.getImage(
                  banner.image.toString(),
                  width: context.screenWidth,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
