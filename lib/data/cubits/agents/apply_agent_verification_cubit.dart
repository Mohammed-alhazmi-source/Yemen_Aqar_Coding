import 'package:ebroker/data/repositories/agents_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ApplyAgentVerificationState {}

class ApplyAgentVerificationInitial extends ApplyAgentVerificationState {}

class ApplyAgentVerificationInProgress extends ApplyAgentVerificationState {}

class ApplyAgentVerificationSuccess extends ApplyAgentVerificationState {
  ApplyAgentVerificationSuccess(this.response);
  final Map<String, dynamic> response;
}

class ApplyAgentVerificationFailure extends ApplyAgentVerificationState {
  ApplyAgentVerificationFailure(this.errorMessage);
  final String errorMessage;
}

class ApplyAgentVerificationCubit extends Cubit<ApplyAgentVerificationState> {
  ApplyAgentVerificationCubit() : super(ApplyAgentVerificationInitial());
  final AgentsRepository _agentRepository = AgentsRepository();

  Future<void> applyVerification({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(ApplyAgentVerificationInProgress());
      final result = await _agentRepository.createAgentVerification(
        parameters: parameters,
      );

      if (result['error'] == false) {
        emit(ApplyAgentVerificationSuccess(result));
      } else {
        emit(ApplyAgentVerificationFailure(result['message'].toString()));
      }
    } catch (e) {
      emit(ApplyAgentVerificationFailure(e.toString()));
    }
  }
}
