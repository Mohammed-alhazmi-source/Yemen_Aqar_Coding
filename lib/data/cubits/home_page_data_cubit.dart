import 'package:ebroker/data/model/home_page_data_model.dart';
import 'package:ebroker/data/repositories/home_screen_data_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchHomePageDataState {}

class FetchHomePageDataInitial extends FetchHomePageDataState {}

class FetchHomePageDataLoading extends FetchHomePageDataState {}

class FetchHomePageDataSuccess extends FetchHomePageDataState {
  FetchHomePageDataSuccess({
    required this.homePageDataModel,
  });

  final HomePageDataModel homePageDataModel;

  FetchHomePageDataSuccess copyWith() {
    HomePageDataModel? homePageDataModel;
    return FetchHomePageDataSuccess(
      homePageDataModel: homePageDataModel ?? this.homePageDataModel,
    );
  }
}

class FetchHomePageDataFailure extends FetchHomePageDataState {
  FetchHomePageDataFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchHomePageDataCubit extends Cubit<FetchHomePageDataState> {
  FetchHomePageDataCubit() : super(FetchHomePageDataInitial());
  final HomeScreenDataRepository _homeScreenDataRepository =
      HomeScreenDataRepository();

  Future<void> fetch({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchHomePageDataLoading());
      final (homepageDataModel: homePageDataModel) =
          await _homeScreenDataRepository.fetchAllHomePageData();
      emit(
        FetchHomePageDataSuccess(
          homePageDataModel: homePageDataModel,
        ),
      );
    } catch (e) {
      emit(FetchHomePageDataFailure(e));
    }
  }

  bool isHomePageDataEmpty() {
    if (state is FetchHomePageDataSuccess) {
      return (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .featuredSection
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .mostLikedProperties
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .mostViewedProperties
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .projectSection
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .sliderSection
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .categoriesSection
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .articleSection
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .agentsList
              .isEmpty;
    }
    return true;
  }
}
