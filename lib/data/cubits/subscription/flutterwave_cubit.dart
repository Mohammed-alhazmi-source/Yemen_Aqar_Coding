import 'package:ebroker/data/repositories/flutterwave_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FlutterwaveState {}

class FlutterwaveInitial extends FlutterwaveState {}

class FlutterwaveInProgress extends FlutterwaveState {}

class FlutterwaveSuccess extends FlutterwaveState {
  FlutterwaveSuccess(this.flutterwaveLink);
  final String flutterwaveLink;
}

class FlutterwaveFail extends FlutterwaveState {
  FlutterwaveFail(this.error);
  final dynamic error;
}

class FlutterwaveCubit extends Cubit<FlutterwaveState> {
  FlutterwaveCubit() : super(FlutterwaveInitial());
  final flutterwaveRepository = FlutterwaveRepository();
  Future<void> assign(
    int packageId,
  ) async {
    try {
      emit(FlutterwaveInProgress());
      final response = await flutterwaveRepository.fetchFlutterwaveLink(
        packageId: packageId,
      );
      emit(FlutterwaveSuccess(
        response,
      ));
    } catch (e) {
      emit(FlutterwaveFail(e.toString()));
    }
  }
}
