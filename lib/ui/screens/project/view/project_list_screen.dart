import 'dart:ui';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:flutter/material.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ProjectListScreen();
      },
    );
  }

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<FetchMyProjectsListCubit>().fetchMyProjects();

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchMyProjectsListCubit>().hasMoreData()) {
          context.read<FetchMyProjectsListCubit>().fetchMore();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'myProjects'),
      ),
      body: BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
        builder: (context, state) {
          if (state is FetchMyProjectsListInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyProjectsListFail) {
            if (state.error is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context.read<FetchMyProjectsListCubit>().fetchMyProjects();
                },
              );
            }
            return const SomethingWentWrong();
          }
          if (state is FetchMyProjectsListSuccess) {
            if (state.projects.isEmpty) {
              return const NoDataFound();
            }
            return Column(
              children: [
                ListView.builder(
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: state.projects.length,
                  padding: const EdgeInsets.all(14),
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    return ProjectHorizontalCard(
                      project: project,
                    );
                  },
                ),
                if (context
                    .watch<FetchMyProjectsListCubit>()
                    .hasMoreData()) ...[
                  Center(child: UiUtils.progress()),
                ],
              ],
            );
            // return ProjectCard(title: "Hello",categoryIcon: ,);
          }
          if (state is FetchMyProjectsListFail) {
            return Center(
              child: CustomText(state.error.toString()),
            );
          }

          return Container();
        },
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.categoryName,
    required this.url,
    required this.title,
    required this.description,
    required this.categoryIcon,
    required this.status,
    this.onTap,
    this.color,
    super.key,
  });

  final String url;
  final String title;
  final String description;
  final String categoryIcon;
  final String categoryName;
  final VoidCallback? onTap;
  final String status;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color ?? context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        height: 231,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 147,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8),
                        ),
                        child: UiUtils.getImage(
                          url,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          blurHash: url,
                        ),
                      ),
                      PositionedDirectional(
                        end: 10,
                        bottom: 10,
                        child: Container(
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Center(
                                child: CustomText(
                                  categoryName.toLowerCase().translate(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font.smaller,
                                  color: context.color.textColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            UiUtils.imageType(
                              categoryIcon,
                              width: 18,
                              height: 18,
                              color: Constant.adaptThemeColorSvg
                                  ? context.color.tertiaryColor
                                  : null,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: CustomText(
                                categoryName,
                                fontWeight: FontWeight.w400,
                                fontSize: context.font.small,
                                color: context.color.textLightColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        CustomText(
                          title,
                          maxLines: 1,
                          fontSize: context.font.large,
                          color: context.color.textColorDark,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
