// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final dynamic credential;
  final String? authId;
  final String? number;
  final String? otp;
  VerifyOtpSuccess({
    this.authId,
    this.number,
    this.otp,
    this.credential,
  });
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;

  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOTP({
    required String otp,
    String? verificationId,
    String? number,
  }) async {
    try {
      if (AppSettings.otpServiceProvider == 'firebase') {
        emit(VerifyOtpInProgress());
        final userCredential = await _authRepository.verifyFirebaseOTP(
          otpVerificationId: verificationId!,
          otp: otp,
        );
        emit(VerifyOtpSuccess(credential: userCredential));
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        emit(VerifyOtpInProgress());
        final credential = await _authRepository.verifyTwilioOTP(
          number: number!,
          otp: otp,
        );
        final authId = credential['auth_id'];
        emit(
          VerifyOtpSuccess(authId: authId, number: number),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error));
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  Future<void> verifyEmailOTP({
    required String otp,
    required String email,
  }) async {
    try {
      emit(VerifyOtpInProgress());
      final credential = await _authRepository.verifyEmailOTP(
        otp: otp,
        email: email,
      );
      if (credential['error'] == true) {
        emit(VerifyOtpFailure(credential['message']));
        return;
      }
      emit(VerifyOtpSuccess(credential: credential['data']));
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error));
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  void setInitialState() {
    emit(VerifyOtpInitial());
  }
}
