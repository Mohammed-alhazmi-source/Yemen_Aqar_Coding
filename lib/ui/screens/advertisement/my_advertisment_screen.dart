import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/advertisement_horizontal_card.dart';
import 'package:flutter/material.dart';

class MyAdvertisementScreen extends StatefulWidget {
  const MyAdvertisementScreen({super.key});
  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const MyAdvertisementScreen(),
    );
  }

  @override
  State<MyAdvertisementScreen> createState() => _MyAdvertisementScreenState();
}

class _MyAdvertisementScreenState extends State<MyAdvertisementScreen>
    with TickerProviderStateMixin {
  final ScrollController _pageScrollController = ScrollController();
  final PageController _pageController = PageController();
  Map<int, String>? statusMap;
  String advertisementType = '';

  @override
  void initState() {
    super.initState();
    context.read<FetchMyPromotedPropertysCubit>().fetchMyPromotedPropertys();
    Future.delayed(
      Duration.zero,
      () {
        statusMap = {
          0: UiUtils.translate(context, 'approved'), // مصدق
          1: UiUtils.translate(context, 'pending'), // معلقة
          2: UiUtils.translate(context, 'rejected'), // رفض
          3: UiUtils.translate(context, 'expired'), // انتهت صلاحية الاعلان عن العقار المعين
        };
      },
    );

    _pageScrollController.addListener(_pageScroll);
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedPropertysCubit>().hasMoreData()) {
        context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertysMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'myAds'),
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context
              .read<FetchMyPromotedPropertysCubit>()
              .fetchMyPromotedPropertys();
        },
        child: BlocBuilder<FetchMyPromotedPropertysCubit,
            FetchMyPromotedPropertysState>(
          builder: (context, state) {
            if (state is FetchMyPromotedPropertysInProgress) {
              return Center(child: UiUtils.progress());
            }
            if (state is FetchMyPromotedPropertysFailure) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SomethingWentWrong()),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ],
                ),
              );
            }
            if (state is FetchMyPromotedPropertysSuccess) {
              if (state.advertisement.isEmpty) {
                return NoDataFound(
                  title: 'noFeaturedAdsYes'.translate(context),
                  description: 'noFeaturedDescription'.translate(context),
                  onTap: () {
                    context
                        .read<FetchMyPromotedPropertysCubit>()
                        .fetchMyPromotedPropertys();
                    setState(() {});
                  },
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      controller: _pageScrollController,
                      padding: const EdgeInsets.all(20),
                      itemBuilder: (context, index) {
                        final model = state.advertisement[index];
                        return _buildAdvertisementCard(
                          context,
                          model,
                        );
                      },
                      itemCount: state.advertisement.length,
                    ),
                  ),
                  if (state.isLoadingMore) UiUtils.progress(),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildAdvertisementCard(
    BuildContext context,
    Advertisement advertisement,
  ) {
    return BlocProvider(
      create: (context) => DeleteAdvertismentCubit(AdvertisementRepository()),
      child: MyAdvertisementPropertyHorizontalCard(
        advertisement: advertisement,
        showLikeButton: false,
        statusButton: StatusButton(
          lable: statusMap![advertisement.advertisementStatus]
              .toString()
              .firstUpperCase(),
          color: statusColor(advertisement.advertisementStatus),
          textColor: context.color.buttonColor,
        ),
        showDeleteButton: true,
      ),
    );
  }

  Color statusColor(status) {
    if (status == 0) {
      return Colors.green;
    } else if (status == 1) {
      return Colors.orangeAccent;
    } else if (status == 2) {
      return Colors.red;
    } else if (status == 3) {
      return Colors.redAccent;
    }
    return Colors.transparent;
  }
}
