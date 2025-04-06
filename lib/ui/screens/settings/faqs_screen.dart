import 'package:ebroker/data/cubits/fetch_faqs_cubit.dart';
import 'package:ebroker/data/model/faqs_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:flutter/material.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({
    super.key,
  });

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const FaqsScreen(),
    );
  }

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  @override
  void initState() {
    context.read<FetchFaqsCubit>().fetchFaqs(
          forceRefresh: false,
        );
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    faqsListScreenController.addListener(pageScrollListener);
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (faqsListScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchFaqsCubit>().hasMoreData()) {
          context.read<FetchFaqsCubit>().fetchMore();
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
        title: UiUtils.translate(context, 'faqScreen'),
        showBackButton: true,
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<FetchFaqsCubit>().fetchFaqs(
                forceRefresh: true,
              );
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          controller: faqsListScreenController,
          child: Column(
            children: <Widget>[
              BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
                builder: (context, state) {
                  if (state is FetchFaqsFailure) {
                    return const SomethingWentWrong();
                  }
                  if (state is FetchFaqsInProgress) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 8,
                        bottom: 25,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            CustomShimmer(
                              height: 48,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  if (state is FetchFaqsSuccess && state.faqs.isEmpty) {
                    return Center(
                      heightFactor: 2,
                      child: NoDataFound(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.faqsScreen);
                        },
                      ),
                    );
                  }
                  if (state is FetchFaqsSuccess && state.faqs.isNotEmpty) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 8,
                        bottom: 25,
                      ),
                      itemCount: state.faqs.length,
                      itemBuilder: (context, index) {
                        final faq = state.faqs[index];
                        return Column(
                          children: [
                            FaqsCard(faq: faq),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),
              if (context.watch<FetchFaqsCubit>().isLoadingMore()) ...[
                Center(child: UiUtils.progress()),
              ],
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqsCard extends StatelessWidget {
  const FaqsCard({required this.faq, super.key});
  final FaqsModel faq;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.color.borderColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      collapsedShape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.color.borderColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      collapsedBackgroundColor: context.color.secondaryColor,
      backgroundColor: context.color.secondaryColor,
      // collapsedIconColor: context.color.tertiaryColor,
      iconColor: context.color.tertiaryColor,
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      title: CustomText(
        faq.question!,
        maxLines: 2,
        fontWeight: FontWeight.w600,
        fontSize: context.font.larger,
        color: context.color.textColorDark,
      ),
      children: [
        ReadMoreText(
          text: faq.answer ?? '',
          style: TextStyle(color: context.color.inverseSurface),
          readMoreButtonStyle: TextStyle(color: context.color.tertiaryColor),
        ),
      ],
    );
  }
}
