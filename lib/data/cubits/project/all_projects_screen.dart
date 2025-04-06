import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:flutter/material.dart';

class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const AllProjectsScreen();
      },
    );
  }

  @override
  State<AllProjectsScreen> createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    context.read<FetchMyProjectsListCubit>().fetch();
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    _controller.addListener(pageScrollListener);
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (_controller.isEndReached()) {
      if (mounted) {
        if (context.read<FetchMyProjectsListCubit>().hasMoreData()) {
          context.read<FetchMyProjectsListCubit>().fetchMore();
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
        showBackButton: true,
        title: UiUtils.translate(context, 'projects'),
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<FetchMyProjectsListCubit>().fetchMyProjects();
        },
        child: SingleChildScrollView(
          controller: _controller,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child:
              BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
            builder: (context, state) {
              if (state is FetchMyProjectsListSuccess) {
                return Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.projects.length,
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
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
