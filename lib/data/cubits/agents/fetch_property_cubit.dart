import 'package:ebroker/data/model/agent/agents_property_model.dart';
import 'package:ebroker/data/repositories/agents_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchAgentsPropertyState {}

final class FetchAgentsPropertyInitial extends FetchAgentsPropertyState {}

final class FetchAgentsPropertyLoading extends FetchAgentsPropertyState {}

final class FetchAgentsPropertySuccess extends FetchAgentsPropertyState {
  FetchAgentsPropertySuccess({
    required this.offset,
    required this.total,
    required this.agentsProperty,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final AgentsProperty agentsProperty;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchAgentsPropertySuccess copyWith({
    AgentsProperty? agentsProperty,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentsPropertySuccess(
      agentsProperty: agentsProperty ?? this.agentsProperty,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

final class FetchAgentsPropertyFailure extends FetchAgentsPropertyState {
  FetchAgentsPropertyFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchAgentsPropertyCubit extends Cubit<FetchAgentsPropertyState> {
  FetchAgentsPropertyCubit() : super(FetchAgentsPropertyInitial());

  final AgentsRepository customerRepository = AgentsRepository();

  Future<void> fetchAgentsProperty({
    required int agentId,
    required bool forceRefresh,
    required bool isAdmin,
  }) async {
    try {
      emit(FetchAgentsPropertyLoading());
      final (:total, :agentsProperty) =
          await customerRepository.fetchAgentProperties(
        offset: 0,
        agentId: agentId,
        isAdmin: isAdmin,
      );
      emit(
        FetchAgentsPropertySuccess(
          offset: 0,
          total: total,
          agentsProperty: agentsProperty,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } catch (e) {
      emit(FetchAgentsPropertyFailure(e));
    }
  }

  bool isLoadingMore() {
    if (state is FetchAgentsPropertySuccess) {
      return (state as FetchAgentsPropertySuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({required bool isAdmin}) async {
    if (state is FetchAgentsPropertySuccess) {
      try {
        final scrollSuccess = state as FetchAgentsPropertySuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchAgentsPropertySuccess).copyWith(isLoadingMore: true),
        );

        final (:total, :agentsProperty) =
            await customerRepository.fetchAgentProperties(
          agentId: (state as FetchAgentsPropertySuccess)
              .agentsProperty
              .customerData
              .id,
          offset: (state as FetchAgentsPropertySuccess)
              .agentsProperty
              .propertiesData
              .length,
          isAdmin: isAdmin,
        );

        final currentState = state as FetchAgentsPropertySuccess;

        emit(
          FetchAgentsPropertySuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            agentsProperty: currentState.agentsProperty.copyWith(
              propertiesData: [
                ...currentState.agentsProperty.propertiesData,
                ...agentsProperty.propertiesData,
              ],
            ),
            offset: (state as FetchAgentsPropertySuccess)
                .agentsProperty
                .propertiesData
                .length,
            total: total,
          ),
        );
      } catch (e) {
        emit(
          (state as FetchAgentsPropertySuccess)
              .copyWith(hasLoadMoreError: true),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchAgentsPropertySuccess) {
      final agentsProperty =
          (state as FetchAgentsPropertySuccess).agentsProperty;
      final total = (state as FetchAgentsPropertySuccess).total;
      return agentsProperty.propertiesData.length < total;
    }
    return false;
  }

  bool isCustomersEmpty() {
    if (state is FetchAgentsPropertySuccess) {
      return (state as FetchAgentsPropertySuccess)
              .agentsProperty
              .propertiesData
              .isEmpty &&
          (state as FetchAgentsPropertySuccess).isLoadingMore == false;
    }
    return true;
  }
}
