// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInitial extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInProgress extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesSuccess extends FetchPromotedPropertiesState
    implements PropertySuccessStateWireframe {
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;
  FetchPromotedPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  FetchPromotedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: propertymodel ?? properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set isLoadingMore(bool isLoadingMore) {}

  @override
  set properties(List<PropertyModel> properties) {}
}

class FetchPromotedPropertiesFailure extends FetchPromotedPropertiesState
    implements PropertyErrorStateWireframe {
  @override
  final String error;
  FetchPromotedPropertiesFailure(this.error);

  @override
  set error(error) {}
}

class FetchPromotedPropertiesCubit extends Cubit<FetchPromotedPropertiesState>
    implements PropertyCubitWireframe {
  FetchPromotedPropertiesCubit() : super(FetchPromotedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      await CacheData().getData(
        forceRefresh: forceRefresh == true,
        onProgress: () {
          emit(FetchPromotedPropertiesInProgress());
        },
        delay: loadWithoutDelay == true ? 0 : null,
        onNetworkRequest: () async {
          final result = await _propertyRepository.fetchPromotedProperty(
            offset: 0,
            sendCityName: true,
          );
          return FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          );
        },
        onOfflineData: () {
          return FetchPromotedPropertiesSuccess(
            total: (state as FetchPromotedPropertiesSuccess).total,
            offset: (state as FetchPromotedPropertiesSuccess).offset,
            isLoadingMore:
                (state as FetchPromotedPropertiesSuccess).isLoadingMore,
            loadingMoreError:
                (state as FetchPromotedPropertiesSuccess).loadingMoreError,
            properties: (state as FetchPromotedPropertiesSuccess).properties,
          );
        },
        onSuccess: (data) {
          emit(data);
        },
        hasData: state is FetchPromotedPropertiesSuccess,
      );
    } catch (e) {
      emit(FetchPromotedPropertiesFailure(e.toString()));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchPromotedPropertiesSuccess) {
      final properties = (state as FetchPromotedPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchPromotedPropertiesSuccess)
            .copyWith(propertymodel: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchPromotedPropertiesSuccess) {
        if ((state as FetchPromotedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchPromotedPropertiesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchPromotedProperty(
          offset: (state as FetchPromotedPropertiesSuccess).properties.length,
          sendCityName: true,
        );

        final propertymodelState = state as FetchPromotedPropertiesSuccess;
        propertymodelState.properties.addAll(result.modelList);
        emit(
          FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertymodelState.properties,
            offset: (state as FetchPromotedPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchPromotedPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchPromotedPropertiesSuccess) {
      return (state as FetchPromotedPropertiesSuccess).properties.length <
          (state as FetchPromotedPropertiesSuccess).total;
    }
    return false;
  }
}
