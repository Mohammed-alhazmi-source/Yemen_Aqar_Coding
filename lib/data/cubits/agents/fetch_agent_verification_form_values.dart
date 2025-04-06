import 'package:ebroker/data/model/agent/agent_verification_form_values_model.dart';
import 'package:ebroker/data/repositories/agents_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchAgentVerificationFormValuesState {}

class FetchAgentVerificationFormValuesInitial
    extends FetchAgentVerificationFormValuesState {}

class FetchAgentVerificationFormValuesLoading
    extends FetchAgentVerificationFormValuesState {}

class FetchAgentVerificationFormValuesSuccess
    extends FetchAgentVerificationFormValuesState {
  FetchAgentVerificationFormValuesSuccess({
    required this.values,
  });

  final List<AgentVerificationFormValueModel> values;

  FetchAgentVerificationFormValuesSuccess copyWith({
    List<AgentVerificationFormValueModel>? values,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentVerificationFormValuesSuccess(
      values: values ?? this.values,
    );
  }
}

class FetchAgentVerificationFormValuesFailure
    extends FetchAgentVerificationFormValuesState {
  FetchAgentVerificationFormValuesFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchAgentVerificationFormValuesCubit
    extends Cubit<FetchAgentVerificationFormValuesState> {
  FetchAgentVerificationFormValuesCubit()
      : super(FetchAgentVerificationFormValuesInitial());

  final AgentsRepository _agentsRepository = AgentsRepository();

  Future<void> fetchAgentsVerificationFormValues({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchAgentVerificationFormValuesLoading());
      final dataOutput =
          await _agentsRepository.getAgentVerificationFormValues();
      final values = List<AgentVerificationFormValueModel>.from(dataOutput);
      emit(
        FetchAgentVerificationFormValuesSuccess(
          values: values,
        ),
      );
    } catch (e) {
      emit(FetchAgentVerificationFormValuesFailure(e.toString()));
    }
  }
}
