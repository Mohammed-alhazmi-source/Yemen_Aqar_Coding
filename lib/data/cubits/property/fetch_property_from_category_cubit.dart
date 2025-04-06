import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPropertyFromCategoryState {}

class FetchPropertyFromCategoryInitial extends FetchPropertyFromCategoryState {}

class FetchPropertyFromCategoryInProgress
    extends FetchPropertyFromCategoryState {}

class FetchPropertyFromCategorySuccess extends FetchPropertyFromCategoryState {
  FetchPropertyFromCategorySuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.propertymodel,
    required this.offset,
    required this.total,
    this.categoryId,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<dynamic> propertymodel;
  final int offset;
  final int total;
  final int? categoryId;

  FetchPropertyFromCategorySuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<dynamic>? propertymodel,
    int? offset,
    int? total,
    int? categoryId,
  }) {
    return FetchPropertyFromCategorySuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      propertymodel: propertymodel ?? this.propertymodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class FetchPropertyFromCategoryFailure extends FetchPropertyFromCategoryState {
  FetchPropertyFromCategoryFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchPropertyFromCategoryCubit
    extends Cubit<FetchPropertyFromCategoryState> {
  FetchPropertyFromCategoryCubit() : super(FetchPropertyFromCategoryInitial()) {
    injector(
      (conditions) {
        conditions
            .setAfter(7)
            .setInjectSetting(perLength: 10, count: 5)
            .setMinListCount(7);
      },
    );
  }
  NativeAdInjector injector = NativeAdInjector();

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchPropertyFromCategory(
    int categoryId, {
    FilterApply? filter,
    bool? showPropertyType,
  }) async {
    try {
      emit(FetchPropertyFromCategoryInProgress());

      final result = await _propertyRepository.fetchPropertyFromCategoryId(
        id: categoryId,
        offset: 0,
        showPropertyType: showPropertyType,
        filter: filter,
      );
      final properties = List<NativeAdWidgetContainer>.from(result.modelList);
      injector.wrapper(injectableList: properties);
      emit(
        FetchPropertyFromCategorySuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          propertymodel: properties,
          offset: 0,
          total: result.total,
          categoryId: categoryId,
        ),
      );
    } catch (e) {
      emit(
        FetchPropertyFromCategoryFailure(
          e,
        ),
      );
    }
  }

  Future<void> fetchPropertyFromCategoryMore({
    bool? showPropertyType,
  }) async {
    try {
      if (state is FetchPropertyFromCategorySuccess) {
        if ((state as FetchPropertyFromCategorySuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchPropertyFromCategorySuccess)
              .copyWith(isLoadingMore: true),
        );

        final result = await _propertyRepository.fetchPropertyFromCategoryId(
          id: (state as FetchPropertyFromCategorySuccess).categoryId!,
          showPropertyType: showPropertyType,
          offset: (state as FetchPropertyFromCategorySuccess)
              .propertymodel
              .whereType<PropertyModel>()
              .length,
        );

        final property = state as FetchPropertyFromCategorySuccess;

        property.propertymodel.addAll(result.modelList);

        emit(
          FetchPropertyFromCategorySuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            propertymodel: property.propertymodel,
            offset: (state as FetchPropertyFromCategorySuccess)
                .propertymodel
                .whereType<PropertyModel>()
                .length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchPropertyFromCategorySuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchPropertyFromCategorySuccess) {
      return (state as FetchPropertyFromCategorySuccess)
              .propertymodel
              .whereType<PropertyModel>()
              .length <
          (state as FetchPropertyFromCategorySuccess).total;
    }
    return false;
  }
}
