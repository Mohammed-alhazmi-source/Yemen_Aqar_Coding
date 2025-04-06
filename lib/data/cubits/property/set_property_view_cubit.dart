import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SetPropertyViewState {}

class SetPropertyViewInitial extends SetPropertyViewState {}

class SetPropertyViewInProgress extends SetPropertyViewState {}

class SetPropertyViewSuccess extends SetPropertyViewState {}

class SetPropertyViewFailure extends SetPropertyViewState {
  SetPropertyViewFailure(this.errorMessage);
  final String errorMessage;
}

class SetPropertyViewCubit extends Cubit<SetPropertyViewState> {
  SetPropertyViewCubit() : super(SetPropertyViewInitial());
  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> set(String propertyId) async {
    try {
      emit(SetPropertyViewInProgress());
      await _propertyRepository.setProeprtyView(propertyId);
      emit(SetPropertyViewSuccess());
    } catch (e) {
      emit(SetPropertyViewFailure(e.toString()));
    }
  }
}
