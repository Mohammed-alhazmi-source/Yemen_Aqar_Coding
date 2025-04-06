import 'package:ebroker/data/helper/design_configs.dart';
import 'package:ebroker/data/model/notification_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

late NotificationData selectedNotification;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  NotificationsState createState() => NotificationsState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const Notifications(),
    );
  }
}

class NotificationsState extends State<Notifications> {
  bool isNotificationsEnabled = true;

  late final ScrollController _pageScrollController = ScrollController();
  List<PropertyModel> propertyData = [];
  @override
  void initState() {
    super.initState();
    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchNotificationsCubit>().hasMoreData()) {
          context.read<FetchNotificationsCubit>().fetchNotificationsMore();
        }
      }
    });
    context.read<FetchNotificationsCubit>().fetchNotifications();
  }

  @override
  void dispose() {
    Routes.currentRoute = Routes.previousCustomerRoute;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'notifications'),
        showBackButton: true,
      ),
      body: BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
        builder: (context, state) {
          if (state is FetchNotificationsInProgress) {
            return buildNotificationShimmer();
          }
          if (state is FetchNotificationsFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context.read<FetchNotificationsCubit>().fetchNotifications();
                },
              );
            }
            return const SomethingWentWrong();
          }

          if (state is FetchNotificationsSuccess) {
            if (state.notificationdata.isEmpty) {
              return NoDataFound(
                onTap: () {
                  context.read<FetchNotificationsCubit>().fetchNotifications();
                },
              );
            }
            if (state.notificationdata.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      controller: _pageScrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 2,
                      ),
                      itemCount: state.notificationdata.length,
                      itemBuilder: (context, index) {
                        final notificationData = state.notificationdata[index];
                        return GestureDetector(
                          onTap: () {
                            selectedNotification = notificationData;
                            if (notificationData.type ==
                                Constant.enquiryNotification) {
                            } else {
                              HelperUtils.goToNextPage(
                                Routes.notificationDetailPage,
                                context,
                                false,
                              );
                            }
                          },
                          child: Container(
                            decoration: DesignConfig.boxDecorationBorder(
                              color:
                                  Theme.of(context).colorScheme.secondaryColor,
                              borderWidth: 1.5,
                              borderColor: context.color.borderColor,
                              radius: 10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              children: <Widget>[
                                if (notificationData.image != null)
                                  GestureDetector(
                                    onTap: () {
                                      UiUtils.showFullScreenImage(
                                        context,
                                        provider: CachedNetworkImageProvider(
                                          notificationData.image!,
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      child: UiUtils.getImage(
                                        notificationData.image!,
                                        height: 53.rh(context),
                                        width: 53.rw(context),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        notificationData.title!
                                            .firstUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .merge(
                                              const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        notificationData.message!
                                            .firstUpperCase(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        notificationData.createdAt!
                                            .formatDate(),
                                        style: TextStyle(
                                          fontSize: context.font.smaller,
                                          color: context.color.textLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((context.read<FetchNotificationsCubit>().state
                          as FetchNotificationsSuccess)
                      .isLoadingMore) ...[
                    Center(child: UiUtils.progress()),
                  ],
                ],
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      itemCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 55,
          child: Row(
            children: <Widget>[
              const CustomShimmer(
                width: 50,
                height: 50,
                borderRadius: 11,
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomShimmer(
                    height: 7,
                    width: 200.rw(context),
                  ),
                  const SizedBox(height: 5),
                  CustomShimmer(
                    height: 7,
                    width: 100.rw(context),
                  ),
                  const SizedBox(height: 5),
                  CustomShimmer(
                    height: 7,
                    width: 150.rw(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
