import 'package:ebroker/data/model/faqs_model.dart';
import 'package:ebroker/data/repositories/faqs_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchFaqsState {}

class FetchFaqsInitial extends FetchFaqsState {}

class FetchFaqsInProgress extends FetchFaqsState {}

class FetchFaqsSuccess extends FetchFaqsState {
  FetchFaqsSuccess({
    required this.isLoadingMore,
    required this.hasLoadMoreError,
    required this.faqs,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool hasLoadMoreError;
  final List<FaqsModel> faqs;
  final int offset;
  final int total;
  FetchFaqsSuccess copyWith({
    bool? isLoadingMore,
    bool? hasLoadMoreError,
    List<FaqsModel>? faqs,
    int? offset,
    int? total,
  }) {
    return FetchFaqsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
      faqs: faqs ?? this.faqs,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchFaqsFailure extends FetchFaqsState {
  FetchFaqsFailure(this.errorMessage);
  final String errorMessage;
}

class FetchFaqsCubit extends Cubit<FetchFaqsState> {
  FetchFaqsCubit() : super(FetchFaqsInitial());

  final FaqsRepository _faqsRepository = FaqsRepository();

  Future<void> fetchFaqs({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchFaqsInProgress());

      final dataOutput = await _faqsRepository.fetchAllFaqs(offset: 0);
      final faqs = List<FaqsModel>.from(dataOutput.modelList);
      emit(
        FetchFaqsSuccess(
          isLoadingMore: false,
          hasLoadMoreError: false,
          faqs: faqs,
          offset: 0,
          total: dataOutput.total,
        ),
      );
    } catch (e) {
      emit(FetchFaqsFailure(e.toString()));
    }
  }

  Future<void> fetchMore() async {
    if (state is FetchFaqsSuccess) {
      try {
        final scrollSuccess = state as FetchFaqsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchFaqsSuccess).copyWith(isLoadingMore: true),
        );

        final dataOutput = await _faqsRepository.fetchAllFaqs(
          offset: (state as FetchFaqsSuccess).faqs.length,
        );
        final currentState = state as FetchFaqsSuccess;
        final updatedFaqs = currentState.faqs..addAll(dataOutput.modelList);

        emit(
          FetchFaqsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            faqs: updatedFaqs,
            offset: updatedFaqs.length,
            total: dataOutput.total,
          ),
        );
      } catch (e) {
        emit(
          (state as FetchFaqsSuccess).copyWith(hasLoadMoreError: true),
        );
      }
    }
  }

  bool isLoadingMore() {
    if (state is FetchFaqsSuccess) {
      return (state as FetchFaqsSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchFaqsSuccess) {
      return (state as FetchFaqsSuccess).faqs.length <
          (state as FetchFaqsSuccess).total;
    }
    return false;
  }

  bool isFaqsEmpty() {
    if (state is FetchFaqsSuccess) {
      return (state as FetchFaqsSuccess).faqs.isEmpty &&
          (state as FetchFaqsSuccess).isLoadingMore == false;
    }
    return true;
  }
}
