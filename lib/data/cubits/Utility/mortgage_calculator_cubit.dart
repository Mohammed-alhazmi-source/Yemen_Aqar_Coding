import 'package:ebroker/data/model/mortgage_calculator_model.dart';
import 'package:ebroker/data/repositories/mortgage_calculator_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class MortgageCalculatorState {}

class MortgageCalculatorInitial extends MortgageCalculatorState {}

class MortgageCalculatorLoading extends MortgageCalculatorState {}

class MortgageCalculatorSuccess extends MortgageCalculatorState {
  MortgageCalculatorSuccess({
    required this.mortgageCalculatorModel,
  });

  final MortgageCalculatorModel mortgageCalculatorModel;

  MortgageCalculatorSuccess copyWith({
    required MortgageCalculatorModel mortgageCalculatorModel,
  }) {
    return MortgageCalculatorSuccess(
      mortgageCalculatorModel: mortgageCalculatorModel,
    );
  }
}

class MortgageCalculatorFailure extends MortgageCalculatorState {
  MortgageCalculatorFailure(this.errorMessage);

  final dynamic errorMessage;
}

class MortgageCalculatorCubit extends Cubit<MortgageCalculatorState> {
  MortgageCalculatorCubit() : super(MortgageCalculatorInitial());

  final MortgageCalculatorRepository _mortgageCalculatorRepository =
      MortgageCalculatorRepository();

  Future<void> calculateMortgage({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(MortgageCalculatorLoading());

      final mortgageData =
          await _mortgageCalculatorRepository.fetchMortgageCalculatorData(
        parameters: parameters,
      );

      emit(
        MortgageCalculatorSuccess(
          mortgageCalculatorModel: mortgageData,
        ),
      );
    } catch (e) {
      emit(MortgageCalculatorFailure(e.toString()));
    }
  }

  void emptyMortgageCalculatorData() {
    emit(MortgageCalculatorInitial());
  }
}
