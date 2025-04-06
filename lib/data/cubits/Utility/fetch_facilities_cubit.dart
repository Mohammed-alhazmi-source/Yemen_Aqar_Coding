import 'package:ebroker/data/model/facilities_model.dart';
import 'package:ebroker/data/repositories/facilities_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class FetchFacilitiesState {}

class FetchFacilitiesInitial extends FetchFacilitiesState {}

class FetchFacilitiesLoading extends FetchFacilitiesState {}

class FetchFacilitiesSuccess extends FetchFacilitiesState {
  final List<FacilitiesModel> facilities;

  FetchFacilitiesSuccess({required this.facilities});
}

class FetchFacilitiesCubit extends Cubit<FetchFacilitiesState> {
  final FacilitiesRepository _facilitiesRepository = FacilitiesRepository();

  FetchFacilitiesCubit() : super(FetchFacilitiesInitial());

  Future<void> fetch() async {
    emit(FetchFacilitiesLoading());
    final facilities = await _facilitiesRepository.fetchFacilities();
    emit(FetchFacilitiesSuccess(facilities: facilities));
  }
}
