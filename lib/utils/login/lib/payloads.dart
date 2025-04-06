abstract class LoginPayload {}

class MultiLoginPayload {
  MultiLoginPayload(this.payloads);
  final Map<String, LoginPayload> payloads;
}

enum EmailLoginType { login, signup }

class EmailLoginPayload extends LoginPayload {
  EmailLoginPayload({
    required this.email,
    required this.password,
    required this.type,
  });
  final String email;
  final String password;
  final EmailLoginType type;
}

class GoogleLoginPayload extends LoginPayload {
  GoogleLoginPayload();
}

int? forceResendingtoken;

class PhoneLoginPayload extends LoginPayload {
  PhoneLoginPayload(this.phoneNumber, this.countryCode);
  final String phoneNumber;
  final String countryCode;
  String? otp;
  Future<void> setOTP(String value) async {
    otp = value;
  }

  String? getOTP() {
    return otp;
  }
}
