import 'package:bloc/bloc.dart';
import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/repositories/agents_repository.dart';

abstract class FetchAgentsState {}

class FetchAgentsInitial extends FetchAgentsState {}

class FetchAgentsLoading extends FetchAgentsState {}

class FetchAgentsSuccess extends FetchAgentsState {
  FetchAgentsSuccess({
    required this.offset,
    required this.total,
    required this.agents,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<AgentModel> agents;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchAgentsSuccess copyWith({
    List<AgentModel>? agents,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentsSuccess(
      agents: agents ?? this.agents,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchAgentsFailure extends FetchAgentsState {
  FetchAgentsFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchAgentsCubit extends Cubit<FetchAgentsState> {
  FetchAgentsCubit() : super(FetchAgentsInitial());

  final AgentsRepository _agentsRepository = AgentsRepository();

  Future<void> fetchAgents({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchAgentsLoading());
      final dataOutput = await _agentsRepository.fetchAllAgents(offset: 0);
      final agents = List<AgentModel>.from(dataOutput.modelList);
      emit(
        FetchAgentsSuccess(
          offset: 0,
          total: dataOutput.total,
          agents: agents,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } catch (e) {
      emit(FetchAgentsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchAgentsSuccess) {
      return (state as FetchAgentsSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore() async {
    if (state is FetchAgentsSuccess) {
      try {
        final scrollSuccess = state as FetchAgentsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchAgentsSuccess).copyWith(isLoadingMore: true),
        );

        final dataOutput = await _agentsRepository.fetchAllAgents(
          offset: (state as FetchAgentsSuccess).agents.length,
        );

        final currentState = state as FetchAgentsSuccess;
        final updatedAgents = currentState.agents..addAll(dataOutput.modelList);
        emit(
          FetchAgentsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            agents: updatedAgents,
            offset: updatedAgents.length,
            total: dataOutput.total,
          ),
        );
      } catch (e) {
        emit(
          (state as FetchAgentsSuccess).copyWith(hasLoadMoreError: true),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchAgentsSuccess) {
      return (state as FetchAgentsSuccess)
              .agents
              .whereType<AgentModel>()
              .length <
          (state as FetchAgentsSuccess).total;
    }
    return false;
  }

  bool isAgentsEmpty() {
    if (state is FetchAgentsSuccess) {
      return (state as FetchAgentsSuccess).agents.isEmpty &&
          (state as FetchAgentsSuccess).isLoadingMore == false;
    }
    return true;
  }
}
