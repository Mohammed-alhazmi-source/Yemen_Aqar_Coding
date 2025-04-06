import 'package:ebroker/data/model/interested_user_model.dart';
import 'package:ebroker/data/repositories/interest_repository.dart';

import 'package:ebroker/exports/main_export.dart';

class GetInterestedUserState {}

class GetInterestedUserInitial extends GetInterestedUserState {}

class GetInterestedUserInProgress extends GetInterestedUserState {}

class GetInterestedUserSuccess extends GetInterestedUserState {
  GetInterestedUserSuccess({
    required this.list,
    required this.total,
    required this.propertyId,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
  });
  final List<InterestedUserModel> list;
  final int total;
  final int offset;
  final bool isLoadingMore;
  final String propertyId;
  final bool hasError;

  GetInterestedUserSuccess copyWith({
    List<InterestedUserModel>? list,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    String? propertyId,
  }) {
    return GetInterestedUserSuccess(
      list: list ?? this.list,
      propertyId: propertyId ?? this.propertyId,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
    );
  }
}

class GetInterestedUserFail extends GetInterestedUserState {
  GetInterestedUserFail(this.error);
  final dynamic error;
}

class GetInterestedUserCubit extends Cubit<GetInterestedUserState> {
  GetInterestedUserCubit() : super(GetInterestedUserInitial());
  final InterestRepository _interestRepository = InterestRepository();
  Future<void> fetch(
    String propertyId,
  ) async {
    try {
      emit(GetInterestedUserInProgress());
      final result = await _interestRepository.getInterestUser(
        propertyId,
        offset: 0,
      );

      emit(
        GetInterestedUserSuccess(
          hasError: false,
          offset: 0,
          total: result.total,
          propertyId: propertyId,
          isLoadingMore: false,
          list: result.modelList,
        ),
      );
    } catch (e) {
      emit(GetInterestedUserFail(e));
    }
  }

  Future<void> fetchMore() async {
    try {
      if (state is GetInterestedUserSuccess) {
        if ((state as GetInterestedUserSuccess).isLoadingMore) {
          return;
        }
        emit((state as GetInterestedUserSuccess).copyWith(isLoadingMore: true));
        final result = await _interestRepository.getInterestUser(
          (state as GetInterestedUserSuccess).propertyId,
          offset: (state as GetInterestedUserSuccess).list.length,
        );

        final interestedUserList = state as GetInterestedUserSuccess;
        interestedUserList.list.addAll(result.modelList);
        emit(
          GetInterestedUserSuccess(
            isLoadingMore: false,
            propertyId: (state as GetInterestedUserSuccess).propertyId,
            hasError: false,
            list: interestedUserList.list,
            offset: (state as GetInterestedUserSuccess).list.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as GetInterestedUserSuccess)
            .copyWith(isLoadingMore: false, hasError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is GetInterestedUserSuccess) {
      return (state as GetInterestedUserSuccess).list.length <
          (state as GetInterestedUserSuccess).total;
    }
    return false;
  }
}
