import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/favourites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchFavoritesState {}

class FetchFavoritesInitial extends FetchFavoritesState {}

class FetchFavoritesInProgress extends FetchFavoritesState {}

class FetchFavoritesSuccess extends FetchFavoritesState {
  FetchFavoritesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.propertymodel,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<PropertyModel> propertymodel;
  final int offset;
  final int total;

  FetchFavoritesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchFavoritesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      propertymodel: propertymodel ?? this.propertymodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchFavoritesFailure extends FetchFavoritesState {
  FetchFavoritesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchFavoritesCubit extends Cubit<FetchFavoritesState> {
  FetchFavoritesCubit() : super(FetchFavoritesInitial());

  final FavoriteRepository _favoritesRepository = FavoriteRepository();

  Future<void> fetchFavorites() async {
    try {
      emit(FetchFavoritesInProgress());

      final result = await _favoritesRepository.fechFavorites(
        offset: 0,
      );

      emit(
        FetchFavoritesSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          propertymodel: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } catch (error) {
      emit(FetchFavoritesFailure(error));
    }
  }

  void remove(id) {
    if (state is FetchFavoritesSuccess) {
      final propertymodel = (state as FetchFavoritesSuccess).propertymodel
        ..removeWhere((element) => element.id == id);

      emit(
        (state as FetchFavoritesSuccess).copyWith(propertymodel: propertymodel),
      );
    }
  }

  void add(PropertyModel model) {
    if (state is FetchFavoritesSuccess) {
      final propertymodel = (state as FetchFavoritesSuccess).propertymodel
        ..insert(0, model);
      // propertymodel.removeWhere((element) => element.id == id);

      emit(
        (state as FetchFavoritesSuccess).copyWith(propertymodel: propertymodel),
      );
    }
  }

  Future<void> fetchFavoritesMore() async {
    try {
      if (state is FetchFavoritesSuccess) {
        if ((state as FetchFavoritesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchFavoritesSuccess).copyWith(isLoadingMore: true));
        final result = await _favoritesRepository.fechFavorites(
          offset: (state as FetchFavoritesSuccess).propertymodel.length,
        );

        final propertymodelState = state as FetchFavoritesSuccess;
        propertymodelState.propertymodel.addAll(result.modelList);
        emit(
          FetchFavoritesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            propertymodel: propertymodelState.propertymodel,
            offset: (state as FetchFavoritesSuccess).propertymodel.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchFavoritesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchFavoritesSuccess) {
      return (state as FetchFavoritesSuccess).propertymodel.length <
          (state as FetchFavoritesSuccess).total;
    }
    return false;
  }
}
