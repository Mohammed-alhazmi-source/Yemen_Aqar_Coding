import 'package:ebroker/data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchasePackage {
  Future<void> purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          context.read<FetchSystemSettingsCubit>().fetchSettings(
                isAnonymous: false,
                forceRefresh: true,
              );
          context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

          HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'success'),
            type: MessageType.success,
            messageDuration: 5,
          );

          Navigator.popUntil(context, (Route route) => route.isFirst);
        },
      );
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'purchaseFailed'),
        type: MessageType.error,
      );
    }
  }
}
