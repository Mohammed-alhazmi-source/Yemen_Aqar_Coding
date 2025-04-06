// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/encryption/rsa.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());

      final result = await Api.get(
        url: Api.getPaymentApiKeys,
        queryParameters: {},
      );

      final data = result['data'] as List;
      final flutterwaveStatus = _getDataFromKey(data, 'flutterwave_status');
      final razorpayKey = _getDataFromKey(data, 'razor_key');
      final razorPaySecret = _getDataFromKey(data, 'razor_secret');
      final paystackPublicKey = _getDataFromKey(data, 'paystack_public_key');
      final paystackSecretKey = _getDataFromKey(data, 'paystack_secret_key');
      final paystackCurrency = _getDataFromKey(data, 'paystack_currency');
      final stripeCurrency = _getDataFromKey(data, 'stripe_currency');
      final stripePublishableKey =
          _getDataFromKey(data, 'stripe_publishable_key');
      final stripeSecretKey = _getDataFromKey(data, 'stripe_secret_key');
      var enabledGatway = '';

      if (_getDataFromKey(data, 'paypal_gateway') == '1') {
        enabledGatway = 'paypal';
      } else if (_getDataFromKey(data, 'razorpay_gateway') == '1') {
        enabledGatway = 'razorpay';
      } else if (_getDataFromKey(data, 'paystack_gateway') == '1') {
        enabledGatway = 'paystack';
      } else if (_getDataFromKey(data, 'stripe_gateway') == '1') {
        enabledGatway = 'stripe';
      } else if (flutterwaveStatus == '1') {
        enabledGatway = 'flutterwave';
      }

      emit(
        GetApiKeysSuccess(
          razorPayKey: razorpayKey ?? '',
          enabledPaymentGatway: enabledGatway,
          razorPaySecret: razorPaySecret ?? '',
          paystackPublicKey: paystackPublicKey ?? '',
          paystackCurrency: paystackCurrency ?? '',
          paystackSecret: paystackSecretKey ?? '',
          stripeCurrency: stripeCurrency ?? '',
          stripePublishableKey: stripePublishableKey ?? '',
          stripeSecretKey: stripeSecretKey ?? '',
          flutterwaveStatus: flutterwaveStatus ?? '',
        ),
      );
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  void setAPIKeys() {
    //setKeys
    if (state is GetApiKeysSuccess) {
      final st = state as GetApiKeysSuccess;

      AppSettings.paystackKey = st.paystackPublicKey;
      AppSettings.razorpayKey = st.razorPayKey;
      AppSettings.enabledPaymentGatway = st.enabledPaymentGatway;
      AppSettings.paystackCurrency = st.paystackCurrency;
      AppSettings.stripeCurrency = st.stripeCurrency;
      AppSettings.stripePublishableKey = st.stripePublishableKey;
      AppSettings.stripeSecrateKey = RSAEncryption().decrypt(
        privateKey: Constant.keysDecryptionPasswordRSA,
        encryptedData: st.stripeSecretKey,
      );
      paystack.init(AppSettings.paystackKey);
    }
    if (state is GetApiKeysFail) {
      log((state as GetApiKeysFail).error.toString(), name: 'API KEY FAIL');
    }
  }

  dynamic _getDataFromKey(List data, String key) {
    try {
      return data.where((element) => element['type'] == key).first['data'];
    } catch (e) {
      if (e.toString().contains('Bad state')) {
        log('The key>>> $key is not comming from API');
      }
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  final String razorPayKey;
  final String razorPaySecret;
  final String paystackPublicKey;
  final String paystackSecret;
  final String paystackCurrency;
  final String enabledPaymentGatway;
  final String stripeCurrency;
  final String stripePublishableKey;
  final String stripeSecretKey;
  final String flutterwaveStatus;
  GetApiKeysSuccess({
    required this.razorPayKey,
    required this.razorPaySecret,
    required this.paystackPublicKey,
    required this.paystackSecret,
    required this.paystackCurrency,
    required this.enabledPaymentGatway,
    required this.stripeCurrency,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
    required this.flutterwaveStatus,
  });

  @override
  String toString() {
    return 'GetApiKeysSuccess(razorPayKey: $razorPayKey, razorPaySecret: $razorPaySecret, paystackPublicKey: $paystackPublicKey, paystackSecret: $paystackSecret, paystackCurrency: $paystackCurrency, enabledPaymentGatway: $enabledPaymentGatway, stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey, flutterwaveStatus: $flutterwaveStatus)';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;
  GetApiKeysFail(this.error);
}
