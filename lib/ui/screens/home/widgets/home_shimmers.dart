import 'package:ebroker/data/cubits/home_page_data_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class HomeShimmer extends StatefulWidget {
  const HomeShimmer({super.key});

  @override
  State<HomeShimmer> createState() => _HomeShimmerState();
}

ScrollController _scrollController = ScrollController();

void initState() {
  _scrollController.addListener(() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  });
}

class _HomeShimmerState extends State<HomeShimmer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchHomePageDataCubit, FetchHomePageDataState>(
      builder: (context, state) {
        if (state is FetchHomePageDataLoading) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              shrinkWrap: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(18),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  children: [
                    CustomShimmer(
                      height: 45.rh(context),
                      width: MediaQuery.of(context).size.width * 0.75,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomShimmer(
                        height: 45.rh(context),
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                CustomShimmer(height: 170.rh(context), width: 200),
                const SizedBox(height: 9),
                SizedBox(
                  height: 40.rh(context),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return CustomShimmer(
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        height: 40.rh(context),
                        width: MediaQuery.of(context).size.width * 0.3,
                      );
                    },
                    itemCount: 5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 200.rh(context),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return CustomShimmer(
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        width: MediaQuery.of(context).size.width * 0.65,
                      );
                    },
                    itemCount: 5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 200.rh(context),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return CustomShimmer(
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        width: MediaQuery.of(context).size.width * 0.8,
                      );
                    },
                    itemCount: 5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return CustomShimmer(
                        height: 150.rh(context),
                        margin: const EdgeInsetsDirectional.only(bottom: 10),
                      );
                    },
                    itemCount: 3,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class PromotedPropertiesShimmer extends StatelessWidget {
  const PromotedPropertiesShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 261,
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
            child: CustomShimmer(
              height: 272.rh(context),
              width: 250.rw(context),
            ),
          );
        },
      ),
    );
  }
}

class NearbyPropertiesShimmer extends StatelessWidget {
  const NearbyPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
            child: const CustomShimmer(
              height: 200,
              width: 300,
            ),
          );
        },
      ),
    );
  }
}
