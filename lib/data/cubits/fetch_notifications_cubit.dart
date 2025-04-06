import 'package:ebroker/data/model/notification_data.dart';
import 'package:ebroker/data/repositories/notifications_repository_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchNotificationsState {}

class FetchNotificationsInitial extends FetchNotificationsState {}

class FetchNotificationsInProgress extends FetchNotificationsState {}

class FetchNotificationsSuccess extends FetchNotificationsState {
  FetchNotificationsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.notificationdata,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<NotificationData> notificationdata;
  final int offset;
  final int total;

  FetchNotificationsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<NotificationData>? notificationdata,
    int? offset,
    int? total,
  }) {
    return FetchNotificationsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      notificationdata: notificationdata ?? List.from(this.notificationdata),
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchNotificationsFailure extends FetchNotificationsState {
  FetchNotificationsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchNotificationsCubit extends Cubit<FetchNotificationsState> {
  FetchNotificationsCubit() : super(FetchNotificationsInitial());

  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  Future<void> fetchNotifications() async {
    try {
      emit(FetchNotificationsInProgress());

      final result = await _notificationsRepository.fetchNotifications(
        offset: 0,
      );

      emit(
        FetchNotificationsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          notificationdata: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchNotificationsFailure(e));
    }
  }

  Future<void> fetchNotificationsMore() async {
    if (state is! FetchNotificationsSuccess) return;

    final currentState = state as FetchNotificationsSuccess;

    if (currentState.isLoadingMore) return;
    if (!hasMoreData()) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await _notificationsRepository.fetchNotifications(
        offset: currentState.notificationdata.length,
      );

      final updatedList =
          List<NotificationData>.from(currentState.notificationdata)
            ..addAll(result.modelList);

      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadingMoreError: false,
          notificationdata: updatedList,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchNotificationsSuccess) {
      final currentState = state as FetchNotificationsSuccess;
      return currentState.notificationdata.length < currentState.total;
    }
    return false;
  }
}
