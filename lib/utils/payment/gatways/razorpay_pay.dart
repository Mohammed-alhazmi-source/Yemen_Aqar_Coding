import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPay extends Payment {
  late SubscriptionPackageModel? _model;

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }

  @override
  void pay(BuildContext context) {
    ///
    final razorpay = Razorpay();
    final options = {
      'key': Constant.razorpayKey,
      'amount': _model!.price! * 100,
      'name': _model!.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile,
        'email': HiveUtils.getUserDetails().email,
      },
      'notes': {
        'package_id': _model!.id,
        'user_id': HiveUtils.getUserId(),
      },
    };
    if (Constant.razorpayKey != '') {
      isPaymentGatewayOpen = true;

      razorpay
        ..open(options)
        ..on(
          Razorpay.EVENT_PAYMENT_SUCCESS,
          (
            PaymentSuccessResponse response,
          ) async {
            isPaymentGatewayOpen = false;
            emit(Success(message: 'Success'));
            // await _purchase(context);
          },
        )
        ..on(
          Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) {
            isPaymentGatewayOpen = false;

            emit(Failure(message: 'Success'));

            HelperUtils.showSnackBarMessage(
              context,
              UiUtils.translate(context, 'purchaseFailed'),
            );
          },
        )
        ..on(Razorpay.EVENT_PAYMENT_ERROR, (e) {
          isPaymentGatewayOpen = false;

          log('ISSUE IS ON RAZORPAY ITSELF $e');
        })
        ..on(
          Razorpay.EVENT_EXTERNAL_WALLET,
          (e) {},
        );
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'setAPIkey'),
      );
    }
  }

  @override
  Payment setPackage(SubscriptionPackageModel modal) {
    _model = modal;
    return this;
  }
}
