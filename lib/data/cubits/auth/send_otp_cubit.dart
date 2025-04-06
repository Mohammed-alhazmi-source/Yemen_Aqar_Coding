// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/auth_repository.dart';

import 'package:ebroker/exports/main_export.dart';

String verificationID = '';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  String? verificationId;
  String? message;
  SendOtpSuccess({
    this.verificationId,
    this.message,
  });
}

class SendOtpFailure extends SendOtpState {
  final String errorMessage;

  SendOtpFailure(this.errorMessage);
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();
  Future<void> sendFirebaseOTP({required String phoneNumber}) async {
    emit(SendOtpInProgress());
    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    );
  }

  Future<void> sendTwilioOTP({required String phoneNumber}) async {
    emit(SendOtpInProgress());

    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    );
  }

  Future<void> sendForgotPasswordEmail({
    required String email,
  }) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendForgotPasswordEmail(
        email: email,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']));
      } else {
        emit(SendOtpSuccess(message: result['message']));
      }
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> sendEmailOTP(
      {required String email,
      required String name,
      required String phoneNumber,
      required String password,
      required String confirmPassword}) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendEmailOTP(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );
      print(result);
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']));
      } else {
        emit(SendOtpSuccess());
      }
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> resendEmailOTP({
    required String email,
    required String password,
  }) async {
    try {
      emit(SendOtpInProgress());
      final result = await _authRepository.resendEmailOTP(
        email: email,
        password: password,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']));
      } else {
        emit(SendOtpSuccess());
      }
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  void setToInitial() {
    emit(SendOtpInitial());
  }
}
