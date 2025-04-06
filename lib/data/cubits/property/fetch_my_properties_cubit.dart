// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyPropertiesState {}

class FetchMyPropertiesInitial extends FetchMyPropertiesState {}

class FetchMyPropertiesInProgress extends FetchMyPropertiesState {}

class FetchMyPropertiesSuccess extends FetchMyPropertiesState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> myProperty;
  FetchMyPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.myProperty,
  });

  FetchMyPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    List<PropertyModel>? myProperty,
  }) {
    return FetchMyPropertiesSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasMoreData ?? hasError,
      myProperty: myProperty ?? this.myProperty,
    );
  }
}

class FetchMyPropertiesFailure extends FetchMyPropertiesState {
  final dynamic errorMessage;

  FetchMyPropertiesFailure(this.errorMessage);
}

class FetchMyPropertiesCubit extends Cubit<FetchMyPropertiesState> {
  FetchMyPropertiesCubit() : super(FetchMyPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchMyProperties({
    required String type,
    required String status,
  }) async {
    try {
      emit(FetchMyPropertiesInProgress());
      final result = await _propertyRepository.fetchMyProperties(
        offset: 0,
        type: type,
        status: status,
      );
      emit(
        FetchMyPropertiesSuccess(
          hasError: false,
          isLoadingMore: false,
          myProperty: result.modelList,
          total: result.total,
          offset: 0,
        ),
      );
    } catch (e) {
      emit(FetchMyPropertiesFailure(e));
    }
  }

  void updateStatus(int propertyId, String currentType) {
    try {
      if (state is FetchMyPropertiesSuccess) {
        final propertyList = (state as FetchMyPropertiesSuccess).myProperty;
        final index = propertyList.indexWhere((element) {
          return element.id == propertyId;
        });

        if (currentType.toLowerCase() == 'sell') {
          propertyList[index].properyType = 'sell';
        }
        if (currentType.toLowerCase() == 'rent') {
          propertyList[index].properyType = 'rent';
        }

        if (currentType.toLowerCase() == 'sold') {
          propertyList[index].properyType = 'sold';
        }
        if (currentType.toLowerCase() == 'rented') {
          propertyList[index].properyType = 'rented';
        }

        emit(
          (state as FetchMyPropertiesSuccess)
              .copyWith(myProperty: propertyList),
        );
      }
    } catch (e) {
      log('Error is $e');
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMyPropertiesSuccess) {
      final properties = (state as FetchMyPropertiesSuccess).myProperty;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMyPropertiesSuccess).copyWith(myProperty: properties),
      );
    }
  }

  Future<void> fetchMoreProperties({
    required String type,
    required String status,
  }) async {
    try {
      if (state is FetchMyPropertiesSuccess) {
        if ((state as FetchMyPropertiesSuccess).isLoadingMore) {
          return;
        }

        final currentState = state as FetchMyPropertiesSuccess;
        emit(currentState.copyWith(isLoadingMore: true));

        final result = await _propertyRepository.fetchMyProperties(
          offset: currentState.myProperty.length,
          type: type,
          status: status,
        );

        final updatedProperties = [
          ...currentState.myProperty,
          ...result.modelList
        ];

        emit(
          FetchMyPropertiesSuccess(
            isLoadingMore: false,
            hasError: false,
            myProperty: updatedProperties,
            offset: updatedProperties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      if (state is FetchMyPropertiesSuccess) {
        emit(
          (state as FetchMyPropertiesSuccess).copyWith(
            isLoadingMore: false,
            hasMoreData: true, // Fixed from hasMoreData to hasError
          ),
        );
      }
    }
  }

  void addLocal(PropertyModel model) {
    try {
      if (state is FetchMyPropertiesSuccess) {
        final myProperty = (state as FetchMyPropertiesSuccess).myProperty;
        if (myProperty.isNotEmpty) {
          myProperty.insert(0, model);
        } else {
          myProperty.add(model);
        }

        emit(
          (state as FetchMyPropertiesSuccess).copyWith(myProperty: myProperty),
        );
      }
    } catch (e, st) {
      log('Error is $e state is $st');
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPropertiesSuccess) {
      return (state as FetchMyPropertiesSuccess).myProperty.length <
          (state as FetchMyPropertiesSuccess).total;
    }
    return false;
  }

  bool isLoadingMore() {
    if (state is FetchMyPropertiesSuccess) {
      return (state as FetchMyPropertiesSuccess).isLoadingMore;
    }
    return false;
  }
}
