import 'package:ebroker/data/cubits/agents/fetch_agents_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agents_card.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({
    super.key,
  });

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const AgentListScreen(),
    );
  }

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  @override
  void initState() {
    context.read<FetchAgentsCubit>().fetchAgents(
          forceRefresh: false,
        );
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    agentsListScreenController.addListener(pageScrollListener);
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (agentsListScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchAgentsCubit>().hasMoreData()) {
          context.read<FetchAgentsCubit>().fetchMore();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildAgentsList(context));
  }
}

Widget buildAgentsList(BuildContext context) {
  return Scaffold(
    backgroundColor: context.color.primaryColor,
    appBar: UiUtils.buildAppBar(
      context,
      title: UiUtils.translate(context, 'agents'),
      showBackButton: true,
    ),
    body: RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        await context.read<FetchAgentsCubit>().fetchAgents(
              forceRefresh: true,
            );
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        controller: agentsListScreenController,
        child: Column(
          children: <Widget>[
            BlocBuilder<FetchAgentsCubit, FetchAgentsState>(
              builder: (context, state) {
                if (state is FetchAgentsFailure) {
                  return const SomethingWentWrong();
                }
                if (state is FetchAgentsLoading) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      left: sidePadding,
                      right: sidePadding,
                      top: 8,
                      bottom: 25,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                      height: 260,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const CustomShimmer(
                        height: 155,
                        width: 200,
                      );
                    },
                  );
                }
                if (state is FetchAgentsSuccess && state.agents.isEmpty) {
                  return NoDataFound(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.agentListScreen);
                    },
                  );
                }
                if (state is FetchAgentsSuccess && state.agents.isNotEmpty) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      left: sidePadding,
                      right: sidePadding,
                      top: 8,
                      bottom: 25,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                      height: 260,
                    ),
                    itemCount: state.agents.length,
                    itemBuilder: (context, index) {
                      final agent = state.agents[index];
                      return AgentCard(
                        agent: agent,
                        propertyCount: agent.propertyCount,
                        name: agent.name,
                      );
                    },
                  );
                }
                return Container();
              },
            ),
            if (context.watch<FetchAgentsCubit>().isLoadingMore()) ...[
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
