import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/personalized_feed_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/network/networkAvailability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertyInitial
    extends FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertyInProgress
    extends FetchPersonalizedPropertyListState {}

class FetchPersonalizedPropertySuccess
    extends FetchPersonalizedPropertyListState
    implements PropertySuccessStateWireframe {
  FetchPersonalizedPropertySuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });

  factory FetchPersonalizedPropertySuccess.fromMap(Map<String, dynamic> map) {
    return FetchPersonalizedPropertySuccess(
      isLoadingMore: map['isLoadingMore'] as bool,
      loadingMoreError: map['loadingMoreError'] as bool,
      properties: (map['properties'] as List)
          .cast<Map<String, dynamic>>()
          .map(PropertyModel.fromMap)
          .toList(),
      offset: map['offset'] as int,
      total: map['total'] as int,
    );
  }
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;

  @override
  set isLoadingMore(bool isLoadingMore) {}

  @override
  set properties(List<PropertyModel> properties) {}

  FetchPersonalizedPropertySuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
    String? cityName,
  }) {
    return FetchPersonalizedPropertySuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isLoadingMore': isLoadingMore,
      'loadingMoreError': loadingMoreError,
      'properties': properties.map((e) => e.toMap()).toList(),
      'offset': offset,
      'total': total,
    };
  }
}

class FetchPersonalizedPropertyFail extends FetchPersonalizedPropertyListState
    implements PropertyErrorStateWireframe {
  FetchPersonalizedPropertyFail(this.error);
  @override
  final dynamic error;

  @override
  set error(error) {}
}

class FetchPersonalizedPropertyList
    extends Cubit<FetchPersonalizedPropertyListState>
    implements PropertyCubitWireframe {
  FetchPersonalizedPropertyList() : super(FetchPersonalizedPropertyInitial());
  final PersonalizedFeedRepository _personalizedFeedRepository =
      PersonalizedFeedRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    if (forceRefresh != true) {
      if (state is FetchPersonalizedPropertySuccess) {
        await Future.delayed(
          Duration(
            seconds: loadWithoutDelay == true
                ? 0
                : AppSettings.hiddenAPIProcessDelay,
          ),
        );
      } else {
        emit(FetchPersonalizedPropertyInProgress());
      }
    } else {
      emit(FetchPersonalizedPropertyInProgress());
    }
    try {
      if (forceRefresh == true) {
        final result = await _personalizedFeedRepository
            .getPersonalizedProeprties(offset: 0);

        emit(
          FetchPersonalizedPropertySuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchPersonalizedPropertySuccess) {
          final result = await _personalizedFeedRepository
              .getPersonalizedProeprties(offset: 0);

          emit(
            FetchPersonalizedPropertySuccess(
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
              final result =
                  await _personalizedFeedRepository.getPersonalizedProeprties(
                offset: 0,
              );

              emit(
                FetchPersonalizedPropertySuccess(
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
                FetchPersonalizedPropertySuccess(
                  total: (state as FetchPersonalizedPropertySuccess).total,
                  offset: (state as FetchPersonalizedPropertySuccess).offset,
                  isLoadingMore:
                      (state as FetchPersonalizedPropertySuccess).isLoadingMore,
                  loadingMoreError: (state as FetchPersonalizedPropertySuccess)
                      .loadingMoreError,
                  properties:
                      (state as FetchPersonalizedPropertySuccess).properties,
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchPersonalizedPropertyFail(e as dynamic));
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchPersonalizedPropertySuccess) {
        if ((state as FetchPersonalizedPropertySuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchPersonalizedPropertySuccess)
              .copyWith(isLoadingMore: true),
        );
        final result =
            await _personalizedFeedRepository.getPersonalizedProeprties(
          offset: (state as FetchPersonalizedPropertySuccess).properties.length,
        );

        final propertiesState = state as FetchPersonalizedPropertySuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchPersonalizedPropertySuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchPersonalizedPropertySuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchPersonalizedPropertySuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchPersonalizedPropertySuccess) {
      return (state as FetchPersonalizedPropertySuccess).properties.length <
          (state as FetchPersonalizedPropertySuccess).total;
    }
    return false;
  }
}
