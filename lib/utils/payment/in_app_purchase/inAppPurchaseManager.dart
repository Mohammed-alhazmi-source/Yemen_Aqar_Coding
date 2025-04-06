import 'package:ebroker/data/cubits/subscription/assign_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseManager {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  String? packageId;
  String? productId;
  Future<ProductDetails> getProductByProductId(String productId) async {
    final productDetailsResponse =
        await _inAppPurchase.queryProductDetails({productId});
    return productDetailsResponse.productDetails.first;
  }

  Future<void> onSuccessfulPurchase(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    await purchaseCompleteDialog(context);
  }

  Future<void> onPurchaseCancel(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    paymentCancelDialog(context);
  }

  Future<void> onErrorPurchase(
    BuildContext context,
    PurchaseDetails purchase,
  ) async {
    paymentErrorDialog(context, purchase);
  }

  Future<void> onPendingPurchase(PurchaseDetails purchase) async {
    if (purchase.purchaseID != null && purchase.pendingCompletePurchase) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        await _inAppPurchase.completePurchase(purchase);
      } catch (e) {
        // Handle the error appropriately
      }
    }
  }

  Future<void> onRestoredPurchase(PurchaseDetails purchase) async {}
  Future completePending(event) async {
    for (final _purchaseDetails in event) {
      if (_purchaseDetails.purchaseID != null &&
          _purchaseDetails.pendingCompletePurchase) {
        try {
          await Future.delayed(const Duration(seconds: 1));
          await _inAppPurchase.completePurchase(_purchaseDetails);
        } catch (e) {
          // Handle the error appropriately
        }
      }
    }
  }

  static getPendings() {
    _inAppPurchase.purchaseStream.listen((event) {});
  }

  void listenIAP(BuildContext context) {
    _inAppPurchase.purchaseStream.listen((event) async {
      await completePending(event);
      for (final inAppPurchaseEvent in event) {
        if (inAppPurchaseEvent.error != null) {}
        if (inAppPurchaseEvent.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(inAppPurchaseEvent);
        }
        Future.delayed(
          Duration.zero,
          () {
            if (inAppPurchaseEvent.status == PurchaseStatus.purchased) {
              onSuccessfulPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.canceled) {
              onPurchaseCancel(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.error) {
              onErrorPurchase(context, inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.pending) {
              onPendingPurchase(inAppPurchaseEvent);
            } else if (inAppPurchaseEvent.status == PurchaseStatus.restored) {
              onRestoredPurchase(inAppPurchaseEvent);
            }
          },
        );
      }
    });
  }

  Future<void> buy(String productId, String packageId) async {
    final isAvailable = await _inAppPurchase.isAvailable();
    print('inAppPurchase.buy 1');
    if (isAvailable) {
      final productDetails = await getProductByProductId(productId);
      // _inAppPurchase._inAppPurchase.completePurchase();
      this.packageId = packageId;
      this.productId = productId;
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
    } else {
      print('inAppPurchase.buy failed');
    }
  }

  Future<void> purchaseCompleteDialog(BuildContext context) async {
    await context.read<AssignInAppPackageCubit>().assign(
          packageId: packageId!,
          productId: productId!,
        );
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'Purchase completed',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const CustomText('Your purchase has completed successfully'),
      ),
    );
  }

  void paymentCancelDialog(BuildContext context) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'Purchase canceled',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const CustomText('Your purchase has been canceled'),
      ),
    );
  }

  void paymentErrorDialog(BuildContext context, PurchaseDetails purchase) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'Purchase error',
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: CustomText('${purchase.error?.message}'),
      ),
    );
  }
}
