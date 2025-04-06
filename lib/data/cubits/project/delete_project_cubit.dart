import 'package:ebroker/exports/main_export.dart';

abstract class DeleteProjectState {}

class DeleteProjectInitial extends DeleteProjectState {}

class DeleteProjectInProgress extends DeleteProjectState {}

class DeleteProjectSuccess extends DeleteProjectState {
  DeleteProjectSuccess(this.id);
  final int id;
}

class DeleteProjectFail extends DeleteProjectState {
  DeleteProjectFail(this.error);
  final dynamic error;
}

class DeleteProjectCubit extends Cubit<DeleteProjectState> {
  DeleteProjectCubit() : super(DeleteProjectInitial());

  delete(
    int id,
  ) async {
    try {
      emit(DeleteProjectInProgress());
      await Api.post(
        url: Api.deleteProject,
        parameter: {'id': id},
      );
      emit(DeleteProjectSuccess(id));
    } catch (e) {
      emit(DeleteProjectFail(e));
    }
  }
}
