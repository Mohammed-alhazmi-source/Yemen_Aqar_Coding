import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeletePropertyState {}

class DeletePropertyInitial extends DeletePropertyState {}

class DeletePropertyInProgress extends DeletePropertyState {}

class DeletePropertySuccess extends DeletePropertyState {}

class DeletePropertyFailure extends DeletePropertyState {
  DeletePropertyFailure(this.errorMessage);
  final String errorMessage;
}

class DeletePropertyCubit extends Cubit<DeletePropertyState> {
  DeletePropertyCubit() : super(DeletePropertyInitial());
  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> delete(int id) async {
    try {
      emit(DeletePropertyInProgress());

      await _propertyRepository.deleteProperty(id);
      emit(DeletePropertySuccess());
    } catch (e) {
      emit(DeletePropertyFailure(e.toString()));
    }
  }
}
