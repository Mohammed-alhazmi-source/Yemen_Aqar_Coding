import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInitial
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInProgress
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsSuccess
    extends GetSubscriptionPackageLimitsState {
  GetSubscriptionPackageLimitsSuccess({
    required this.error,
    required this.message,
    required this.hasSubscription,
  });
  final bool error;
  final String message;
  final bool hasSubscription;
}

class GetSubsctiptionPackageLimitsFailure
    extends GetSubscriptionPackageLimitsState {
  GetSubsctiptionPackageLimitsFailure(this.errorMessage);
  final String errorMessage;
}

class GetSubsctiptionPackageLimitsCubit
    extends Cubit<GetSubscriptionPackageLimitsState> {
  GetSubsctiptionPackageLimitsCubit()
      : super(GetSubscriptionPackageLimitsInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  Future<void> getLimits({required String type}) async {
    try {
      emit(GetSubscriptionPackageLimitsInProgress());
      final subscriptionPackageLimit =
          await _subscriptionRepository.getPackageLimit(
        limitType: type,
      );
      print(subscriptionPackageLimit);
      if (subscriptionPackageLimit['error'] == true) {
        emit(
          GetSubsctiptionPackageLimitsFailure(
            subscriptionPackageLimit['message'],
          ),
        );
      } else {
        emit(
          GetSubscriptionPackageLimitsSuccess(
            error: subscriptionPackageLimit['error'],
            message: subscriptionPackageLimit['message'],
            hasSubscription: subscriptionPackageLimit['subscription'],
          ),
        );
      }
    } catch (error) {
      emit(GetSubsctiptionPackageLimitsFailure(error.toString()));
    }
  }
}
