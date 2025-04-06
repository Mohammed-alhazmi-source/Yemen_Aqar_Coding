import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

abstract class HomePageInfinityScrollState {}

class HomePageInfinityScrollInitial extends HomePageInfinityScrollState {}

class HomePageInfinityScrollInProgress extends HomePageInfinityScrollState {}

class HomePageInfinityScrollSuccess extends HomePageInfinityScrollState {
  HomePageInfinityScrollSuccess({
    required this.offset,
    required this.total,
    required this.properties,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<PropertyModel> properties;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  HomePageInfinityScrollSuccess copyWith({
    int? offset,
    int? total,
    List<PropertyModel>? propertyModel,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return HomePageInfinityScrollSuccess(
      offset: offset ?? this.offset,
      total: total ?? this.total,
      properties: propertyModel ?? properties,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class HomePageInfinityScrollFailure extends HomePageInfinityScrollState {
  HomePageInfinityScrollFailure(this.error);

  final dynamic error;
}

class HomePageInfinityScrollCubit extends Cubit<HomePageInfinityScrollState> {
  HomePageInfinityScrollCubit() : super(HomePageInfinityScrollInitial()) {
    injector(
      (conditions) {
        conditions
            .setAfter(7)
            .setInjectSetting(perLength: 10, count: 10)
            .setMinListCount(7);
      },
    );
  }

  final NativeAdInjector injector = NativeAdInjector();
  PropertyRepository propertyRepository = PropertyRepository();

  Future<void> fetch() async {
    try {
      emit(HomePageInfinityScrollInProgress());
      final dataOutput = await propertyRepository.fetchAllProperties(
        offset: 0,
      );
      // injector.wrapper(injectableList: properties);
      emit(
        HomePageInfinityScrollSuccess(
          offset: 0,
          total: dataOutput.total,
          properties: dataOutput.modelList,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } catch (e) {
      emit(HomePageInfinityScrollFailure(e));
    }
  }

  bool isLoadingMore() {
    if (state is HomePageInfinityScrollSuccess) {
      return (state as HomePageInfinityScrollSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is HomePageInfinityScrollSuccess) {
      return (state as HomePageInfinityScrollSuccess)
              .properties
              .whereType<PropertyModel>()
              .length <
          (state as HomePageInfinityScrollSuccess).total;
    }
    return false;
  }

  Future<void> fetchMore() async {
    if (state is HomePageInfinityScrollSuccess) {
      try {
        final scrollSuccess = state as HomePageInfinityScrollSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as HomePageInfinityScrollSuccess)
              .copyWith(isLoadingMore: true),
        );

        final dataOutput = await propertyRepository.fetchAllProperties(
          offset: (state as HomePageInfinityScrollSuccess)
              .properties
              .whereType<PropertyModel>()
              .length,
        );

        final currentState = state as HomePageInfinityScrollSuccess;

        currentState.properties.addAll(dataOutput.modelList);
        emit(
          HomePageInfinityScrollSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            properties: currentState.properties,
            offset: (state as HomePageInfinityScrollSuccess)
                .properties
                .whereType<PropertyModel>()
                .length,
            total: dataOutput.total,
          ),
        );
      } catch (e) {
        emit(
          (state as HomePageInfinityScrollSuccess)
              .copyWith(hasLoadMoreError: true),
        );
      }
    }
  }
}
