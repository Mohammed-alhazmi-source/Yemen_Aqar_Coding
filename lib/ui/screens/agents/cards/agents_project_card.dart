import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentProjects extends StatefulWidget {
  const AgentProjects({
    required this.agentId,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final int agentId;

  @override
  State<AgentProjects> createState() => _AgentProjectsState();
}

class _AgentProjectsState extends State<AgentProjects> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(onPageEnd);
    context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
          forceRefresh: false,
          agentId: widget.agentId,
          isAdmin: widget.isAdmin,
        );
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchAgentsProjectCubit>().hasMoreData()) {
        context.read<FetchAgentsProjectCubit>().fetchMore(
              isAdmin: widget.isAdmin,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FetchAgentsProjectCubit, FetchAgentsProjectState>(
        builder: (context, state) {
          if (state is FetchAgentsProjectLoading) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          }
          if (state is FetchAgentsProjectFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchAgentsProjectSuccess &&
              state.agentsProperty.projectData.isEmpty) {
            return Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(
                top: 15,
                left: 18,
                right: 18,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: NoDataFound(
                onTap: () {
                  context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
                        agentId: widget.agentId,
                        forceRefresh: true,
                        isAdmin: widget.isAdmin,
                      );
                },
              ),
            );
          }
          if (state is FetchAgentsProjectSuccess) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(
                      top: 15,
                      left: 18,
                      right: 18,
                    ),
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 18,
                      right: 18,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      border: Border.all(
                        color: context.color.borderColor,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          height: 36,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            border: Border.all(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: CustomText(
                            fontSize: 16,
                            color: context.color.inverseSurface,
                            fontWeight: FontWeight.w700,
                            '${state.agentsProperty.customerData.projectCount} ${UiUtils.translate(context, 'projects')}',
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            controller: _pageScrollController,
                            itemCount: state.agentsProperty.projectData.length,
                            itemBuilder: (context, index) {
                              final agentsProject =
                                  state.agentsProperty.projectData[index];
                              return GestureDetector(
                                onTap: () async {
                                  unawaited(Widgets.showLoader(context));
                                  final projectRepository = ProjectRepository();
                                  final projectDetails = await projectRepository
                                      .getProjectDetails(id: agentsProject.id);
                                  Future.delayed(
                                    Duration.zero,
                                    () {
                                      Widgets.hideLoder(context);
                                      HelperUtils.goToNextPage(
                                        Routes.projectDetailsScreen,
                                        context,
                                        false,
                                        args: {
                                          'project': projectDetails,
                                        },
                                      );
                                    },
                                  );
                                },
                                child: ProjectCard(
                                  categoryName: agentsProject.category.category,
                                  url: agentsProject.image,
                                  title: agentsProject.title,
                                  description: agentsProject.city,
                                  categoryIcon: agentsProject.category.image,
                                  status: agentsProject.type,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (context
                    .watch<FetchAgentsProjectCubit>()
                    .isLoadingMore()) ...[
                  Center(child: UiUtils.progress()),
                ],
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
