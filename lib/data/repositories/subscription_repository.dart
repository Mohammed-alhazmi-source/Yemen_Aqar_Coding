import 'dart:io';

import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/utils/api.dart';

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPackages({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getPackage,
      queryParameters: {
        'platform': Platform.isIOS ? 'ios' : 'android',
        // "current_user": HiveUtils.getUserId()
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<SubscriptionPackageModel>(SubscriptionPackageModel.fromJson)
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<Map<String, dynamic>> getPackageLimit({
    required String limitType,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'package_type': limitType,
      };
      print(parameters);
      final response = await Api.get(
        url: Api.getLimitsOfPackage,
        queryParameters: parameters,
        useAuthToken: true,
      );
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> subscribeToPackage(
    int packageId,
    bool isPackageAvailable,
  ) async {
    try {
      final parameters = <String, dynamic>{
        Api.packageId: packageId,
        // Api.userid: HiveUtils.getUserId(),
        if (isPackageAvailable) 'flag': 1,
      };

      await Api.post(
        url: Api.userPurchasePackage,
        parameter: parameters,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> assignFreePackage(int packageId) async {
    await Api.post(
      url: Api.assignPackage,
      parameter: {'package_id': packageId, 'in_app': false},
    );
  }

  Future<void> assignPackage({
    required String packageId,
    required String productId,
  }) async {
    try {
      await Api.post(
        url: Api.assignPackage,
        parameter: {
          'package_id': packageId,
          'product_id': productId,
          'in_app': true,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
