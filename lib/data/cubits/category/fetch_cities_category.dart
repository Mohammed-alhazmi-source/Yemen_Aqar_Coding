// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/repositories/cities_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/Extensions/lib/list.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchCityCategoryState {}

class FetchCityCategoryInitial extends FetchCityCategoryState {}

class FetchCityCategoryInProgress extends FetchCityCategoryState {}

class FetchCityCategorySuccess extends FetchCityCategoryState {
  final List<City> cities;
  final int total;
  final bool isLoadingMore;
  final bool hasLoadMoreError;
  final int offset;
  FetchCityCategorySuccess({
    required this.cities,
    required this.total,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
    required this.offset,
  });

  FetchCityCategorySuccess copyWith({
    List<City>? cities,
    int? offset,
    int? total,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchCityCategorySuccess(
      offset: offset ?? this.offset,
      cities: cities ?? this.cities,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchCityCategoryFail extends FetchCityCategoryState {
  final dynamic error;

  FetchCityCategoryFail(this.error);

  @override
  String toString() => 'FetchCityCategoryFail(error: $error)';
}

class FetchCityCategoryCubit extends Cubit<FetchCityCategoryState> {
  FetchCityCategoryCubit() : super(FetchCityCategoryInitial());
  final CitiesRepository _citiesRepository = CitiesRepository();
  Future<void> fetchCityCategory({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      final result = await _citiesRepository.fetchAllCities(offset: 0);
      final cities = List<City>.from(result.modelList);
      if (forceRefresh != true) {
        if (state is FetchCityCategorySuccess) {
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
          emit(FetchCityCategoryInProgress());
        }
      } else {
        emit(FetchCityCategoryInProgress());
      }

      if (forceRefresh == true) {
        emit(
          FetchCityCategorySuccess(
            offset: 0,
            hasLoadMoreError: false,
            isLoadingMore: false,
            cities: cities,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchCityCategorySuccess) {
          emit(
            FetchCityCategorySuccess(
              offset: 0,
              hasLoadMoreError: false,
              isLoadingMore: false,
              cities: cities,
              total: result.total,
            ),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              emit(
                FetchCityCategorySuccess(
                  offset: 0,
                  hasLoadMoreError: false,
                  isLoadingMore: false,
                  cities: cities,
                  total: result.total,
                ),
              );
            },
            onNoInternet: () {
              emit(
                FetchCityCategorySuccess(
                  offset: 0,
                  hasLoadMoreError: false,
                  isLoadingMore: false,
                  cities: (state as FetchCityCategorySuccess).cities,
                  total: (state as FetchCityCategorySuccess).total,
                ),
              );
            },
          );
        }
      }
    } catch (error, st) {
      log('Error is $error state is $st');
    }
  }

  Future<void> fetchMore() async {
    if (state is FetchCityCategorySuccess) {
      try {
        final scrollSuccess = state as FetchCityCategorySuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchCityCategorySuccess).copyWith(isLoadingMore: true),
        );
        final dataOutput = await _citiesRepository.fetchAllCities(
          offset: (state as FetchCityCategorySuccess).cities.length,
        );
        final currentState = state as FetchCityCategorySuccess;
        final updatedCities = currentState.cities..addAll(dataOutput.modelList);
        emit(
          FetchCityCategorySuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            cities: updatedCities,
            offset: updatedCities.length,
            total: dataOutput.total,
          ),
        );
      } catch (e) {
        emit(
          (state as FetchCityCategorySuccess).copyWith(hasLoadMoreError: true),
        );
      }
    }
  }

  bool isLoadingMore() {
    if (state is FetchCityCategorySuccess) {
      return (state as FetchCityCategorySuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchCityCategorySuccess) {
      return (state as FetchCityCategorySuccess)
              .cities
              .whereType<City>()
              .length <
          (state as FetchCityCategorySuccess).total;
    }
    return false;
  }

  bool isCitiesEmpty() {
    if (state is FetchCityCategorySuccess) {
      return (state as FetchCityCategorySuccess).cities.isEmpty &&
          (state as FetchCityCategorySuccess).isLoadingMore == false;
    }
    return true;
  }

  dynamic getCount() {
    if (state is FetchCityCategorySuccess) {
      return (state as FetchCityCategorySuccess).cities.sum((e) => e.count);
    } else {
      return '--';
    }
  }
}
