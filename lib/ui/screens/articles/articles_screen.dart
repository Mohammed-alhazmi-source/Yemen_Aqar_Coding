import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ArticlesScreen();
      },
    );
  }

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    context.read<FetchArticlesCubit>().fetchArticles();
    _pageScrollController.addListener(pageScrollListen);
    super.initState();
  }

  void pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchArticlesCubit>().hasMoreData()) {
        context.read<FetchArticlesCubit>().fetchArticlesMore();
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        await context.read<FetchArticlesCubit>().fetchArticles();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: UiUtils.translate(
            context,
            'articles',
          ),
        ),
        body: BlocBuilder<FetchArticlesCubit, FetchArticlesState>(
          builder: (context, state) {
            if (state is FetchArticlesInProgress) {
              return buildArticlesShimmer();
            }
            if (state is FetchArticlesFailure) {
              if (state.errorMessage is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchArticlesCubit>().fetchArticles();
                  },
                );
              }

              return const SomethingWentWrong();
            }
            if (state is FetchArticlesSuccess) {
              if (state.articlemodel.isEmpty) {
                return const NoDataFound();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller: _pageScrollController,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.articlemodel.length,
                      itemBuilder: (context, index) {
                        final article = state.articlemodel[index];

                        return buildArticleCard(context, article);

                        // return article(state, index);
                      },
                    ),
                  ),
                  if (state.isLoadingMore) const CircularProgressIndicator(),
                  if (state.loadingMoreError)
                    CustomText(UiUtils.translate(context, 'somethingWentWrng')),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildArticleCard(BuildContext context, ArticleModel article) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.articleDetailsScreenRoute,
            arguments: {
              'model': article,
            },
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 1.5,
              color: context.color.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: UiUtils.getImage(
                    article.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 6),
                child: CustomText(
                  (article.title ?? '').firstUpperCase(),
                  maxLines: 2,
                  color: context.color.textColorDark,
                  fontSize: context.font.normal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: CustomText(
                  stripHtmlTags(article.description ?? '').trim(),
                  maxLines: 3,
                  color: context.color.textLightColor,
                  fontSize: context.font.small,
                ),
              ),
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 6),
                  child: CustomText(
                    article.date == null ? '' : article.date.toString(),
                    color: context.color.textLightColor,
                    fontSize: context.font.smaller,
                  )),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String stripHtmlTags(String htmlString) {
    final exp = RegExp('<[^>]*>', multiLine: true);
    final strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  Widget buildArticlesShimmer() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: 287.rh(context),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                border: Border.all(
                  width: 1.5,
                  color: context.color.borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer(
                    width: double.infinity,
                    height: 160.rh(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomShimmer(
                      width: 100.rw(context),
                      height: 10.rh(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomShimmer(
                      width: 160.rw(context),
                      height: 10.rh(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomShimmer(
                      width: 150.rw(context),
                      height: 10.rh(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Container article(FetchArticlesSuccess state, int index) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomText(
                state.articlemodel[index].title!,
                color: Colors.black,
              ),
              const Divider(),
              if (state.articlemodel[index].image != '') ...[
                Image.network(state.articlemodel[index].image!),
              ],
              const Divider(),
              Html(data: state.articlemodel[index].description),
            ],
          ),
        ),
      ),
    );
  }
}
