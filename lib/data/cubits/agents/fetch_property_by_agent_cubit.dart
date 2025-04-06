import 'package:ebroker/exports/main_export.dart';

class FetchPropertyByAgentCubit extends Cubit<FetchPropertyByAgentState> {
  FetchPropertyByAgentCubit() : super(FetchPropertyByAgentInitial());

  PropertyRepository propertyRepository = PropertyRepository();

  Future<void> fetchPropertyByAgent({
    required int agentId,
    required int propertyId,
  }) async {
    try {
      emit(FetchPropertyByAgentInProgress());

      emit(
        FetchPropertyByAgentSuccess(
          property: await propertyRepository.fetchPropertyFromPropertyId(
            id: propertyId,
            isMyProperty: false,
          ),
        ),
      );
    } catch (e) {
      emit(FetchPropertyByAgentFailure(e.toString()));
    }
  }
}

sealed class FetchPropertyByAgentState {}

final class FetchPropertyByAgentInitial extends FetchPropertyByAgentState {}

final class FetchPropertyByAgentInProgress extends FetchPropertyByAgentState {}

final class FetchPropertyByAgentSuccess extends FetchPropertyByAgentState {
  FetchPropertyByAgentSuccess({
    required this.property,
  });
  PropertyModel property;
}

final class FetchPropertyByAgentFailure extends FetchPropertyByAgentState {
  FetchPropertyByAgentFailure(this.error);
  final String error;
}
