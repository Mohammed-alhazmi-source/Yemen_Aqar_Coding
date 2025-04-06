import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchProjectDetailsState {}

class FetchProjectDetailsInitial extends FetchProjectDetailsState {}

class FetchProjectDetailsInProgress extends FetchProjectDetailsState {}

class FetchProjectDetailsSuccess extends FetchProjectDetailsState {
  FetchProjectDetailsSuccess({
    required this.project,
  });
  final ProjectModel project;
}

class FetchProjectDetailsFail extends FetchProjectDetailsState {
  FetchProjectDetailsFail(this.error);
  final dynamic error;
}

class FetchProjectDetailsCubit extends Cubit<FetchProjectDetailsState> {
  FetchProjectDetailsCubit() : super(FetchProjectDetailsInitial());
  final ProjectRepository _projectRepository = ProjectRepository();
  Future<void> fetchProjectDetails({
    required int projectId,
  }) async {
    try {
      emit(FetchProjectDetailsInProgress());
      final projectDetails =
          await _projectRepository.getProjectDetails(id: projectId);

      emit(
        FetchProjectDetailsSuccess(
          project: projectDetails,
        ),
      );
    } catch (e) {
      emit(FetchProjectDetailsFail(e));
    }
  }
}
