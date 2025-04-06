import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchMyProjectsListState {}

class FetchMyProjectsListInitial extends FetchMyProjectsListState {}

class FetchMyProjectsListInProgress extends FetchMyProjectsListState {}

class FetchMyProjectsListSuccess extends FetchMyProjectsListState {
  FetchMyProjectsListSuccess({
    required this.isLoadingMore,
    required this.hasError,
    required this.total,
    required this.projects,
    required this.offset,
  });
  final bool isLoadingMore;
  final bool hasError;
  final int total;
  final List<ProjectModel> projects;
  final int offset;

  FetchMyProjectsListSuccess copyWith({
    bool? isLoadingMore,
    bool? hasError,
    int? total,
    List<ProjectModel>? projects,
    int? offset,
  }) {
    return FetchMyProjectsListSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      total: total ?? this.total,
      projects: projects ?? this.projects,
      offset: offset ?? this.offset,
    );
  }
}

class FetchMyProjectsListFail extends FetchMyProjectsListState {
  FetchMyProjectsListFail(this.error);
  final dynamic error;
}

class FetchMyProjectsListCubit extends Cubit<FetchMyProjectsListState> {
  FetchMyProjectsListCubit() : super(FetchMyProjectsListInitial());
  final ProjectRepository _projectRepository = ProjectRepository();

  Future<void> fetch() async {
    try {
      emit(FetchMyProjectsListInProgress());
      final dataOutput = await _projectRepository.getProjects(offset: 0);

      emit(
        FetchMyProjectsListSuccess(
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: dataOutput.total,
          projects: dataOutput.modelList,
        ),
      );
    } catch (e) {
      emit(FetchMyProjectsListFail(e));
    }
  }

  Future<void> fetchMyProjects() async {
    try {
      emit(FetchMyProjectsListInProgress());
      final dataOutput = await _projectRepository.getMyProjects(offset: 0);

      emit(
        FetchMyProjectsListSuccess(
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          total: dataOutput.total,
          projects: dataOutput.modelList,
        ),
      );
    } catch (e) {
      emit(FetchMyProjectsListFail(e));
    }
  }

  Future<void> delete(int id) async {
    if (state is FetchMyProjectsListSuccess) {
      final indexWhere = (state as FetchMyProjectsListSuccess)
          .projects
          .indexWhere((element) => element.id == id);
      (state as FetchMyProjectsListSuccess).projects.removeAt(indexWhere);
      emit(
        (state as FetchMyProjectsListSuccess)
            .copyWith(projects: (state as FetchMyProjectsListSuccess).projects),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchMyProjectsListSuccess) {
      return (state as FetchMyProjectsListSuccess)
              .projects
              .whereType<ProjectModel>()
              .length <
          (state as FetchMyProjectsListSuccess).total;
    }
    return false;
  }

  void update(ProjectModel model) {
    if (state is FetchMyProjectsListSuccess) {
      final indexWhere = (state as FetchMyProjectsListSuccess)
          .projects
          .indexWhere((element) => element.id == model.id);
      if (indexWhere.isNegative) {
        (state as FetchMyProjectsListSuccess).projects.add(model);
      } else {
        (state as FetchMyProjectsListSuccess).projects[indexWhere] = model;
      }
      emit(
        (state as FetchMyProjectsListSuccess)
            .copyWith(projects: (state as FetchMyProjectsListSuccess).projects),
      );
    }
  }

  Future<void> fetchMore() async {
    try {
      final scrollSuccess = state as FetchMyProjectsListSuccess;
      if (scrollSuccess.isLoadingMore) return;
      emit(
        (state as FetchMyProjectsListSuccess).copyWith(isLoadingMore: true),
      );
      final result = await _projectRepository.fetchAllProjects(
        offset: (state as FetchMyProjectsListSuccess).projects.length,
      );

      final currentState = state as FetchMyProjectsListSuccess;
      final updatedProjects = currentState.projects..addAll(result.modelList);

      emit(
        FetchMyProjectsListSuccess(
          projects: updatedProjects,
          isLoadingMore: false,
          hasError: false,
          offset: updatedProjects.length,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(
        (state as FetchMyProjectsListSuccess)
            .copyWith(isLoadingMore: false, hasError: true),
      );
    }
  }
}
