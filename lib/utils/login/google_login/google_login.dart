import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:ebroker/utils/login/lib/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;

  @override
  Future<void> init() async {
    _googleSignIn = GoogleSignIn(
      scopes: ['profile', 'email'],
    );
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      await _googleSignIn?.signOut(); // لتسجيل الخروج من الحساب الحالي
      final googleSignIn = await _googleSignIn?.signIn();

      if (googleSignIn == null) {
        throw ErrorDescription('google-terminated');
      }
      final googleAuth = await googleSignIn.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );    

      final userCredential = await firebaseAuth.signInWithCredential(authCredential);
      userCredential.user != null ? emit(MSuccess(userCredential, type: 'google')) : emit(MFail("حدث خطأ أثناء تسجيل الدخول"));
      return userCredential;

    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        emit(MFail('noInternet'.translate(context!)));
      }
    } on FirebaseAuthException catch (e) {
      emit(MFail(ErrorFilter.check(e.code)));
    } catch (e) {
      emit(MFail('googleLoginFailed'.translate(context!)));
    }
    return null;
  }

  @override
  void onEvent(MLoginState state) {
    // TODO(R): implement onEvent
  }
}
