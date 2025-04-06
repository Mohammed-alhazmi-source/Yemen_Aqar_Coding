import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangePropertyStatusState {}

class ChangePropertyStatusInitial extends ChangePropertyStatusState {}

class ChangePropertyStatusInProgress extends ChangePropertyStatusState {}

class ChangePropertyStatusSuccess extends ChangePropertyStatusState {
  final String? message;
  ChangePropertyStatusSuccess({
    this.message,
  });

  ChangePropertyStatusSuccess copyWith({
    String? message,
  }) {
    return ChangePropertyStatusSuccess(
      message: message ?? this.message,
    );
  }
}

class ChangePropertyStatusFailure extends ChangePropertyStatusState {
  final String error;
  ChangePropertyStatusFailure(this.error);
}

class ChangePropertyStatusCubit extends Cubit<ChangePropertyStatusState> {
  ChangePropertyStatusCubit() : super(ChangePropertyStatusInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> enableProperty({
    required int propertyId,
    required int status,
  }) async {
    try {
      emit(ChangePropertyStatusInProgress());
      final result = await _propertyRepository.changePropertyStatus(
        propertyId: propertyId,
        status: status,
      );
      if (result['error'] == true) {
        emit(ChangePropertyStatusFailure(result['message']));
      } else {
        emit(ChangePropertyStatusSuccess(message: result['message']));
      }
    } catch (e) {
      emit(ChangePropertyStatusFailure(e.toString()));
    }
  }

  Future<void> disableProperty({
    required int propertyId,
    required int status,
  }) async {
    try {
      emit(ChangePropertyStatusInProgress());
      final result = await _propertyRepository.changePropertyStatus(
        propertyId: propertyId,
        status: status,
      );
      if (result['error'] == true) {
        emit(ChangePropertyStatusFailure(result['message']));
      } else {
        emit(ChangePropertyStatusSuccess(message: result['message']));
      }
    } catch (e) {
      emit(ChangePropertyStatusFailure(e.toString()));
    }
  }
}
