// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInitial extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInProgress extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesSuccess extends FetchNearbyPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchNearbyPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchNearbyPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchNearbyPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set isLoadingMore(bool isLoadingMore) {
    // TODO(R): implement isLoadingMore
  }

  @override
  set properties(List<PropertyModel> properties) {
    // TODO(R): implement properties
  }
}

class FetchNearbyPropertiesFailure extends FetchNearbyPropertiesState
    implements PropertyErrorStateWireframe {
  @override
  final dynamic error;
  FetchNearbyPropertiesFailure(this.error);

  @override
  set error(error) {
    // TODO(R): implement error
  }
}

class FetchNearbyPropertiesCubit extends Cubit<FetchNearbyPropertiesState>
    implements PropertyCubitWireframe {
  FetchNearbyPropertiesCubit() : super(FetchNearbyPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    if (forceRefresh != true) {
      if (state is FetchNearbyPropertiesSuccess) {
        await Future.delayed(
          Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay,
          ),
        );
      } else {
        emit(FetchNearbyPropertiesInProgress());
      }
    } else {
      emit(FetchNearbyPropertiesInProgress());
    }

    try {
      if (forceRefresh == true) {
        final result = await _propertyRepository.fetchNearByProperty(
          offset: 0,
        );
        emit(
          FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchNearbyPropertiesSuccess) {
          final result = await _propertyRepository.fetchNearByProperty(
            offset: 0,
          );
          emit(
            FetchNearbyPropertiesSuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total,
            ),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              final result = await _propertyRepository.fetchNearByProperty(
                offset: 0,
              );
              emit(
                FetchNearbyPropertiesSuccess(
                  isLoadingMore: false,
                  loadingMoreError: false,
                  properties: result.modelList,
                  offset: 0,
                  total: result.total,
                ),
              );
            },
            onNoInternet: () {
              emit(
                FetchNearbyPropertiesSuccess(
                  total: (state as FetchNearbyPropertiesSuccess).total,
                  offset: (state as FetchNearbyPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchNearbyPropertiesSuccess).isLoadingMore,
                  loadingMoreError:
                      (state as FetchNearbyPropertiesSuccess).loadingMoreError,
                  properties:
                      (state as FetchNearbyPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchNearbyPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchNearbyPropertiesSuccess) {
      final properties = (state as FetchNearbyPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchNearbyPropertiesSuccess)
            .copyWith(properties: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchNearbyPropertiesSuccess) {
        if ((state as FetchNearbyPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchNearbyPropertiesSuccess).copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchNearByProperty(
          offset: (state as FetchNearbyPropertiesSuccess).properties.length,

          // sendCityName: true
        );

        final propertiesState = state as FetchNearbyPropertiesSuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset: (state as FetchNearbyPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchNearbyPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchNearbyPropertiesSuccess) {
      return (state as FetchNearbyPropertiesSuccess).properties.length <
          (state as FetchNearbyPropertiesSuccess).total;
    }
    return false;
  }
}
