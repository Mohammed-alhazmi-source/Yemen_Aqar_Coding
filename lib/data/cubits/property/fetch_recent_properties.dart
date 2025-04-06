import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchRecentPropertiesState {}

class FetchRecentProepertiesInitial extends FetchRecentPropertiesState {}

class FetchRecentPropertiesInProgress extends FetchRecentPropertiesState {}

class FetchRecentPropertiesSuccess extends FetchRecentPropertiesState
    implements PropertySuccessStateWireframe {
  FetchRecentPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.properties,
  });

  final int total;
  final int offset;
  @override
  final bool isLoadingMore;
  final bool hasError;
  @override
  final List<PropertyModel> properties;

  FetchRecentPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    List<PropertyModel>? properties,
  }) {
    return FetchRecentPropertiesSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      properties: properties ?? this.properties,
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

class FetchRecentPropertiesFailur extends FetchRecentPropertiesState
    implements PropertyErrorStateWireframe {
  FetchRecentPropertiesFailur(this.error);
  @override
  final dynamic error;

  @override
  set error(error) {}
}

class FetchRecentPropertiesCubit extends Cubit<FetchRecentPropertiesState>
    implements PropertyCubitWireframe {
  FetchRecentPropertiesCubit() : super(FetchRecentProepertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchRecentPropertiesSuccess) {
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
          emit(FetchRecentPropertiesInProgress());
        }
      } else {
        emit(FetchRecentPropertiesInProgress());
      }

      if (forceRefresh == true) {
        final result = await _propertyRepository.fetchRecentProperties(
          offset: 0,
        );
        // log("API RESULT IS $result");
        emit(
          FetchRecentPropertiesSuccess(
            total: result.total,
            offset: 0,
            isLoadingMore: false,
            hasError: false,
            properties: result.modelList,
          ),
        );
      } else {
        if (state is! FetchRecentPropertiesSuccess) {
          final result = await _propertyRepository.fetchRecentProperties(
            offset: 0,
          );
          emit(
            FetchRecentPropertiesSuccess(
              total: result.total,
              offset: 0,
              isLoadingMore: false,
              hasError: false,
              properties: result.modelList,
            ),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              final result = await _propertyRepository.fetchRecentProperties(
                offset: 0,
              );
              emit(
                FetchRecentPropertiesSuccess(
                  total: result.total,
                  offset: 0,
                  isLoadingMore: false,
                  hasError: false,
                  properties: result.modelList,
                ),
              );
            },
            onNoInternet: () {
              emit(
                FetchRecentPropertiesSuccess(
                  total: (state as FetchRecentPropertiesSuccess).total,
                  offset: (state as FetchRecentPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchRecentPropertiesSuccess).isLoadingMore,
                  hasError: (state as FetchRecentPropertiesSuccess).hasError,
                  properties:
                      (state as FetchRecentPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      emit(FetchRecentPropertiesFailur(e.toString()));
    }
  }

  @override
  Future<void> fetchMore() async {
    if (state is FetchRecentPropertiesSuccess) {
      final mystate = state as FetchRecentPropertiesSuccess;
      if (mystate.isLoadingMore) {
        return;
      }
      emit(
        (state as FetchRecentPropertiesSuccess).copyWith(isLoadingMore: true),
      );
      final result = await _propertyRepository.fetchRecentProperties(
        offset: (state as FetchRecentPropertiesSuccess).properties.length,
      );
      final propertymodelState = state as FetchRecentPropertiesSuccess;
      propertymodelState.properties.addAll(result.modelList);
      emit(
        FetchRecentPropertiesSuccess(
          isLoadingMore: false,
          hasError: false,
          properties: propertymodelState.properties,
          offset: (state as FetchRecentPropertiesSuccess).properties.length,
          total: result.total,
        ),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchRecentPropertiesSuccess) {
      return (state as FetchRecentPropertiesSuccess).properties.length <
          (state as FetchRecentPropertiesSuccess).total;
    }
    return false;
  }
}
