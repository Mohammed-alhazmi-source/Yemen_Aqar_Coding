import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:ebroker/utils/login/lib/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;

  @override
  Future<void> init() async {}

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());

      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      oAuthProvider = OAuthProvider('apple.com');
      if (oAuthProvider != null) {
        credential = oAuthProvider!.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );

        final userCredential =
            await firebaseAuth.signInWithCredential(credential!);

        // Attempt to get the display name from Apple credential
        String? displayName = [
          appleIdCredential.givenName,
          appleIdCredential.familyName,
        ].where((name) => name != null && name.isNotEmpty).join(' ');

        // If display name is empty, use email or generate a fallback name
        if (displayName.isEmpty) {
          displayName = appleIdCredential.email ??
              'User${userCredential.user?.uid.substring(0, 5)}';
        }

        // Update the display name
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();

        emit(MSuccess(userCredential, type: 'apple'));
        return userCredential;
      } else {
        return null;
      }
    } catch (e) {
      emit(MFail('appleLoginFailed'.translate(context!)));
      rethrow;
    }
  }

  @override
  void onEvent(MLoginState state) {}
}
