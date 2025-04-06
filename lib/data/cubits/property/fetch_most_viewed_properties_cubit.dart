// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInitial extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInProgress
    extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesSuccess extends FetchMostViewedPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchMostViewedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchMostViewedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchMostViewedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set properties(List<PropertyModel> properties) {
    // TODO(R): implement properties
  }

  @override
  set isLoadingMore(bool isLoadingMore) {
    // TODO(R): implement isLoadingMore
  }
}

class FetchMostViewedPropertiesFailure extends FetchMostViewedPropertiesState
    implements PropertyErrorStateWireframe {
  @override
  final dynamic error;
  FetchMostViewedPropertiesFailure(this.error);

  @override
  set error(error) {
    // TODO(R): implement error
  }
}

class FetchMostViewedPropertiesCubit
    extends Cubit<FetchMostViewedPropertiesState>
    implements PropertyCubitWireframe {
  FetchMostViewedPropertiesCubit() : super(FetchMostViewedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    // if (state is FetchMostViewedPropertiesSuccess) {
    //   return;
    // }
    if (forceRefresh != true) {
      if (state is FetchMostViewedPropertiesSuccess) {
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(
          Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay,
          ),
        );
        // });
      } else {
        emit(FetchMostViewedPropertiesInProgress());
      }
    } else {
      emit(FetchMostViewedPropertiesInProgress());
    }
    try {
      if (forceRefresh == true) {
        final result = await _propertyRepository.fetchMostViewedProperty(
          offset: 0,
          sendCityName: true,
        );

        emit(
          FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchMostViewedPropertiesSuccess) {
          final result = await _propertyRepository.fetchMostViewedProperty(
            offset: 0,
            sendCityName: true,
          );

          emit(
            FetchMostViewedPropertiesSuccess(
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
              final result = await _propertyRepository.fetchMostViewedProperty(
                offset: 0,
                sendCityName: true,
              );

              emit(
                FetchMostViewedPropertiesSuccess(
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
                FetchMostViewedPropertiesSuccess(
                  total: (state as FetchMostViewedPropertiesSuccess).total,
                  offset: (state as FetchMostViewedPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchMostViewedPropertiesSuccess).isLoadingMore,
                  loadingMoreError: (state as FetchMostViewedPropertiesSuccess)
                      .loadingMoreError,
                  properties:
                      (state as FetchMostViewedPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchMostViewedPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMostViewedPropertiesSuccess) {
      final properties = (state as FetchMostViewedPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMostViewedPropertiesSuccess)
            .copyWith(properties: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchMostViewedPropertiesSuccess) {
        if ((state as FetchMostViewedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMostViewedPropertiesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchMostViewedProperty(
          offset: (state as FetchMostViewedPropertiesSuccess).properties.length,
          sendCityName: true,
        );

        final propertiesState = state as FetchMostViewedPropertiesSuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchMostViewedPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchMostViewedPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchMostViewedPropertiesSuccess) {
      return (state as FetchMostViewedPropertiesSuccess).properties.length <
          (state as FetchMostViewedPropertiesSuccess).total;
    }
    return false;
  }
}
