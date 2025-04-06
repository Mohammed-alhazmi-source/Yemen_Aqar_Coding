import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  static Map<String, String> getHeaders() => {
        'Authorization': 'Bearer ${StripeService.secret}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  static void init({String? stripePublishable, String? stripeSecrate}) {
    Stripe.publishableKey = stripePublishable ?? '';
    StripeService.secret = stripeSecrate;

    Stripe.merchantIdentifier = 'merchant.flut=ter.stripe.testaaa';
    if (Stripe.publishableKey == '') {
      log('Please add stripe publishable key');
    } else if (StripeService.secret == null) {
      log('Please add stripe secret key');
    }
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet({
    required int amount,
    required bool isTestEnvironment,
    String? currency,
    String? from,
    BuildContext? context,
    String? awaitedOrderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      //create Payment intent

      isPaymentGatewayOpen = true;
      final paymentIntent = await StripeService.createPaymentIntent(
        amount: amount,
        currency: currency,
        from: from,
        context: context,
        metadata: metadata, //{"packageId": 123, "userId": 123}
        // awaitedOrderID: awaitedOrderId,
      );

      //setting up Payment Sheet
      if (AppSettings.stripeCurrency == 'USD') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            allowsDelayedPaymentMethods: true,
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
              address: AddressCollectionMode.full,
              email: CollectionMode.always,
              name: CollectionMode.always,
              phone: CollectionMode.always,
            ),
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: AppSettings.applicationName,
          ),
        );
      } else {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            allowsDelayedPaymentMethods: true,
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: AppSettings.applicationName,
          ),
        );
      }

      //open payment sheet
      await Stripe.instance.presentPaymentSheet();

      //confirm payment
      final response = await Dio().post(
        '${StripeService.paymentApiUrl}/${paymentIntent['id']}',
        options: Options(headers: headers),
      );

      final getdata = Map.from(response.data);
      final statusOfTransaction = getdata['status'];
      log('--stripe response $getdata');
      if (statusOfTransaction == 'succeeded') {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          status: statusOfTransaction,
        );
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction pending',
          success: true,
          status: statusOfTransaction,
        );
      } else {
        isPaymentGatewayOpen = false;

        return StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
          status: statusOfTransaction,
        );
      }
    } on PlatformException catch (err) {
      log('Platform issue: $err');
      isPaymentGatewayOpen = false;

      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (error) {
      log('Other issue issue: $error');
      isPaymentGatewayOpen = false;
      return StripeTransactionResponse(
        message: 'Transaction failed: $error',
        success: false,
        status: 'fail',
      );
    }
  }

  static StripeTransactionResponse getPlatformExceptionErrorResult(err) {
    var message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(
      message: message,
      success: false,
      status: 'cancelled',
    );
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    String? currency,
    String? from,
    BuildContext? context,
    String? awaitedOrderID,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final parameter = <String, dynamic>{
        'amount': amount,
        'currency': currency,
        'metadata': metadata,
      };

      // if (from == 'order') parameter['metadata[order_id]'] = awaitedOrderID;

      final dio = Dio();

      final response = await dio.post(
        StripeService.paymentApiUrl,
        data: parameter,
        options: Options(
          headers: StripeService.getHeaders(),
        ),
      );

      return Map.from(response.data);
    } catch (e) {
      if (e is DioException) {
        log(e.response!.data.toString());
      }

      log('STRIPE ISSUE ${e is DioException}');
    }
    return null;
  }
}

class StripeTransactionResponse {
  StripeTransactionResponse({this.message, this.success, this.status});
  final String? message;
  final String? status;
  bool? success;
}

Future<void> openStripePaymentGateway({
  required double amount,
  required Map<String, dynamic> metadata,
  required VoidCallback onSuccess,
  required Function(dynamic message) onError,
}) async {
  try {
    StripeService.init(
      stripePublishable: AppSettings.stripePublishableKey,
      stripeSecrate: AppSettings.stripeSecrateKey,
    );

    final response = await StripeService.payWithPaymentSheet(
      amount: (amount * 100).toInt(),
      currency: AppSettings.stripeCurrency,
      isTestEnvironment: true,
      metadata: metadata,
    );

    if (response.status == 'succeeded') {
      onSuccess.call();
    } else {
      onError.call(response.message);
    }
  } catch (e) {
    log('ERROR IS $e');
  }
}
