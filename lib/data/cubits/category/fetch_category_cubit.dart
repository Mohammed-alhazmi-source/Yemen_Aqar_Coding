// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/repositories/category_repository.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchCategoryState {}

class FetchCategoryInitial extends FetchCategoryState {}

class FetchCategoryInProgress extends FetchCategoryState {}

class FetchCategorySuccess extends FetchCategoryState {
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<Category> categories;

  FetchCategorySuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchCategorySuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    List<Category>? categories,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'offset': offset,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'FetchCategorySuccess(total: $total, offset: $offset, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchCategoryFailure extends FetchCategoryState {
  final String errorMessage;

  FetchCategoryFailure(this.errorMessage);
}

class FetchCategoryCubit extends Cubit<FetchCategoryState> {
  FetchCategoryCubit() : super(FetchCategoryInitial());

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchCategories({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      await CacheData().getData<FetchCategorySuccess>(
        forceRefresh: forceRefresh == true,
        delay: loadWithoutDelay == true ? 0 : null,
        onProgress: () {
          emit(FetchCategoryInProgress());
        },
        onNetworkRequest: () async {
          final categories = await _categoryRepository.fetchCategories(
            offset: 0,
          );

          final list =
              categories.modelList.map((element) => element.image!).toList();
          await HelperUtils.precacheSVG(list);

          return FetchCategorySuccess(
            total: categories.total,
            categories: categories.modelList,
            offset: 0,
            hasError: false,
            isLoadingMore: false,
          );
        },
        onOfflineData: () {
          return state as FetchCategorySuccess;
        },
        onSuccess: (data) {
          emit(data);
        },
        hasData: state is FetchCategorySuccess,
      );
    } catch (e) {
      emit(FetchCategoryFailure(e.toString()));
    }
  }

  Future<Category> get(int id) async {
    try {
      final dataOutput = await _categoryRepository.fetchCategories(
        offset: 0,
        id: id,
      );
      return dataOutput.modelList.first;
    } catch (e) {
      rethrow;
    }
  }

  List<Category> getCategories() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories;
    }

    return <Category>[];
  }

  Future<void> fetchCategoriesMore() async {
    try {
      if (state is FetchCategorySuccess) {
        if ((state as FetchCategorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCategorySuccess).copyWith(isLoadingMore: true));
        final result = await _categoryRepository.fetchCategories(
          offset: (state as FetchCategorySuccess).categories.length,
        );

        final categoryState = state as FetchCategorySuccess;
        categoryState.categories.addAll(result.modelList);

        final list = categoryState.categories.map((e) => e.image!).toList();
        await HelperUtils.precacheSVG(list);

        emit(
          FetchCategorySuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            offset: (state as FetchCategorySuccess).categories.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchCategorySuccess)
            .copyWith(isLoadingMore: false, hasError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories.length <
          (state as FetchCategorySuccess).total;
    }
    return false;
  }
}
