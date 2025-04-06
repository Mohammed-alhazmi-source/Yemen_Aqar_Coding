import 'package:firebase_auth/firebase_auth.dart';

abstract class MLoginState {}

class MProgress extends MLoginState {}

class MVerificationPending extends MLoginState {
  // final String target;

  MVerificationPending();
}

class MSuccess extends MLoginState {
  MSuccess(this.credentials, {required this.type});
  final String type;
  final UserCredential credentials;
}

class MFail extends MLoginState {
  MFail(this.error);
  final dynamic error;
}
