import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationState { initial, authenticated, unAuthenticated, firstTime }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.initial) {
    _checkIfAuthenticated();
  }

  void _checkIfAuthenticated() {
    final userAuthenticated = HiveUtils.isUserAuthenticated();

    if (userAuthenticated) {
      emit(AuthenticationState.authenticated);
    } else {
      //When user installs app for first time then this firstTime state will be emmited.
      if (HiveUtils.isUserFirstTime()) {
        emit(AuthenticationState.firstTime);
      } else {
        emit(AuthenticationState.unAuthenticated);
      }
    }
  }

  bool isAuthenticated() {
    return (state == AuthenticationState.authenticated);
  }

  void setUnAuthenticated() {
    emit(AuthenticationState.unAuthenticated);
  }
}
