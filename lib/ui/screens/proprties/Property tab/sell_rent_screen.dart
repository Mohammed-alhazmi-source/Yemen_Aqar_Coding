import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

FetchMyPropertiesCubit? cubitReference;
dynamic propertyType;
Map ref = {};

class SellRentScreen extends StatefulWidget {
  const SellRentScreen({
    required this.type,
    super.key,
  });
  final String type;

  @override
  State<SellRentScreen> createState() => _SellRentScreenState();
}

class _SellRentScreenState extends State<SellRentScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController controller;

  bool isNetworkAvailable = true;
  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(pageScrollListener);
    // context.read<FetchMyPropertiesCubit>().fetchMyProperties(
    //       type: widget.type,
    //     );
  }

  @override
  void dispose() {
    controller
      ..removeListener(pageScrollListener)
      ..dispose();
    super.dispose();
  }

  void pageScrollListener() {
    // if (controller.isEndReached()) {
    //   if (context.read<FetchMyPropertiesCubit>().hasMoreData()) {
    //     context.read<FetchMyPropertiesCubit>().fetchMoreProperties(
    //           type: widget.type,
    //         );
    //   }
    // }
  }

  String statusText(String text) {
    if (text == '1') {
      return UiUtils.translate(context, 'active');
    } else if (text == '0') {
      return UiUtils.translate(context, 'deactive');
    }
    return '';
  }

  Color statusColor(String text) {
    if (text == '1') {
      return const Color.fromRGBO(64, 171, 60, 1);
    } else {
      return const Color.fromRGBO(238, 150, 43, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.type.toLowerCase() == 'sell') {
      ref['sell'] = context.read<FetchMyPropertiesCubit>();
    } else if (widget.type.toLowerCase() == 'rent') {
      ref['rent'] = context.read<FetchMyPropertiesCubit>();
    } else if (widget.type.toLowerCase() == 'sold') {
      ref['sold'] = context.read<FetchMyPropertiesCubit>();
    } else if (widget.type.toLowerCase() == 'rented') {
      ref['rented'] = context.read<FetchMyPropertiesCubit>();
    }

    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        // await context.read<FetchMyPropertiesCubit>().fetchMyProperties(
        //       type: widget.type,
        //     );
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
          builder: (context, state) {
            if (state is FetchMyPropertiesInProgress) {
              return buildMyPropertyShimmer();
            }
            if (state is FetchMyPropertiesFailure) {
              if (state.errorMessage is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    // context.read<FetchMyPropertiesCubit>().fetchMyProperties(
                    //       type: widget.type,
                    //     );
                  },
                );
              }
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: const SomethingWentWrong(),
              );
            }

            if (state is FetchMyPropertiesSuccess) {
              if (state.myProperty.isEmpty) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: NoDataFound(
                      title: 'noPropertyAdded'.translate(context),
                      description: 'noPropertyDescription'.translate(context),
                      onTap: () {
                        // context
                        //     .read<FetchMyPropertiesCubit>()
                        //     .fetchMyProperties(
                        //       type: widget.type,
                        //     );
                      },
                    ),
                  ),
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                controller: controller,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                itemCount:
                    state.myProperty.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 2,
                  );
                },
                itemBuilder: (context, index) {
                  if (state.myProperty.length == index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [UiUtils.progress()],
                    );
                  }
                  final property = state.myProperty[index];
                  return BlocProvider(
                    create: (context) => AddToFavoriteCubitCubit(),
                    child: PropertyHorizontalCard(
                      property: property,
                      showLikeButton: false,
                      statusButton: StatusButton(
                        lable: statusText(property.status.toString()),
                        color: statusColor(property.status.toString()),
                        textColor: context.color.buttonColor,
                      ),
                      // useRow: true,
                    ),
                  );
                },
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  Widget buildMyPropertyShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 10 + defaultPadding,
        horizontal: defaultPadding,
      ),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth - 50,
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
