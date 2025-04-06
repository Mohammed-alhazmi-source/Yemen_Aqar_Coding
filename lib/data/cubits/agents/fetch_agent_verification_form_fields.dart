import 'package:ebroker/data/model/agent/agent_verification_form_fields_model.dart';
import 'package:ebroker/data/repositories/agents_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchAgentVerificationFormFieldsState {}

class FetchAgentVerificationFormFieldsInitial
    extends FetchAgentVerificationFormFieldsState {}

class FetchAgentVerificationFormFieldsLoading
    extends FetchAgentVerificationFormFieldsState {}

class FetchAgentVerificationFormFieldsSuccess
    extends FetchAgentVerificationFormFieldsState {
  FetchAgentVerificationFormFieldsSuccess({
    required this.fields,
  });

  final List<AgentVerificationFormFieldsModel> fields;

  FetchAgentVerificationFormFieldsSuccess copyWith({
    List<AgentVerificationFormFieldsModel>? fields,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentVerificationFormFieldsSuccess(
      fields: fields ?? this.fields,
    );
  }
}

class FetchAgentVerificationFormFieldsFailure
    extends FetchAgentVerificationFormFieldsState {
  FetchAgentVerificationFormFieldsFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchAgentVerificationFormFieldsCubit
    extends Cubit<FetchAgentVerificationFormFieldsState> {
  FetchAgentVerificationFormFieldsCubit()
      : super(FetchAgentVerificationFormFieldsInitial());

  final AgentsRepository _agentsRepository = AgentsRepository();

  Future<void> fetchAgentsVerificationForm({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchAgentVerificationFormFieldsLoading());
      final dataOutput =
          await _agentsRepository.getAgentVerificationFormFields();
      final fields = List<AgentVerificationFormFieldsModel>.from(dataOutput);
      emit(
        FetchAgentVerificationFormFieldsSuccess(
          fields: fields,
        ),
      );
    } catch (e) {
      emit(FetchAgentVerificationFormFieldsFailure(e.toString()));
    }
  }
}
