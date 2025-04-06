import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key, this.from});
  final String? from;

  @override
  State<CityListScreen> createState() => _CityListScreenState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const CityListScreen(),
    );
  }
}

class _CityListScreenState extends State<CityListScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    context.read<FetchCityCategoryCubit>().fetchCityCategory(
          forceRefresh: false,
        );
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    cityScreenController.addListener(pageScrollListener);
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (cityScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchCityCategoryCubit>().hasMoreData()) {
          context.read<FetchCityCategoryCubit>().fetchMore();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'allCities'),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        controller: cityScreenController,
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: <Widget>[
            BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
              builder: (context, state) {
                if (state is FetchCityCategoryFail) {
                  return const SomethingWentWrong();
                }
                if (state is FetchCityCategoryInProgress) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      left: sidePadding,
                      right: sidePadding,
                      top: 8,
                      bottom: 25,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                      height: 260,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const CustomShimmer(
                        height: 155,
                        width: 200,
                      );
                    },
                  );
                }
                if (state is FetchCityCategorySuccess && state.cities.isEmpty) {
                  return NoDataFound(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.cityListScreen);
                    },
                  );
                }
                if (state is FetchCityCategorySuccess &&
                    state.cities.isNotEmpty) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      left: sidePadding,
                      right: sidePadding,
                      top: 8,
                      bottom: 25,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                      height: 260,
                    ),
                    itemCount: state.cities.length,
                    itemBuilder: (context, index) {
                      final city = state.cities[index];
                      return CityCard(
                        count: city.count,
                        name: city.name,
                        city: city,
                      );
                    },
                  );
                }
                return Container();
              },
            ),
            if (context.watch<FetchCityCategoryCubit>().isLoadingMore()) ...[
              Center(child: UiUtils.progress()),
            ],
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  const CityCard({
    required this.city,
    required this.name,
    required this.count,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });

  final City city;
  final int count;
  final bool? isFirst;
  final bool? showEndPadding;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HelperUtils.share(context, city.count, city.name);
      },
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        width: 155,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                clipBehavior: Clip.antiAlias,
                child: UiUtils.getImage(
                  city.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CustomText(
                      city.name.firstUpperCase(),
                      fontWeight: FontWeight.bold,
                      fontSize: context.font.large,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      'Properties(${city.count})',
                      fontSize: context.font.normal,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
