import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CityPropertiesScreen extends StatefulWidget {
  const CityPropertiesScreen({required this.cityName, super.key});

  final String cityName;

  @override
  State<CityPropertiesScreen> createState() => _CityPropertiesScreenState();
}

class _CityPropertiesScreenState extends State<CityPropertiesScreen> {
  FilterApply? selectedFilter;
  ScrollController cityPropertiesScreenController = ScrollController();

  @override
  void initState() {
    cityPropertiesScreenController.addListener(_onScroll);
    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchCityPropertyList>().fetch(
            cityName: widget.cityName,
          );
    });
    super.initState();
  }

  void _onScroll() {
    // Check if we're near the bottom of the list
    if (cityPropertiesScreenController.position.pixels >=
        cityPropertiesScreenController.position.maxScrollExtent - 100) {
      final fetchCubit = context.read<FetchCityPropertyList>();

      // Only fetch more if not already loading and more data exists
      if (!fetchCubit.isLoadingMore() && fetchCubit.hasMoreData()) {
        fetchCubit.fetchMore();
      }
    }
  }

  @override
  void dispose() {
    // Always dispose of the ScrollController
    cityPropertiesScreenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.cityName,
        showBackButton: true,
      ),
      body: BlocBuilder<FetchCityPropertyList, FetchCityPropertyListState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: context.color.tertiaryColor,
            onRefresh: () async {
              await context.read<FetchCityPropertyList>().fetch(
                    cityName: widget.cityName,
                  );
            },
            child: CustomScrollView(
              controller: cityPropertiesScreenController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: state is FetchCityPropertyInProgress
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: List.generate(
                              15,
                              (index) => CustomShimmer(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width,
                                borderRadius: 15,
                                margin: EdgeInsetsDirectional.only(bottom: 10),
                              ),
                            ),
                          ),
                        )
                      : state is FetchCityPropertyFail
                          ? SliverToBoxAdapter(
                              child: SomethingWentWrong(),
                            )
                          : state is FetchCityPropertySuccess &&
                                  state.properties.isNotEmpty
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final property = state.properties[index];
                                      return PropertyHorizontalCard(
                                        property: property,
                                        showLikeButton: true,
                                      );
                                    },
                                    childCount: state.properties.length,
                                  ),
                                )
                              : SliverToBoxAdapter(
                                  child: Center(
                                    child: NoDataFound(
                                      title:
                                          'noPropertyAdded'.translate(context),
                                    ),
                                  ),
                                ),
                ),
                if (context.watch<FetchCityPropertyList>().isLoadingMore())
                  SliverToBoxAdapter(
                    child: Center(child: UiUtils.progress()),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
