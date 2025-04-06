import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class PromotedPropertiesScreen extends StatefulWidget {
  const PromotedPropertiesScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (context) {
        return const PromotedPropertiesScreen();
      },
    );
  }

  @override
  State<PromotedPropertiesScreen> createState() =>
      _PromotedPropertiesScreenState();
}

class _PromotedPropertiesScreenState extends State<PromotedPropertiesScreen> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();
  @override
  void initState() {
    context.read<FetchPromotedPropertiesCubit>().fetch();
    _pageScrollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    // / / /This is extensions which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchPromotedPropertiesCubit>().hasMoreData()) {
        context.read<FetchPromotedPropertiesCubit>().fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'promotedProperties'),
      ),
      body: BlocBuilder<FetchPromotedPropertiesCubit,
          FetchPromotedPropertiesState>(
        builder: (context, state) {
          if (state is FetchPromotedPropertiesInProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          }
          if (state is FetchPromotedPropertiesFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchPromotedPropertiesSuccess) {
            if (state.properties.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: RemoveGlow(),
                    child: ListView.builder(
                      controller: _pageScrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: state.properties.length,
                      itemBuilder: (context, index) {
                        final property = state.properties[index];
                        return GestureDetector(
                          onTap: () {
                            HelperUtils.goToNextPage(
                              Routes.propertyDetails,
                              context,
                              false,
                              args: {
                                'propertyData': property,
                                'fromMyProperty': false,
                              },
                            );
                          },
                          child: PropertyHorizontalCard(
                            property: property,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress(),
                const SizedBox(
                  height: 30,
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
